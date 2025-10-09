# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.5"

gem "fastlane", "~> 2.221"
gem "xcode-install"
gem "xcov", "~> 1.5"
gem 'xcpretty'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

