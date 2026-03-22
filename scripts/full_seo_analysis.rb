#!/usr/bin/env ruby
# Comprehensive SEO Analysis - Based on your Search Console Data

require "csv"

puts "=" * 80
puts "📊 BOOKRHUB SEO ANALYSIS - COMPREHENSIVE REPORT"
puts "=" * 80

# ============================================
# 1. PAGES NOT INDEXED
# ============================================

not_indexed_urls = []
File.readlines("search_console_data/drilldowns/drilldown (7).csv").each do |line|
  next if line.include?("Último rastreo") || line.include?("1970-01-01")
  url = line.strip.split(",").first
  not_indexed_urls << url if url && url.include?("http")
end

# Categorize not indexed pages
not_indexed_by_type = {
  "SEO Landing Pages" => [],
  "City Pages" => [],
  "Spanish SEO Pages" => [],
  "App/Other" => []
}

not_indexed_urls.each do |url|
  if url.include?("/es/") || url.include?("/sistema-")
    not_indexed_by_type["Spanish SEO Pages"] << url
  elsif url.include?("-in-") || url.include?("-en-")
    not_indexed_by_type["City Pages"] << url
  elsif url.include?("/booking-system") || url.include?("/use-cases") || url.include?("/free") || url.include?("/vs-") || url.include?("/best-")
    not_indexed_by_type["SEO Landing Pages"] << url
  else
    not_indexed_by_type["App/Other"] << url
  end
end

puts "\n\n🚨 PAGES DISCOVERED BUT NOT INDEXED: #{not_indexed_urls.count}"
puts "-" * 80

not_indexed_by_type.each do |type, urls|
  if urls.any?
    puts "\n#{type}: #{urls.count} pages"
    urls.first(5).each { |u| puts "  - #{u}" }
    puts "  ... and #{urls.count - 5} more" if urls.count > 5
  end
end

# ============================================
# 2. PAGES THAT ARE INDEXED/CRAWLED
# ============================================

indexed_pages = []
Dir.glob("search_console_data/drilldowns/*.csv").each do |file|
  next if file.include?("drilldown (7)")
  File.readlines(file).each do |line|
    next if line.include?("Último rastreo") || line.include?("1970-01-01")
    url = line.strip.split(",").first
    date = line.strip.split(",").last
    indexed_pages << {url: url, crawled: date} if url && url.include?("http")
  end
end

puts "\n\n✅ PAGES THAT HAVE BEEN CRAWLED: #{indexed_pages.count}"
puts "-" * 80

# Categorize indexed pages
indexed_by_status = {
  "Recently Crawled (2026)" => [],
  "Old Crawl (2025)" => [],
  "Very Old (2024-2023)" => []
}

indexed_pages.each do |page|
  year = page[:crawled].to_i
  if year >= 2026
    indexed_by_status["Recently Crawled (2026)"] << page
  elsif year >= 2025
    indexed_by_status["Old Crawl (2025)"] << page
  else
    indexed_by_status["Very Old (2024-2023)"] << page
  end
end

indexed_by_status.each do |status, pages|
  puts "\n#{status}: #{pages.count} pages"
  pages.first(5).each { |p| puts "  - #{p[:url]} (#{p[:crawled]})" }
  puts "  ... and #{pages.count - 5} more" if pages.count > 5
end

# ============================================
# 3. SEO LANDING PAGES STATUS
# ============================================

puts "\n\n🎯 SEO LANDING PAGES STATUS:"
puts "-" * 80

seo_patterns = {
  "/booking-system-for-" => "Niche Landing Pages",
  "/use-cases" => "Use Cases Hub",
  "/free-booking" => "Free Booking Page",
  "/why-bookrhub" => "Why BookrHub",
  "/best-" => "Best/Comparison Pages",
  "/vs-" => "Competitor Comparison",
  "/how-to-" => "How-To Guides",
  "/sistema-de-turnos" => "Spanish Niche Pages",
  "/en-" => "City-Niche Pages (EN)",
  "/es/" => "Spanish City Pages"
}

seo_counts = Hash.new(0)
seo_indexed = Hash.new(0)
seo_not_indexed = Hash.new(0)

not_indexed_urls.each do |url|
  seo_patterns.each do |pattern, name|
    if url.include?(pattern)
      seo_not_indexed[name] += 1
      seo_counts[name] += 1
    end
  end
end

indexed_pages.each do |page|
  seo_patterns.each do |pattern, name|
    if page[:url].include?(pattern)
      seo_indexed[name] += 1
      seo_counts[name] += 1
    end
  end
end

puts "\n| Page Type | Total | Indexed | NOT Indexed |"
puts "|-----------|-------|--------|-------------|"

seo_counts.sort_by { |k, v| -v }.each do |type, total|
  indexed = seo_indexed[type] || 0
  not_ind = seo_not_indexed[type] || 0
  puts "| #{type} | #{total} | #{indexed} | #{not_ind} |"
