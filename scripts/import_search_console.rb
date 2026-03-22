#!/usr/bin/env ruby
# Manual Search Console Import Script
#
# This script helps you import data from Google Search Console
# that you export manually as CSV.
#
# Export Steps:
# 1. Go to: https://search.google.com/search-console
# 2. Select your property
# 3. Go to "Performance" report
# 4. Click "Export" → "Download CSV"
# 5. Save as "search_console_export.csv" in this directory
# 6. Run: ruby scripts/import_search_console.rb

require "csv"
require "json"

puts "\n" + "=" * 60
puts "📊 Search Console Data Analyzer"
puts "=" * 60

# Check if file exists
csv_file = "search_console_export.csv"

unless File.exist?(csv_file)
  puts "\n❌ File not found: #{csv_file}"
  puts "\n📥 Export your data from Google Search Console:"
  puts "   1. Go to: https://search.google.com/search-console"
  puts "   2. Select: https://bookrhub.com/"
  puts "   3. Go to: Performance → Pages"
  puts "   4. Date range: Last 28 days"
  puts "   5. Click: Export → Download CSV"
  puts "   6. Save as: #{csv_file}"
  exit 1
end

puts "\n✅ Found #{csv_file}"

# Parse CSV
rows = CSV.read(csv_file, headers: true, header_converters: :symbol)

puts "\n📊 Analysis Summary"
puts "-" * 60

# Basic stats
total_clicks = rows.sum { |r| r[:clicks].to_f }
total_impressions = rows.sum { |r| r[:impressions].to_f }
avg_ctr = begin
  total_clicks / total_impressions * 100
rescue
  0
end
avg_position = begin
  rows.sum { |r| r[:position].to_f * r[:clicks].to_f } / total_clicks
rescue
  0
end

puts "Total Clicks: #{total_clicks.to_i}"
puts "Total Impressions: #{total_impressions.to_i}"
puts "Average CTR: #{avg_ctr.round(2)}%"
puts "Average Position: #{avg_position.round(1)}"

# Top queries
puts "\n🔍 Top 20 Queries by Clicks:"
puts "-" * 60
rows.sort_by { |r| -r[:clicks].to_f }.first(20).each do |row|
  query = row[:query]
  clicks = row[:clicks].to_i
  impressions = row[:impressions].to_i
  ctr = (row[:ctr].to_f * 100).round(2)
  position = row[:position].to_f.round(1)

  puts "#{query}"
  puts "  Clicks: #{clicks} | Impressions: #{impressions} | CTR: #{ctr}% | Pos: #{position}"
  puts
end

# SEO Opportunities
puts "\n🎯 SEO Opportunities"
puts "-" * 60

# High impressions, low CTR
puts "\n⚠️  High Impressions, Low CTR (Improve Titles/Meta):"
high_imp_low_ctr = rows.select { |r|
  r[:impressions].to_i > 500 && r[:ctr].to_f < 0.03 && r[:position].to_f <= 20
}
high_imp_low_ctr.sort_by { |r| -r[:impressions].to_i }.first(10).each do |row|
  puts "  \"#{row[:query]}\""
  puts "    Position: #{row[:position]} | CTR: #{(row[:ctr].to_f * 100).round(2)}% | Impressions: #{row[:impressions]}"
  puts "    💡 Consider rewriting title/description for this query"
end

# Position 5-10 (almost ranking)
puts "\n📈 Position 5-10 (Almost Ranking - Build Backlinks):"
almost_ranking = rows.select { |r|
  r[:position].to_f >= 5 && r[:position].to_f <= 10 && r[:clicks].to_i < 10
}
almost_ranking.sort_by { |r| r[:position] }.first(10).each do |row|
  puts "  \"#{row[:query]}\""
  puts "    Position: #{row[:position]} | Clicks: #{row[:clicks]} | Impressions: #{row[:impressions]}"
  puts "    💡 Focus on building quality backlinks to this page"
end

