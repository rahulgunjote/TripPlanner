#!/usr/bin/env ruby
# Test both Swift Testing and XCTest framework detection

puts "🧪 Testing Framework Detection (Swift Testing & XCTest)"
puts "=" * 60
puts ""

# Create sample test files to test both frameworks
sample_swift_testing = <<~SWIFT
import Testing
import Foundation
@testable import TripPlanner

@MainActor
struct SampleSwiftTestingTests {
    @Test("Test with description")
    func testSomething() async throws {
        // test code
    }
    
    @Test
    func testAnotherThing() {
        // test code
    }
    
    @Test(arguments: [1, 2, 3])
    func testWithArguments(value: Int) {
        // test code
    }
}
SWIFT

sample_xctest = <<~SWIFT
import XCTest
@testable import TripPlanner

class SampleXCTestTests: XCTestCase {
    func testExample() {
        XCTAssertTrue(true)
    }
    
    func testAnotherExample() {
        XCTAssertEqual(1, 1)
    }
    
    func helperMethod() {
        // This should not be detected
    }
}
SWIFT

sample_mixed = <<~SWIFT
import Testing
import XCTest
@testable import TripPlanner

// Mixed file (though unusual in practice)
@Test
func testSwiftTesting() {
}

class MixedTests: XCTestCase {
    func testXCTest() {
    }
}
SWIFT

# Test Swift Testing detection
puts "1️⃣ Testing Swift Testing Framework Detection"
puts "-" * 60
uses_swift_testing = sample_swift_testing.include?("import Testing")
tests = sample_swift_testing.scan(/@Test(?:\([^)]*\))?\s+func\s+(\w+)\(\s*\)/).flatten
puts "   Import detected: #{uses_swift_testing ? '✅' : '❌'}"
puts "   Tests found: #{tests.count}"
tests.each { |t| puts "     - #{t}" }
puts ""

# Test XCTest detection
puts "2️⃣ Testing XCTest Framework Detection"
puts "-" * 60
uses_xctest = sample_xctest.include?("import XCTest")
has_xctestcase = sample_xctest =~ /class\s+\w+\s*:\s*XCTestCase/
tests = sample_xctest.scan(/func (test\w+)\(\s*\)/).flatten
puts "   Import detected: #{uses_xctest ? '✅' : '❌'}"
puts "   XCTestCase found: #{has_xctestcase ? '✅' : '❌'}"
puts "   Tests found: #{tests.count}"
tests.each { |t| puts "     - #{t}" }
puts ""

# Test mixed detection
puts "3️⃣ Testing Mixed Framework Detection"
puts "-" * 60
uses_swift_testing = sample_mixed.include?("import Testing")
uses_xctest = sample_mixed.include?("import XCTest")
has_xctestcase = sample_mixed =~ /class\s+\w+\s*:\s*XCTestCase/

swift_tests = sample_mixed.scan(/@Test(?:\([^)]*\))?\s+func\s+(\w+)\(\s*\)/).flatten
xctest_tests = has_xctestcase ? sample_mixed.scan(/func (test\w+)\(\s*\)/).flatten : []

puts "   Swift Testing: #{uses_swift_testing ? '✅' : '❌'} (#{swift_tests.count} tests)"
swift_tests.each { |t| puts "     - #{t}" }
puts "   XCTest: #{uses_xctest ? '✅' : '❌'} (#{xctest_tests.count} tests)"
xctest_tests.each { |t| puts "     - #{t}" }
puts ""

# Now test with actual project files
puts "4️⃣ Testing Actual Project Files"
puts "-" * 60

test_files = Dir.glob("./TripPlannerTests/**/*Tests.swift")
if test_files.empty?
  puts "❌ No test files found!"
  exit 1
end

all_tests = []
tests_by_file = {}

test_files.each do |file|
  content = File.read(file)
  class_name = File.basename(file, ".swift")
  file_tests = Set.new
  
  uses_swift_testing = content.include?("import Testing")
  uses_xctest = content.include?("import XCTest")
  
  if uses_swift_testing
    content.scan(/@Test(?:\([^)]*\))?\s+func\s+(\w+)\(\s*\)/).each do |match|
      test_method = match[0]
      test_id = "TripPlannerTests/#{class_name}/#{test_method}"
      all_tests << test_id unless all_tests.include?(test_id)
      file_tests.add(test_method)
    end
  end
  
  if uses_xctest
    if content =~ /class\s+\w+\s*:\s*XCTestCase/
      content.scan(/func (test\w+)\(\s*\)/).each do |match|
        test_method = match[0]
        test_id = "TripPlannerTests/#{class_name}/#{test_method}"
        all_tests << test_id unless all_tests.include?(test_id)
        file_tests.add(test_method)
      end
    end
  end
  
  framework_info = []
  framework_info << "Swift Testing" if uses_swift_testing
  framework_info << "XCTest" if uses_xctest
  framework_str = framework_info.empty? ? "Unknown" : framework_info.join(" + ")
  
  tests_by_file[class_name] = { count: file_tests.size, framework: framework_str }
end

puts "📊 Total: #{all_tests.count} tests across #{test_files.count} files"
puts ""
tests_by_file.each do |file, info|
  puts "   #{file}: #{info[:count]} tests (#{info[:framework]})"
end
puts ""

if all_tests.count > 0
  puts "✅ Framework detection working correctly!"
  puts ""
  puts "Sample tests discovered:"
  all_tests.first(10).each { |t| puts "  - #{t}" }
  puts "  ... and #{all_tests.count - 10} more" if all_tests.count > 10
else
  puts "❌ No tests discovered!"
  exit 1
end
