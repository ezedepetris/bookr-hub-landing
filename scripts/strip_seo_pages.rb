#!/usr/bin/env ruby
# Script to strip SEO pages down to content only (remove HTML wrapper)

require 'fileutils'

def process_file(filepath)
  content = File.read(filepath)

  # Find the start of main content (hero-seo header)
  main_start = content.index('<header class="hero-seo">')
  return nil unless main_start

  # Find the end of main (closing </main> tag)
  main_end = content.index('</main>', main_start)
  return nil unless main_end

  # Extract just the content between <main> tags
  main_content = content[main_start..main_end + 6]

  # Also keep FAQ schema from head if present
  schema = ''
  if content.include?('<!-- FAQ Schema -->')
    schema_start = content.index('<!-- FAQ Schema -->')
    schema_end = content.index('</script>', schema_start) + 9
    schema = content[schema_start..schema_end]
  end

  # Also keep structured data if present
  if content.include?('<!-- Structured Data -->')
    struct_start = content.index('<!-- Structured Data -->')
    struct_end = content.index('</script>', struct_start) + 9
    schema += "\n" + content[struct_start..struct_end]
  end

  # Combine schema with content
  result = schema + "\n" + main_content

  # Clean up any duplicate </main> tags
  result.gsub!(%r{</main>.*</main>}m, '</main>')

  result
end

# Process English pages
en_dir = '/Users/femputadora/Documents/code/experiments/bookr-hub/bookr-hub-landing/public/seo/en'
en_count = 0
Dir.glob("#{en_dir}/*.html").each do |filepath|
  result = process_file(filepath)
  if result
    File.write(filepath, result)
    en_count += 1
  end
end

puts "Processed #{en_count} English pages"

# Process Spanish pages
es_dir = '/Users/femputadora/Documents/code/experiments/bookr-hub/bookr-hub-landing/public/seo/es'
es_count = 0
Dir.glob("#{es_dir}/*.html").each do |filepath|
  result = process_file(filepath)
  if result
    File.write(filepath, result)
    es_count += 1
  end
end

puts "Processed #{es_count} Spanish pages"
puts 'Done!'