end

# ============================================
# 4. KEY INSIGHTS
# ============================================

puts "\n\n" + "=" * 80
puts "💡 KEY INSIGHTS & RECOMMENDATIONS"
puts "=" * 80

total_seo_pages = seo_counts.values.sum
total_indexed = seo_indexed.values.sum
total_not_indexed = seo_not_indexed.values.sum

puts "
1. YOUR SEO PAGES ARE MOSTLY NOT INDEXED
   ─────────────────────────────────────
   • Total SEO pages created: #{total_seo_pages}
   • Indexed: #{total_indexed} (#{begin
     total_indexed.to_f / total_seo_pages * 100
   rescue
     0
   end}%)
   • NOT Indexed: #{total_not_indexed}

   💡 ACTION: Submit top SEO pages to Google Search Console immediately

2. CITY PAGES NEED ATTENTION
   ───────────────────────────
   • #{seo_not_indexed["City-Niche Pages (EN)"] || 0} city pages not indexed
   • These are your main SEO targeting pages

   💡 ACTION: These are the most valuable - prioritize indexing

3. SPANISH PAGES ARE WORKING
   ───────────────────────────
   • #{seo_indexed["Spanish Niche Pages"] || 0} Spanish pages indexed
   • Your Spanish content is being crawled

   💡 GOOD: Keep creating Spanish content

4. PAGES WITH 1970 DATE = NOT CRAWLED
   ─────────────────────────────────────
   • 1,000 pages have never been crawled
   • Google discovered them but hasn't prioritized crawling

   💡 ACTION: Submit sitemap and key pages manually
"

# ============================================
# 5. TOP PAGES TO SUBMIT
# ============================================

puts "\n\n📋 TOP 20 PAGES TO SUBMIT TO GOOGLE (Priority Order):"
puts "-" * 80

priority_pages = []

# Add niche landing pages
priority_pages << "/booking-system-for-barbers"
priority_pages << "/booking-system-for-hair-salons"
priority_pages << "/booking-system-for-beauty-salons"
priority_pages << "/booking-system-for-massage-spa"
priority_pages << "/use-cases"
priority_pages << "/free-booking"
priority_pages << "/why-bookrhub"
priority_pages << "/best-booking-system"

# Add Spanish versions
priority_pages << "/es/sistema-de-turnos-para-barbers"
priority_pages << "/es/reservas-gratis"
priority_pages << "/es/casos-de-uso"

# Add key city pages
priority_pages << "/booking-system-for-barbers-in-sydney"
priority_pages << "/booking-system-for-barbers-in-auckland"
priority_pages << "/booking-system-for-barbers-in-buenos-aires"

# Add competitor comparisons
priority_pages << "/vs-fresha"
priority_pages << "/vs-calendly"

priority_pages.uniq.first(20).each_with_index do |page, i|
  full_url = "https://bookrhub.com#{page}"
  indexed = indexed_pages.any? { |p| p[:url].include?(page) }
  status = indexed ? "✅" : "❌"
  puts "  #{i + 1}. #{status} #{full_url}"
end

# ============================================
# 6. ISSUES TO FIX
# ============================================

puts "\n\n⚠️  TECHNICAL ISSUES TO FIX:"
puts "-" * 80

puts "
1. PAGES WITH 1970-01-01 DATE
   • These pages exist but Google hasn't crawled them
   • Need to submit sitemap and request indexing

2. DUPLICATE CONTENT WARNING
   • /use-cases might conflict with /es/casos-de-uso
   • City pages may be too similar to niche pages

3. CANONICAL URL ISSUES
   • Some pages may not have proper canonical tags
   • Check pages with similar content

4. HTTP/HTTPS MIX
   • Some drilldowns show http://bookrhub.com/ (without www)
   • Ensure consistent URL structure
"

puts "\n\n" + "=" * 80
puts "🚀 IMMEDIATE ACTION PLAN"
puts "=" * 80
puts "
STEP 1: Submit these pages NOW (use URL Inspection in Search Console):
──────────────────────────────────────────────────────────────────────
https://bookrhub.com/booking-system-for-barbers
https://bookrhub.com/use-cases
https://bookrhub.com/free-booking
https://bookrhub.com/why-bookrhub
https://bookrhub.com/booking-system-for-barbers-in-sydney
https://bookrhub.com/booking-system-for-barbers-in-auckland

STEP 2: Submit sitemap
──────────────────────────────────────────────────────────────────────
• Go to Search Console → Sitemaps
• Submit: https://bookrhub.com/sitemap.xml

STEP 3: Wait 1-2 weeks
──────────────────────────────────────────────────────────────────────
• Google will crawl and index submitted pages
• Monitor Coverage report for changes

STEP 4: Create more backlinks
──────────────────────────────────────────────────────────────────────
• Each new page needs at least 1 backlink to get indexed faster
• Submit to directories, create social shares
"

puts "\n\n✅ ANALYSIS COMPLETE"
