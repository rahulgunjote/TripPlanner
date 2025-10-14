#!/usr/bin/env ruby
# Quick script to test the test discovery logic

puts "🔍 Testing test discovery logic..."
puts "Current directory: #{Dir.pwd}"
puts ""

# Try different paths
paths = [
  "./TripPlannerTests/**/*Tests.swift",
  "../TripPlannerTests/**/*Tests.swift",
  "#{Dir.pwd}/TripPlannerTests/**/*Tests.swift"
]

paths.each_with_index do |pattern, i|
  puts "#{i + 1}. Trying pattern: #{pattern}"
  files = Dir.glob(pattern)
  puts "   Found #{files.count} files"
  files.first(3).each { |f| puts "   - #{f}" }
  puts ""
end

# Use the first successful pattern
test_files = []
paths.each do |pattern|
  test_files = Dir.glob(pattern)
  break unless test_files.empty?
end

if test_files.empty?
  puts "❌ No test files found!"
  exit 1
end

puts "✅ Using #{test_files.count} test files"
puts ""

all_tests = []

test_files.each do |file|
  content = File.read(file)
  class_name = File.basename(file, ".swift")
  
  # XCTest methods
  xctest_methods = content.scan(/func (test\w+)\(\)/).flatten
  
  # Swift Testing methods
  swift_testing_methods = content.scan(/@Test(?:\([^)]*\))?\s+func\s+(\w+)\(\)/).flatten
  
  xctest_methods.each do |method|
    all_tests << "TripPlannerTests/#{class_name}/#{method}"
  end
  
  swift_testing_methods.each do |method|
    all_tests << "TripPlannerTests/#{class_name}/#{method}"
  end
  
  puts "📄 #{class_name}:"
  puts "   XCTest methods: #{xctest_methods.count}"
  puts "   Swift Testing methods: #{swift_testing_methods.count}"
end

puts ""
puts "📊 Total tests discovered: #{all_tests.count}"
puts ""
puts "Sample tests:"
all_tests.first(10).each { |t| puts "  - #{t}" }
puts "  ... and #{all_tests.count - 10} more" if all_tests.count > 10
