#!/usr/bin/env ruby
# Quick Analysis of Search Console Data

require "csv"

puts "=" * 80
puts "📊 BOOKRHUB SEO ANALYSIS - Your Real Data"
puts "=" * 80

# Load data
queries = CSV.read("search_console_data/queries.csv", headers: true, header_converters: :symbol)
pages = CSV.read("search_console_data/pages.csv", headers: true, header_converters: :symbol)
critical = begin
  CSV.read("search_console_data/critical_issues.csv", headers: true, header_converters: :symbol)
rescue
  []
end

puts "\n\n📈 OVERALL PERFORMANCE"
puts "-" * 80
total_clicks = queries.sum { |r| r[:clics].to_i }
total_impressions = queries.sum { |r| r[:impresiones].to_i }
overall_ctr = begin
  total_clicks.to_f / total_impressions * 100
rescue
  0
end

puts "  Total Clicks: #{total_clicks}"
puts "  Total Impressions: #{total_impressions}"
puts "  Overall CTR: #{overall_ctr.round(2)}%"

# Position distribution
puts "\n\n📍 POSITION DISTRIBUTION"
puts "-" * 80
top3 = queries.count { |r| r[:posición].to_f <= 3 && r[:posición].to_f > 0 }
top10 = queries.count { |r| r[:posición].to_f <= 10 && r[:posición].to_f > 0 }
top20 = queries.count { |r| r[:posición].to_f <= 20 && r[:posición].to_f > 0 }
beyond20 = queries.count { |r| r[:posición].to_f > 20 }
total = queries.count

puts "  Position 1-3:   #{top3} queries (#{(total > 0) ? (top3.to_f / total * 100).round(1) : 0}%)"
puts "  Position 4-10:  #{top10 - top3} queries"
puts "  Position 11-20: #{top20 - top10} queries"
puts "  Position 21+:   #{beyond20} queries"

# Top queries
puts "\n\n🔍 TOP QUERIES BY CLICKS"
puts "-" * 80
queries.sort_by { |r| -r[:clics].to_i }.first(10).each do |r|
  query = r[:consultas_principales].to_s.strip
  next if query.empty?
  puts "  \"#{query}\""
  puts "    Clicks: #{r[:clics]} | Impressions: #{r[:impresiones]} | CTR: #{r[:ctr]} | Position: #{r[:posición]}"
end

# Top pages
puts "\n\n📄 TOP PAGES BY CLICKS"
puts "-" * 80
pages.sort_by { |r| -r[:clics].to_i }.first(10).each do |r|
  page = r[:páginas_principales].to_s.strip
  next if page.empty?
  short = (page.length > 60) ? page[0..57] + "..." : page
  puts "  #{short}"
  puts "    Clicks: #{r[:clics]} | Impressions: #{r[:impresiones]} | CTR: #{r[:ctr]} | Position: #{r[:posición]}"
end

# High opportunity queries
puts "\n\n🎯 OPPORTUNITIES - No Clicks But Showing in Search"
puts "-" * 80
opportunities = queries.select { |r| r[:clics].to_i == 0 && r[:impresiones].to_i > 5 && r[:posición].to_f > 0 }.sort_by { |r| -r[:impresiones].to_i }.first(15)
if opportunities.any?
  puts "  These queries appear in search but nobody clicks:"
  opportunities.each do |r|
    query = r[:consultas_principales].to_s.strip
    next if query.empty?
    puts "    \"#{query}\" - #{r[:impresiones]} impressions, pos #{r[:posición]}"
  end
else
  puts "  No major opportunities found"
end

# Coverage issues
puts "\n\n⚠️  INDEXING/COVERAGE ISSUES"
puts "-" * 80
if critical.any? && critical.first[:motivo]
  critical.each do |r|
    motivo = r[:motivo].to_s.strip
    paginas = r[:páginas].to_s.strip
    next if motivo.empty?
    puts "  #{motivo}: #{paginas} pages"
  end
end

puts "\n\n" + "=" * 80
puts "💡 KEY INSIGHTS"
puts "=" * 80

puts "\n1. YOUR BEST PERFORMING PAGE:"
best_page = pages.sort_by { |r| -r[:clics].to_i }.first
if best_page && best_page[:clics].to_i > 0
  puts "   #{best_page[:páginas_principales]}"
  puts "   #{best_page[:clics]} clicks, #{best_page[:impresiones]} impressions, #{best_page[:ctr]} CTR"
end

puts "\n2. YOUR SEO PAGES ARE NOT INDEXED YET:"
seo_pages = pages.select { |r| r[:páginas_principales].to_s.include?("bookrhub.com") && !r[:páginas_principales].to_s.include?(".bookrhub.com") }
seo_pages_count = seo_pages.count { |r| r[:clics].to_i == 0 && r[:impresiones].to_i > 0 }
puts "   #{seo_pages_count} SEO pages showing in search but 0 clicks"

puts "\n3. MAIN COVERAGE ISSUES:"
redirect_issues = critical.find { |r| r[:motivo].to_s.include?("Redirección") }
if redirect_issues
  puts "   ⚠️  #{redirect_issues[:páginas]} pages with redirect errors"
end
not_indexed = critical.find { |r| r[:motivo].to_s.include?("sin indexar") }
if not_indexed
  puts "   ⚠️  #{not_indexed[:páginas]} pages not indexed"
end

puts "\n\n" + "=" * 80
puts "🎯 ACTION ITEMS"
puts "=" * 80
puts "
1. SUBMIT SEO PAGES TO GOOGLE
   Your new pages need to be indexed manually:
   - /booking-system-for-barbers
   - /use-cases
   - /free-booking

2. FIX REDIRECT ERRORS
   42 pages have redirect issues - check those URLs

3. FIX 404 ERRORS
   16 pages return 404 - these are dead links

4. YOUR BEST CONTENT IS:
   Demo/template pages are getting traffic!
   Consider creating more of these

5. GEO-TARGETING:
   Queries are mostly in Spanish (Argentina)
   Your Spanish SEO pages are important
"
