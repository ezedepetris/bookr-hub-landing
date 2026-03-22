#!/usr/bin/env ruby
# Google Search Console API Setup Script
# Run this to configure OAuth credentials

require "fileutils"
require "json"

puts "\n" + "=" * 60
puts "🔧 Google Search Console API Setup"
puts "=" * 60

# Check if credentials already exist
config_dir = "config"
credentials_file = "#{config_dir}/google_credentials.json"

if File.exist?(credentials_file)
  puts "\n✅ Credentials file already exists at #{credentials_file}"
  puts "\nTo reauthorize, delete the token file:"
  puts "  rm .searchconsole_token.yaml"
  puts "\nThen run:"
  puts "  ruby scripts/search_console_analyzer.rb"
  exit 0
end

# Create config directory
FileUtils.mkdir_p(config_dir)

puts "\n📋 Step 1: Create OAuth Credentials"
puts "-" * 60
puts <<~INSTRUCTIONS
  
  1. Go to: https://console.cloud.google.com/apis/credentials
  2. Click "Create Credentials" → "OAuth client ID"
  3. Application type: "Web application"
  4. Name: "BookrHub SEO Analyzer"
  5. Authorized redirect URIs: Add "http://localhost:8080"
  6. Click "Create"
  7. Download the JSON file
  
INSTRUCTIONS

puts "\n📥 Step 2: Save Credentials"
puts "-" * 60
print "Paste the full path to your downloaded JSON file: "
credentials_path = STDIN.gets.chomp.strip

# Remove quotes if present
credentials_path.delete!('"')
credentials_path.delete!("'")

unless File.exist?(credentials_path)
  puts "\n❌ File not found at: #{credentials_path}"
  puts "Please try again with the correct path."
  exit 1
end

# Copy to config directory
begin
  credentials = JSON.parse(File.read(credentials_path))

  # Validate it's an OAuth credential
  unless credentials["installed"] || credentials["web"]
    puts "\n❌ Invalid credentials file."
    puts "Make sure you downloaded an OAuth client ID (Web application or Other)."
    exit 1
  end

  # For installed apps, structure is different - save as-is
  FileUtils.cp(credentials_path, credentials_file)
  puts "\n✅ Credentials saved to #{credentials_file}"
rescue JSON::ParserError => e
  puts "\n❌ Invalid JSON file: #{e.message}"
  exit 1
end

puts "\n📊 Step 3: Enable Search Console API"
puts "-" * 60
puts <<~INSTRUCTIONS
  
  1. Go to: https://console.cloud.google.com/apis/library/searchconsole.googleapis.com
  2. Make sure your project is selected
  3. Click "Enable"
  
INSTRUCTIONS

puts "\n🔐 Step 4: Add Search Console Property"
puts "-" * 60
puts <<~INSTRUCTIONS
  
  1. Go to: https://search.google.com/search-console
  2. Click "Add Property"
  3. Enter: https://bookrhub.com
  4. Verify ownership (HTML file upload or DNS record)
  
INSTRUCTIONS

puts "\n🚀 Step 5: Run the Analyzer"
puts "-" * 60
puts <<~INSTRUCTIONS
  
  1. Install required gems:
     gem install google-apis-searchconsole googleauth oauth2
  
  2. Run the analyzer:
     ruby scripts/search_console_analyzer.rb
  
  3. The first time, it will ask you to:
     - Open a URL in your browser
     - Authorize access to your Search Console data
     - Copy the authorization code back
  
INSTRUCTIONS

puts "\n" + "=" * 60
puts "✅ Setup complete!"
puts "=" * 60
