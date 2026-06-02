#!/usr/bin/env ruby
# Inject GEO statistics into programmatic SEO pages
# Adds city-specific market data callouts to improve GEO/AI SEO value

require 'fileutils'
require_relative '../lib/seo_generation/geo_data'

SEO_DIR = File.join(__dir__, '..', 'public', 'seo')

# Build reverse lookup: city_slug → country_key
def build_city_country_map
  map = {}
  GeoData::COUNTRY_DATA.each do |country_key, data|
    data[:cities].each_key do |city_slug|
      map[city_slug] = country_key
    end
  end
  map
end

CITY_COUNTRY_MAP = build_city_country_map

# Determine locale from filename/directory
def detect_locale(file_path)
  path = file_path.sub(SEO_DIR, '')
  if path.start_with?('/es/') || path.start_with?('\\es\\')
    :es
  else
    :en
  end
end

# Extract city slug from filename
def extract_city(file_path)
  basename = File.basename(file_path, '.html').downcase

  # English pattern: booking-system-for-{niche}-in-{city}
  if basename.include?('-in-')
    city = basename.split('-in-').last
    return city
  end

  # Spanish pattern: sistema-de-turnos-para-{niche}-en-{city}
  if basename.include?('-en-')
    city = basename.split('-en-').last
    return city
  end

  nil
end

# Extract niche slug from filename
def extract_niche(file_path, locale)
  basename = File.basename(file_path, '.html').downcase
  niches = GeoData::NICHE_NAMES.keys

  if locale == :es
    niches.find { |n| basename.include?(n) || basename.include?(GeoData::NICHE_NAMES.dig(n, :es, :singular)&.tr(' ', '-')) }
  else
    niches.find { |n| basename.include?(n) }
  end
end

# Add seo-layout.min.css to head if not present
def inject_layout_css(content)
  if content.include?('seo-layout')
    return content
  end

  # Find the stylesheet link and add seo-layout after it
  content.sub(
    %r{<link rel="stylesheet" href="[^"]*styles\.css[^"]*">},
    '\0' + "\n  <link rel=\"stylesheet\" href=\"/css/seo-layout.min.css\">"
  )
end

# Update CSS version
def update_css_version(content)
  content.gsub('styles.css?v=2.5.1', 'styles.min.css?v=2.6.0')
end

# Inject stat callout after intro paragraph in content section
def inject_stat_callout(content, country_key, city_slug, niche, locale)
  stat_html = GeoData.stat_callout_html(country_key, city_slug, niche, locale)
  return content if stat_html.strip.empty?

  # Inject after the intro paragraph (first <p> inside .seo-content)
  if content.include?('<div class="seo-content">')
    content.sub(
      %r{(<div class="seo-content">\s*<p class="intro">[^<]*</p>)},
      "\\1\n\n  #{stat_html}"
    )
  elsif content.include?('class="seo-content"')
    content.sub(
      %r{(<p[^>]*>.*?</p>)},
      "\\1\n\n  #{stat_html}"
    )
  else
    content
  end
end

# Add stat callout CSS inline for pages that may not have seo-layout
def inject_stat_styles(content)
  return content if content.include?('stat-callout')

  styles = <<~CSS


    <style>
    .stat-callout { background: #f0f7ff; border-left: 4px solid #0066cc; padding: 1.5rem; margin: 1.5rem 0; border-radius: 0 8px 8px 0; }
    .stat-callout-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 1rem; }
    .stat-item { text-align: center; }
    .stat-number { font-size: 1.75rem; font-weight: 700; color: #0066cc; display: block; line-height: 1.2; }
    .stat-label { font-size: 0.85rem; color: #555; display: block; margin-top: 0.25rem; }
    .stat-source { font-size: 0.8rem; color: #888; font-style: italic; margin-top: 0.75rem; margin-bottom: 0; }
    @media (max-width: 600px) { .stat-callout-grid { grid-template-columns: repeat(2, 1fr); } }
    </style>
  CSS

  content.sub('</head>', "#{styles}\n</head>")
end

def update_file(file_path)
  content = File.read(file_path)
  orig = content.dup

  locale = detect_locale(file_path)
  city_slug = extract_city(file_path)
  niche = extract_niche(file_path, locale)

  if city_slug.nil? || niche.nil?
    puts "  Skip (no city/niche): #{File.basename(file_path)}"
    return false
  end

  country_key = CITY_COUNTRY_MAP[city_slug]
  if country_key.nil?
    puts "  Skip (unknown city '#{city_slug}'): #{File.basename(file_path)}"
    return false
  end

  # Skip if already has stats
  if content.include?('stat-callout')
    # Already processed
    return false
  end

  content = update_css_version(content)
  content = inject_layout_css(content)
  content = inject_stat_styles(content)
  content = inject_stat_callout(content, country_key, city_slug, niche, locale)

  if content != orig
    File.write(file_path, content)
    true
  else
    false
  end
end

def process_directory(dir, label)
  count = 0
  Dir.glob(File.join(dir, '**', '*.html')).each do |file|
    if update_file(file)
      count += 1
    end
  end
  puts "#{label}: #{count} pages updated"
  count
end

puts "Injecting GEO statistics into SEO pages..."
puts "=" * 50

en_count = process_directory(File.join(SEO_DIR, 'en'), 'English')
es_count = process_directory(File.join(SEO_DIR, 'es'), 'Spanish')

puts "=" * 50
puts "Done! #{en_count + es_count} pages updated"
puts "  - #{en_count} English pages"
puts "  - #{es_count} Spanish pages"
