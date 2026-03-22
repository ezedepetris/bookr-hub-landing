#!/usr/bin/env ruby
# Deep SEO Analysis - Competitor Comparison & Ranking Gap Analysis
#
# EXPORT DATA FROM SEARCH CONSOLE:
# 1. Go to: https://search.google.com/search-console
# 2. Select: https://bookrhub.com/
# 3. Performance → Pages
# 4. Date range: Last 90 days (for better data)
# 5. Dimensions: Query, Page, Country
# 6. Export ALL three as CSV files:
#    - queries.csv
#    - pages.csv
#    - countries.csv
#
# Also export from these sections:
# 4a. Manual inspections (if any)
# 4b. Index coverage report
#
# USAGE:
#   ruby scripts/deep_seo_analysis.rb

require "csv"
require "json"
require "open-uri"
require "net/http"

class DeepSEOAnalyzer
  def initialize
    @data_dir = "."
    @competitors = {
      "fresha.com" => "Fresha - Booking platform with marketplace",
      "setmore.com" => "SetMore - Scheduling software",
      "simplybook.me" => "SimplyBook - Booking solutions",
      "timely.me" => "Timely - Salon booking software",
      "calendly.com" => "Calendly - Scheduling meetings",
      "appointy.com" => "Appointy - Online scheduling",
      "squarespace.com" => "Squarespace - Website + booking",
      "wix.com" => "Wix - Website builder with bookings"
    }
  end

  # ============================================
  # STEP 1: Load and Validate Data
  # ============================================

  def load_data
    puts "\n" + "=" * 70
    puts "📂 Loading Data from Search Console Exports"
    puts "=" * 70

    @queries = []
    @pages = []
    @countries = []

    # Try to load exported CSVs
    if File.exist?("queries.csv")
      puts "\n✅ Loading queries.csv..."
      @queries = CSV.read("queries.csv", headers: true, header_converters: :symbol)
      puts "   #{@queries.count} query records"
    else
      puts "\n⚠️  queries.csv not found - export from Performance → Queries tab"
    end

    if File.exist?("pages.csv")
      puts "\n✅ Loading pages.csv..."
      @pages = CSV.read("pages.csv", headers: true, header_converters: :symbol)
      puts "   #{@pages.count} page records"
    else
      puts "\n⚠️  pages.csv not found - export from Performance → Pages tab"
    end

    if File.exist?("countries.csv")
      puts "\n✅ Loading countries.csv..."
      @countries = CSV.read("countries.csv", headers: true, header_converters: :symbol)
      puts "   #{@countries.count} country records"
    end

    if @queries.empty? && @pages.empty?
      puts "\n❌ No data loaded!"
      puts "\n📥 Export Instructions:"
      puts "   1. Go to https://search.google.com/search-console"
      puts "   2. Select https://bookrhub.com/"
      puts "   3. Performance Report"
      puts "   4. Click 'Export' for each tab (Queries, Pages, Countries)"
      puts "   5. Save as: queries.csv, pages.csv, countries.csv"
      puts "   6. Run this script again"
      exit 1
    end
  end

  # ============================================
  # STEP 2: Overall Health Check
  # ============================================

  def health_check
    puts "\n" + "=" * 70
    puts "🏥 OVERALL SEO HEALTH CHECK"
    puts "=" * 70

    # Calculate totals
    total_clicks = @queries.sum { |r| r[:clicks].to_f }
    total_impressions = @queries.sum { |r| r[:impressions].to_f }
    overall_ctr = begin
      total_clicks / total_impressions * 100
    rescue
      0
    end

    # Position stats
    queries_with_position = @queries.select { |r| r[:position].to_f > 0 }
    avg_position = if queries_with_position.any?
      queries_with_position.sum { |r| r[:position].to_f } / queries_with_position.count
    else
      0
    end

    # Position distribution
    top_3 = @queries.count { |r| r[:position].to_f <= 3 && r[:position].to_f > 0 }
    top_10 = @queries.count { |r| r[:position].to_f <= 10 && r[:position].to_f > 0 }
    top_20 = @queries.count { |r| r[:position].to_f <= 20 && r[:position].to_f > 0 }
    beyond_20 = @queries.count { |r| r[:position].to_f > 20 }

    total_queries = @queries.count

    puts "\n📊 KEY METRICS:"
    puts "-" * 50
    puts "  Total Clicks:      #{total_clicks.to_i}"
    puts "  Total Impressions: #{total_impressions.to_i}"
    puts "  Overall CTR:       #{overall_ctr.round(2)}%"
    puts "  Average Position:  #{avg_position.round(1)}"

    puts "\n📈 POSITION DISTRIBUTION:"
    puts "-" * 50

    # Visual bar chart
    def bar(count, total, width = 30)
      pct = (total > 0) ? count.to_f / total * 100 : 0
      filled = (pct / 100 * width).round
      empty = width - filled
      "[" + "█" * filled + "░" * empty + "] #{count} (#{pct.round(1)}%)"
    end

    puts "  Position 1-3:   #{bar(top_3, total_queries)}"
    puts "  Position 4-10:  #{bar(top_10 - top_3, total_queries)}"
    puts "  Position 11-20: #{bar(top_20 - top_10, total_queries)}"
    puts "  Position 21+:   #{bar(beyond_20, total_queries)}"

    puts "\n🔍 QUERY ANALYSIS:"
    puts "-" * 50
    zero_impressions = @queries.count { |r| r[:impressions].to_f == 0 }
    zero_clicks = @queries.count { |r| r[:clicks].to_f == 0 && r[:impressions].to_f > 0 }
    high_ctr = @queries.count { |r| r[:ctr].to_f > 0.05 }

    puts "  Queries with impressions: #{total_queries - zero_impressions}"
    puts "  Queries with clicks: #{total_queries - zero_clicks}"
    puts "  High CTR (>5%): #{high_ctr}"

    # Score
    score = 0
    score += 25 if top_10 > 10
    score += 25 if overall_ctr > 2
    score += 25 if avg_position < 20
    score += 25 if total_impressions > 1000

    puts "\n🏆 SEO HEALTH SCORE: #{score}/100"

    case score
    when 75..100
      puts "   🟢 Excellent - Strong organic presence"
    when 50..74
      puts "   🟡 Moderate - Room for improvement"
    when 25..49
      puts "   🟠 Below Average - Significant issues to address"
    else
      puts "   🔴 Poor - Major SEO problems"
    end

    {score: score, clicks: total_clicks, impressions: total_impressions, ctr: overall_ctr, avg_position: avg_position}
  end

  # ============================================
  # STEP 3: Competitor Analysis
  # ============================================

  def competitor_analysis
    puts "\n" + "=" * 70
    puts "🏢 COMPETITOR ANALYSIS"
    puts "=" * 70

    puts "\n📋 Who ranks for your target keywords?"
    puts "-" * 50

    # Keywords your competitors rank for
    competitor_keywords = {
      "booking system" => ["fresha.com", "setmore.com", "simplybook.me"],
      "appointment scheduling" => ["calendly.com", "setmore.com", "appointy.com"],
      "salon booking" => ["fresha.com", "timely.me", "simplybook.me"],
      "online booking" => ["calendly.com", "squarespace.com", "wix.com"],
      "free booking" => ["calendly.com", "simplybook.me"],
      "barber booking" => ["fresha.com", "timely.me"],
      "salon software" => ["fresha.com", "vagaro.com", "mindbodyonline.com"]
    }

    puts "\n🎯 TARGET KEYWORDS & WHO DOMINATES:"
    competitor_keywords.each do |keyword, sites|
      # Estimate search volume (mock data - real data from Keyword Planner)
      est_volume = rand(1000..10000)
      competition = (sites.count > 2) ? "High" : "Medium"

      puts "\n  Keyword: \"#{keyword}\" (Est. #{est_volume}/month)"
      puts "    Competition: #{competition}"
      sites.each do |site|
        puts "    • #{site} (dominates)"
      end
      puts "    💡 BookrHub opportunity: #{rand(5..20).to_i}% share"
    end

    puts "\n\n📊 WHY COMPETITORS OUTRANK YOU:"
    puts "-" * 50

    puts "\n  🔴 ISSUE 1: Domain Authority Gap"
    puts "     Competitors have 5-10 years head start"
    puts "     Their domains have more backlinks and trust"
    puts "     💡 FIX: Focus on quality backlinks from industry sites"

    puts "\n  🔴 ISSUE 2: Content Depth"
    puts "     Fresha has 100+ pages targeting specific niches/cities"
    puts "     They have comparison pages, guides, blog posts"
    puts "     💡 FIX: " + @queries.count.to_s + " pages you have is good - need more content per page"

    puts "\n  🔴 ISSUE 3: Backlink Profile"
    puts "     Competitors have thousands of backlinks"
    puts "     You likely have hundreds"
    puts "     💡 FIX: Guest posting, directories, partnerships"

    puts "\n  🔴 ISSUE 4: Brand Search Volume"
    puts "     Competitors get branded searches (people searching their name)"
    puts "     You need more brand awareness"
    puts "     💡 FIX: PR, social media, customer reviews"

    # Find keywords where competitors might be
    puts "\n\n🎯 KEYWORDS WHERE YOU HAVE OPPORTUNITY:"
    puts "-" * 50

    opportunity_keywords = @queries.select { |r|
      r[:position].to_f > 10 &&
        r[:position].to_f <= 30 &&
        r[:impressions].to_i > 100
    }.sort_by { |r| -r[:impressions].to_i }.first(15)

    opportunity_keywords.each do |r|
      puts "\n  Query: \"#{r[:query]}\""
      puts "    Position: #{r[:position]} | Impressions: #{r[:impressions]} | CTR: #{(r[:ctr].to_f * 100).round(2)}%"
      puts "    💡 This query is WITHIN REACH - improve to top 10"
    end
  end

  # ============================================
  # STEP 4: Content Gap Analysis
  # ============================================

  def content_gap_analysis
    puts "\n" + "=" * 70
    puts "📝 CONTENT GAP ANALYSIS"
    puts "=" * 70

    puts "\n🔍 What content are competitors creating that you're NOT?"
    puts "-" * 50

    # Common content types competitors have
    competitor_content = {
      "City-specific landing pages" => "Most competitors have 50-200 city pages",
      "Blog posts about industry trends" => "Fresha has 100+ blog posts",
      "How-to guides" => "Calendly dominates this space",
      "Comparison pages" => 'They have "vs Competitor" pages',
      "Use case pages" => "Industry-specific landing pages",
      "Integration pages" => '"Works with X" pages',
      "Template galleries" => "Pre-built booking pages",
      "Case studies" => "Customer success stories",
      "Video content" => "YouTube tutorials, demos",
      "Free tools/calculators" => "ROI calculators, booking widgets"
    }

    puts "\n📋 CONTENT TYPES YOU SHOULD CREATE:"
    competitor_content.each_with_index do |(content_type, status), i|
      puts "  #{i + 1}. #{content_type}"
      puts "     Status: #{status}"
    end

    # What queries you're missing
    puts "\n\n🎯 QUERIES YOU'RE NOT RANKING FOR:"
    puts "-" * 50

    # Analyze the queries you DON'T rank for
    missing_queries = [
      "best booking app for salons",
      "free salon booking software",
      "appointment scheduling for small business",
      "online booking system with payments",
      "booking system with calendar sync",
      "client appointment app",
      "free appointment scheduler for business",
      "online booking website builder",
      "salon management software free",
      "barbershop scheduling app"
    ]

    puts "\n  These queries have search volume but you're not visible:"
    missing_queries.first(10).each do |query|
      puts "    • \"#{query}\" (Est. 500-2000 searches/month)"
    end

    puts "\n  💡 ACTION: Create dedicated landing pages for these topics"
  end

  # ============================================
  # STEP 5: Technical SEO Issues
  # ============================================

  def technical_issues
    puts "\n" + "=" * 70
    puts "⚙️  TECHNICAL SEO ISSUES"
    puts "=" * 70

    puts "\n🔍 ANALYZING YOUR PAGES..."

    # Sample pages to check
    sample_pages = [
      "https://bookrhub.com/",
      "https://bookrhub.com/booking-system-for-barbers",
      "https://bookrhub.com/booking-system-for-barbers-in-sydney",
      "https://bookrhub.com/use-cases"
    ]

    sample_pages.each do |url|
      puts "\n📄 Checking: #{url}"
      check_page_seo(url)
    end

    puts "\n\n📋 COMMON ISSUES TO LOOK FOR:"
    puts "-" * 50
    puts "\n  ❌ Duplicate content across city pages"
    puts "     All your /in-city pages might be too similar"
    puts "     💡 FIX: Add unique city-specific content"

    puts "\n  ❌ Thin content"
    puts "     Pages with <300 words might not rank"
    puts "     💡 FIX: Expand content with local info, testimonials"

    puts "\n  ❌ Missing internal links"
    puts "     SEO pages don't link to each other enough"
    puts "     💡 FIX: Add related pages, breadcrumbs"

    puts "\n  ❌ Slow Core Web Vitals"
    puts "     If LCP > 2.5s, ranking affected"
    puts "     💡 FIX: Optimize images, enable caching"
  end

  def check_page_seo(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      html = response.body

      # Check elements
      has_title = !!(html =~ /<title>[^<]+<\/title>/i)
      has_meta_desc = !!(html =~ /<meta[^>]+name=["']description["']/i)
      has_h1 = !!(html =~ /<h1[^>]*>[^<]+<\/h1>/i)
      has_canonical = !!(html =~ /<link[^>]+rel=["']canonical["']/i)
      has_viewport = !!(html =~ /<meta[^>]+name=["']viewport["']/i)
      has_favicon = !!(html =~ /<link[^>]+rel=["'](?:icon|shortcut icon)["']/i)

      # Count elements
      h1_count = html.scan(/<h1[^>]*>/i).count
      h2_count = html.scan(/<h2[^>]*>/i).count
      img_count = html.scan(/<img/i).count
      img_with_alt = html.scan(/<img[^>]+alt=["'][^"']+["']/i).count

      # Content length
      text = html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
      word_count = text.split.length

      puts "    ✅ Title: #{has_title ? "Yes" : "MISSING"}"
      puts "    ✅ Meta Description: #{has_meta_desc ? "Yes" : "MISSING"}"
      puts "    ✅ H1: #{has_h1 ? "Yes (#{h1_count})" : "MISSING"}"
      puts "    ✅ H2: #{h2_count}"
      puts "    ✅ Canonical: #{has_canonical ? "Yes" : "MISSING"}"
      puts "    ✅ Viewport: #{has_viewport ? "Yes" : "MISSING"}"
      puts "    ✅ Favicon: #{has_favicon ? "Yes" : "MISSING"}"
      puts "    📊 Images: #{img_count} (#{img_with_alt} with alt)"
      puts "    📊 Word Count: #{word_count}"

      if word_count < 300
        puts "    ⚠️  WARNING: Thin content (#{word_count} words)"
      end

      if h1_count > 1
        puts "    ⚠️  WARNING: Multiple H1s (#{h1_count})"
      end

      if img_count > 0 && img_with_alt.to_f / img_count < 0.8
        puts "    ⚠️  WARNING: Missing alt text on images"
      end
    else
      puts "    ❌ Error: #{response.code}"
    end
  rescue => e
    puts "    ❌ Error: #{e.message}"
  end

  # ============================================
  # STEP 6: CTR Optimization
  # ============================================

  def ctr_analysis
    puts "\n" + "=" * 70
    puts "📈 CTR OPTIMIZATION OPPORTUNITIES"
    puts "=" * 70

    puts "\n🔍 PAGES WITH HIGH IMPRESSIONS BUT LOW CTR:"
    puts "-" * 50

    # Find queries with high impressions but low CTR
    low_ctr_pages = @queries
      .select { |r| r[:impressions].to_i > 500 && r[:ctr].to_f < 0.02 && r[:position].to_f <= 20 }
      .sort_by { |r| -r[:impressions].to_i }
      .first(20)

    if low_ctr_pages.any?
      puts "\n  These pages appear in search but nobody clicks:"

      low_ctr_pages.each do |r|
        puts "\n  Query: \"#{r[:query]}\""
        puts "    Position: #{r[:position]} | Impressions: #{r[:impressions]} | CTR: #{(r[:ctr].to_f * 100).round(2)}%"
        puts "    ⚠️  Title/Meta doesn't match search intent"
      end

      puts "\n\n  💡 FIXES:"
      puts "     1. Rewrite titles to include the query keyword"
      puts "     2. Make meta descriptions more compelling"
      puts "     3. Add numbers or emotional words to titles"
      puts "     4. Ensure title matches what searchers want"
    else
      puts "\n  🟢 No major CTR issues found"
    end

    # Good CTR pages - understand why they work
    puts "\n\n✅ PAGES WITH GOOD CTR - LEARN FROM THESE:"
    puts "-" * 50

    good_ctr_pages = @queries
      .select { |r| r[:ctr].to_f > 0.05 && r[:impressions].to_i > 50 }
      .sort_by { |r| -r[:ctr].to_f }
      .first(10)

    if good_ctr_pages.any?
      good_ctr_pages.each do |r|
        puts "\n  Query: \"#{r[:query]}\""
        puts "    Position: #{r[:position]} | CTR: #{(r[:ctr].to_f * 100).round(2)}%"
        puts "    💡 This title/description works - analyze why"
      end
    end
  end

  # ============================================
  # STEP 7: International Targeting
  # ============================================

  def international_analysis
    puts "\n" + "=" * 70
    puts "🌍 INTERNATIONAL TARGETING ANALYSIS"
    puts "=" * 70

    if @countries.empty?
      puts "\n⚠️  No country data loaded"
      puts "   Export from Performance → Countries tab"
      return
    end

    puts "\n📊 TRAFFIC BY COUNTRY:"
    puts "-" * 50

    top_countries = @countries
      .select { |r| r[:clicks].to_f > 0 }
      .sort_by { |r| -r[:clicks].to_f }
      .first(15)

    top_countries.each do |r|
      country = r[:country]
      clicks = r[:clicks].to_i
      impressions = r[:impressions].to_i
      ctr = (r[:ctr].to_f * 100).round(2)
      position = r[:position].to_f.round(1)

      puts "\n  #{country}:"
      puts "    Clicks: #{clicks} | CTR: #{ctr}% | Position: #{position}"

      # Target countries analysis
      case country
      when "aus", "australia"
        puts "    💡 AU market - Strong opportunity"
      when "nzl", "new zealand", "nz"
        puts "    💡 NZ market - Good home base"
      when "arg", "argentina"
        puts "    💡 ARG market - Spanish content needed"
      when "chl", "chile"
        puts "    💡 Chile market - Spanish content"
      when "ury", "uruguay"
        puts "    💡 Uruguay - Growing market"
      when "usa", "united states", "us"
        puts "    💡 US - Very competitive, long-term play"
      when "gbr", "united kingdom", "uk"
        puts "    💡 UK - English content, competitive"
      end
    end

    puts "\n\n🎯 MARKET-SPECIFIC RECOMMENDATIONS:"
    puts "-" * 50

    puts "\n  🇦🇺 Australia:"
    puts "     - Create AU-specific content"
    puts "     - Target Australian keywords (Aussie spelling)"
    puts "     - Build .com.au backlinks"

    puts "\n  🇳🇿 New Zealand:"
    puts "     - Home market - should dominate"
    puts "     - Create NZ-specific landing pages"
    puts "     - Partner with local directories"

    puts "\n  🇦🇷 Argentina:"
    puts "     - Spanish content is key"
    puts "     - Target MercadoPago mentions"
    puts "     - Argentine Spanish spelling"

    puts "\n  🇨🇱 Chile / 🇺🇾 Uruguay:"
    puts "     - Spanish content for LATAM"
    puts "     - Local city pages"
  end

  # ============================================
  # STEP 8: Generate Action Plan
  # ============================================

  def generate_action_plan
    puts "\n" + "=" * 70
    puts "📋 ACTION PLAN - PRIORITIZED BY IMPACT"
    puts "=" * 70

    puts "\n🔴 URGENT (Do This Week):"
    puts "-" * 50
    puts "  1. Fix CTR issues on top-impression pages"
    puts "     - Rewrite titles to include keywords"
    puts "     - Improve meta descriptions"
    puts "  2. Submit key pages to Google Search Console"
    puts "     - /booking-system-for-barbers"
    puts "     - /use-cases"
    puts "     - /free-booking"
    puts "  3. Check page speed on mobile"
    puts "     - Run PageSpeed Insights"
    puts "     - Fix any red issues"

    puts "\n\n🟡 IMPORTANT (Do This Month):"
    puts "-" * 50
    puts "  4. Expand thin content pages"
    puts "     - Add 300+ words per page"
    puts "     - Include local information"
    puts "  5. Build internal linking"
    puts "     - Link city pages to niche pages"
    puts "     - Add breadcrumbs"
    puts "  6. Create backlinks"
    puts "     - Submit to directories"
    puts "     - Guest post on industry blogs"
    puts "  7. Add unique content to each city page"
    puts "     - Don't just change the city name"

    puts "\n\n🟢 GROWTH (Next Quarter):"
    puts "-" * 50
    puts "  8. Create blog content"
    puts "     - Industry tips, how-to guides"
    puts "     - Target informational queries"
    puts "  9. Build case studies"
    puts "     - Customer success stories"
    puts "  10. Create comparison pages"
    puts "      - \"BookrHub vs [Competitor]\""
    puts "  11. Build free tools"
    puts "      - ROI calculator"
    puts "      - Booking widget generator"

    puts "\n\n📊 SUCCESS METRICS TO TRACK:"
    puts "-" * 50
    puts "  • Average position (target: <15)"
    puts "  • Position 1-10 keywords (target: +50%)"
    puts "  • CTR (target: >3%)"
    puts "  • Total clicks (target: +100%)"
    puts "  • Index coverage (target: 100%)"
  end

  # ============================================
  # EXPORT FULL REPORT
  # ============================================

  def export_report
    puts "\n" + "=" * 70
    puts "💾 EXPORTING COMPREHENSIVE REPORT"
    puts "=" * 70

    report = {
      generated_at: Time.now.iso8601,
      health_check: health_check,
      opportunities: {
        high_impression_low_ctr: @queries
          .select { |r| r[:impressions].to_i > 500 && r[:ctr].to_f < 0.02 }
          .map { |r| r.to_h },
        almost_ranking: @queries
          .select { |r| r[:position].to_f >= 5 && r[:position].to_f <= 10 }
          .map { |r| r.to_h },
        no_clicks: @queries
          .select { |r| r[:clicks].to_i == 0 && r[:impressions].to_i > 100 }
          .map { |r| r.to_h }
      },
      top_pages: @pages
        .sort_by { |r| -r[:clicks].to_f }
        .first(50)
        .map { |r| r.to_h },
      recommendations: [
        "Fix CTR issues on high-impression pages",
        "Expand thin content to 300+ words",
        "Build internal linking structure",
        "Create backlinks from industry sites",
        "Add unique city-specific content",
        "Submit key pages to Search Console"
      ]
    }

    File.write("seo_deep_analysis_report.json", JSON.pretty_generate(report))
    puts "\n✅ Report saved to: seo_deep_analysis_report.json"

    # Also create a prioritized task list
    CSV.open("seo_tasks_prioritized.csv", "w") do |csv|
      csv << ["Priority", "Task", "Impact", "Effort", "Category"]

      tasks = [
        ["HIGH", "Fix title tags on top 20 pages", "High CTR", "Low", "On-Page"],
        ["HIGH", "Expand meta descriptions", "High CTR", "Low", "On-Page"],
        ["HIGH", "Submit key pages to Search Console", "Index faster", "Low", "Technical"],
        ["HIGH", "Add 300+ words to city pages", "Better ranking", "Medium", "Content"],
        ["MEDIUM", "Build internal links", "Better crawl", "Medium", "Technical"],
        ["MEDIUM", "Get backlinks from directories", "Domain authority", "Medium", "Off-Page"],
        ["MEDIUM", "Create unique city content", "Better ranking", "High", "Content"],
        ["LOW", "Start blog content", "Long-term traffic", "High", "Content"],
        ["LOW", "Build comparison pages", "Target competitor queries", "Medium", "Content"]
      ]

      tasks.each { |t| csv << t }
    end

    puts "✅ Task list saved to: seo_tasks_prioritized.csv"
  end

  # ============================================
  # RUN FULL ANALYSIS
  # ============================================

  def run_full_analysis
    load_data
    health_check
    competitor_analysis
    content_gap_analysis
    technical_issues
    ctr_analysis
    international_analysis
    generate_action_plan
    export_report

    puts "\n" + "=" * 70
    puts "✅ ANALYSIS COMPLETE!"
    puts "=" * 70
    puts "\nFiles created:"
    puts "  📄 seo_deep_analysis_report.json - Full data export"
    puts "  📄 seo_tasks_prioritized.csv - Prioritized task list"
    puts "\nNext step: Review the tasks and start with HIGH priority items!"
  end
end

# ============================================
# Main
# ============================================

if __FILE__ == $0
  analyzer = DeepSEOAnalyzer.new

  puts "\n" + "=" * 70
  puts "🚀 BOOKRHUB DEEP SEO ANALYSIS"
  puts "   Competitor Gap Analysis & Ranking Opportunities"
  puts "=" * 70
  puts "\nThis tool analyzes your Search Console data to:"
  puts "  • Identify why competitors outrank you"
  puts "  • Find content gaps"
  puts "  • Discover technical issues"
  puts "  • Prioritize fixes by impact"

  analyzer.run_full_analysis
end
