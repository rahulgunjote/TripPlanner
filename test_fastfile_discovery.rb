#!/usr/bin/env ruby
# Test the exact logic used in Fastfile for test discovery

puts "🧪 Testing Fastfile test discovery logic..."
puts "📂 Current directory: #{Dir.pwd}"
puts ""

# Find all test files - check multiple possible paths
search_paths = [
  "./TripPlannerTests/**/*Tests.swift",  # From project root
  "../TripPlannerTests/**/*Tests.swift",  # From fastlane directory
  "#{Dir.pwd}/TripPlannerTests/**/*Tests.swift"  # Absolute path
]

test_files = []
search_paths.each do |pattern|
  test_files = Dir.glob(pattern)
  if !test_files.empty?
    puts "✅ Found test files using pattern: #{pattern}"
    break
  end
end

if test_files.empty?
  puts "❌ No test files found!"
  puts "Searched patterns:"
  search_paths.each { |p| puts "  - #{p}" }
  exit 1
end

puts "📁 Found #{test_files.count} test files"
all_tests = []
tests_by_file = {}

# Parse test files to extract test methods
test_files.each do |file|
  content = File.read(file)
  class_name = File.basename(file, ".swift")
  file_tests = []
  
  # Extract Swift Testing methods (@Test annotation)
  # Pattern: @Test("description") func testName() or @Test func testName()
  content.scan(/@Test(?:\([^)]*\))?\s+func\s+(\w+)\(\)/).each do |match|
    test_method = match[0]
    test_id = "TripPlannerTests/#{class_name}/#{test_method}"
    all_tests << test_id
    file_tests << test_method
  end
  
  # Also try XCTest pattern as fallback
  content.scan(/func (test\w+)\(\)/).each do |match|
    test_method = match[0]
    test_id = "TripPlannerTests/#{class_name}/#{test_method}"
    # Only add if not already added by Swift Testing pattern
    if !all_tests.include?(test_id)
      all_tests << test_id
      file_tests << test_method
    end
  end
  
  tests_by_file[class_name] = file_tests.count
end

if all_tests.empty?
  puts "❌ No test methods found in test files!"
  puts "Files checked: #{tests_by_file.keys.join(', ')}"
  exit 1
end

puts "📊 Found #{all_tests.count} total tests across #{test_files.count} test files"
tests_by_file.each { |file, count| puts "   #{file}: #{count} tests" }
puts ""

puts "✅ Test discovery successful!"
puts ""
puts "Sample tests:"
all_tests.first(15).each { |t| puts "  - #{t}" }
puts "  ... and #{all_tests.count - 15} more" if all_tests.count > 15