# Low position but getting clicks
puts "\n🔄 Low Position but Getting Clicks (Strong Content):"
strong_content = rows.select { |r|
  r[:position].to_f > 10 && r[:position].to_f <= 20 && r[:clicks].to_i > 20
}
strong_content.sort_by { |r| -r[:clicks].to_f }.first(10).each do |row|
  puts "  \"#{row[:query]}\""
  puts "    Position: #{row[:position]} | Clicks: #{row[:clicks]} | Impressions: #{row[:impressions]}"
  puts "    💡 Great content! Improve SEO to rank higher"
end

# Zero clicks, high impressions
puts "\n❌ Zero Clicks but Impressions (Title/Intent Mismatch):"
zero_clicks = rows.select { |r|
  r[:clicks].to_i == 0 && r[:impressions].to_i > 100
}
zero_clicks.sort_by { |r| -r[:impressions].to_i }.first(10).each do |row|
  puts "  \"#{row[:query]}\""
  puts "    Position: #{row[:position]} | Impressions: #{row[:impressions]} | CTR: 0%"
  puts "    ⚠️  Your page appears but no one clicks - check if content matches intent"
end

# Top pages
puts "\n📄 Top Performing Pages:"
puts "-" * 60
# Group by page and sum
pages_data = {}
rows.each do |row|
  page = row[:page]
  pages_data[page] ||= {clicks: 0, impressions: 0}
  pages_data[page][:clicks] += row[:clicks].to_f
  pages_data[page][:impressions] += row[:impressions].to_f
end

pages_data.sort_by { |k, v| -v[:clicks] }.first(10).each do |page, data|
  short_page = page.gsub("https://bookrhub.com", "")[0..50]
  puts "#{short_page}"
  puts "  Clicks: #{data[:clicks].to_i} | Impressions: #{data[:impressions].to_i}"
end

# Recommendations
puts "\n" + "=" * 60
puts "💡 Recommendations Summary"
puts "=" * 60

# Count issues
issues = {
  title_meta: rows.count { |r| r[:impressions].to_i > 500 && r[:ctr].to_f < 0.03 && r[:position].to_f <= 20 },
  almost_ranking: rows.count { |r| r[:position].to_f >= 5 && r[:position].to_f <= 10 },
  no_clicks: rows.count { |r| r[:clicks].to_i == 0 && r[:impressions].to_i > 100 }
}

puts "\n📋 Issue Counts:"
puts "  ⚠️  High impressions, low CTR: #{issues[:title_meta]}"
puts "  📈 Almost ranking (pos 5-10): #{issues[:almost_ranking]}"
puts "  ❌ Zero clicks: #{issues[:no_clicks]}"

puts "\n🎬 Next Steps:"
puts "  1. For title/meta issues: Rewrite page titles and descriptions"
puts "  2. For almost ranking: Build more backlinks to those pages"
puts "  3. For no clicks: Review if page content matches search intent"

# Export actionable report
CSV.open("seo_recommendations.csv", "w") do |csv|
  csv << ["Query", "Page", "Clicks", "Impressions", "CTR", "Position", "Issue", "Recommendation"]

  rows.each do |row|
    issue = nil
    recommendation = nil

    if row[:impressions].to_i > 500 && row[:ctr].to_f < 0.03 && row[:position].to_f <= 20
      issue = "Low CTR"
      recommendation = "Rewrite title and meta description to match query"
    elsif row[:position].to_f >= 5 && row[:position].to_f <= 10
      issue = "Almost ranking"
      recommendation = "Build backlinks or improve content quality"
    elsif row[:clicks].to_i == 0 && row[:impressions].to_i > 100
      issue = "No clicks"
      recommendation = "Check if content matches search intent"
    end

    if issue
      csv << [
        row[:query],
        row[:page],
        row[:clicks],
        row[:impressions],
        (row[:ctr].to_f * 100).round(2),
        row[:position],
        issue,
        recommendation
      ]
    end
  end
end

puts "\n✅ Actionable items exported to: seo_recommendations.csv"
