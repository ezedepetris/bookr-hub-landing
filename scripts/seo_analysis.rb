#!/usr/bin/env ruby
# SEO Analysis Tool - Multiple APIs
#
# PageSpeed Insights API (FREE, no OAuth):
#   1. Get API key: https://console.cloud.google.com/apis/library/pagespeedonline.googleapis.com
#   2. Enable the API
#   3. Create API key: https://console.cloud.google.com/apis/credentials
#
# Usage:
#   PAGESPEED_API_KEY=your_key ruby scripts/seo_analysis.rb

require "json"
require "net/http"
require "uri"
require "csv"

class SEOAnalyzer
  PAGESPEED_API = "https://www.googleapis.com/pagespeedonline/v5/runPagespeed"

  def initialize(pagespeed_key: nil)
    @pagespeed_key = pagespeed_key || ENV["PAGESPEED_API_KEY"]
  end

  # ============================================
  # PageSpeed Insights Analysis (FREE, API Key)
  # ============================================

  def analyze_pagespeed(url)
    puts "\n" + "=" * 60
    puts "⚡ PageSpeed Analysis: #{url}"
    puts "=" * 60

    unless @pagespeed_key
      puts "\n⚠️  No PageSpeed API key set"
      puts "   Get one free at: https://console.cloud.google.com/apis/credentials"
      puts "   Enable API: https://console.cloud.google.com/apis/library/pagespeedonline.googleapis.com"
      puts "   Then run: PAGESPEED_API_KEY=your_key ruby scripts/seo_analysis.rb"
      return
    end

    uri = URI("#{PAGESPEED_API}?url=#{URI.encode_www_form_component(url)}&key=#{@pagespeed_key}")

    puts "\n🔍 Fetching PageSpeed data..."
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)

      # Extract scores
      scores = {
        performance: data.dig("lighthouseResult", "categories", "performance", "score")&.round(2) || 0,
        accessibility: data.dig("lighthouseResult", "categories", "accessibility", "score")&.round(2) || 0,
        best_practices: data.dig("lighthouseResult", "categories", "best-practices", "score")&.round(2) || 0,
        seo: data.dig("lighthouseResult", "categories", "seo", "score")&.round(2) || 0,
        pwa: data.dig("lighthouseResult", "categories", "pwa", "score")&.round(2) || 0
      }

      puts "\n📊 Scores (0-1 scale, higher is better):"
      scores.each do |metric, score|
        percentage = (score * 100).round(0)
        bar = "█" * (percentage / 5) + "░" * (20 - percentage / 5)
        color = if percentage >= 90
          "🟢"
        else
          (percentage >= 50) ? "🟡" : "🔴"
        end
        puts "  #{color} #{metric.to_s.ljust(15)} #{bar} #{percentage}%"
      end

      # Core Web Vitals
      if data["loadingExperience"]
        metrics = data.dig("loadingExperience", "metrics") || {}

        puts "\n📱 Core Web Vitals Status:"

        fcp = metrics.dig("FIRST_CONTENTFUL_PAINT", "category")
        puts "  First Contentful Paint: #{fcp || "N/A"}"

        lcp = metrics.dig("LARGEST_CONTENTFUL_PAINT_ELEMENT", "category") ||
          metrics.dig("LARGEST_CONTENTFUL_PAINT", "category")
        puts "  Largest Contentful Paint: #{lcp || "N/A"}"

        cls = metrics.dig("CUMULATIVE_LAYOUT_SHIFT", "category")
        puts "  Cumulative Layout Shift: #{cls || "N/A"}"

        fid = metrics.dig("FIRST_INPUT_DELAY", "category")
        puts "  First Input Delay: #{fid || "N/A"}"
      end

      # Recommendations
      puts "\n💡 Key Recommendations:"
      audits = data.dig("lighthouseResult", "audits") || {}

      recommendations = {
        "render-blocking-resources" => "Eliminate render-blocking resources",
        "unused-css-rules" => "Remove unused CSS",
        "unused-javascript" => "Remove unused JavaScript",
        "uses-optimized-images" => "Optimize images",
        "uses-text-compression" => "Enable text compression",
        "efficiently-encoded-images" => "Use efficient image formats",
        "server-response-time" => "Reduce server response time",
        "redirects" => "Avoid page redirects",
        "meta-viewport" => "Set viewport meta tag",
        "document-title" => "Add document title",
        "meta-description" => "Add meta description"
      }

      recommendations.each do |audit_id, recommendation|
        if audits.dig(audit_id, "score")&.to_i == 0
          puts "  ⚠️  #{recommendation}"
        end
      end

    else
      puts "\n❌ Error: #{response.code} - #{response.message}"
      puts response.body
    end
  end

  def analyze_multiple_pagespeed(urls)
    puts "\n" + "=" * 60
    puts "⚡ Batch PageSpeed Analysis"
    puts "=" * 60

    results = []

    urls.each do |url|
      puts "\n📄 Analyzing: #{url}"

      data = fetch_pagespeed_data(url)
      if data
        results << {
          url: url,
          performance: (data.dig("lighthouseResult", "categories", "performance", "score") || 0) * 100,
          seo: (data.dig("lighthouseResult", "categories", "seo", "score") || 0) * 100,
          accessibility: (data.dig("lighthouseResult", "categories", "accessibility", "score") || 0) * 100
        }
      end

      sleep 1 # Rate limiting
    end

    puts "\n\n📊 Summary Table:"
    puts "-" * 80
    puts "URL".ljust(40) + "Performance".ljust(15) + "SEO".ljust(12) + "A11y"
    puts "-" * 80

    results.sort_by { |r| r[:performance] }.each do |r|
      short_url = (r[:url].length > 38) ? r[:url][0..37] + "..." : r[:url]
      perf = r[:performance].round(0)
      perf_color = if perf >= 90
        "🟢"
      else
        (perf >= 50) ? "🟡" : "🔴"
      end
      puts "#{short_url.ljust(40)} #{perf_color}#{perf.to_s.rjust(4)}%".ljust(55) +
        "#{r[:seo].round(0).to_s.rjust(4)}%".ljust(12) + "#{r[:accessibility].round(0)}%"
    end

    results
  end

  # ============================================
  # SEO Score Calculator (No API needed)
  # ============================================

  def calculate_seo_score(html_content, url)
    puts "\n" + "=" * 60
    puts "🔍 On-Page SEO Analysis: #{url}"
    puts "=" * 60

    score = 0
    max_score = 100
    issues = []

    # Title tag
    if html_content =~ /<title>([^<]+)<\/title>/i
      title = $1
      puts "\n✅ Title: #{title}"
      score += 15
      if title.length < 30
        issues << "⚠️  Title too short (< 30 chars)"
      elsif title.length > 60
        issues << "⚠️  Title too long (> 60 chars)"
      end
    else
      issues << "❌ Missing title tag"
    end

    # Meta description
    if html_content =~ /<meta[^>]+name=["']description["'][^>]+content=["']([^"']+)["']/i
      desc = $1
      puts "✅ Meta description: #{desc[0..80]}..."
      score += 15
      if desc.length < 120
        issues << "⚠️  Meta description too short (< 120 chars)"
      end
    else
      issues << "❌ Missing meta description"
    end

    # H1 tags
    h1s = html_content.scan(/<h1[^>]*>([^<]+)<\/h1>/i)
    if h1s.any?
      puts "✅ H1 found: #{h1s.first.first}"
      score += 10
      if h1s.count > 1
        issues << "⚠️  Multiple H1 tags found (#{h1s.count})"
      end
    else
      issues << "❌ Missing H1 tag"
    end

    # Open Graph tags
    og_tags = html_content.scan(/<meta property=["']og:[^"']+["'][^>]+content=["']([^"']+)["']/i)
    if og_tags.count >= 3
      puts "✅ Open Graph tags: #{og_tags.count} found"
      score += 10
    else
      issues << "⚠️  Missing Open Graph tags"
    end

    # Canonical URL
    if html_content =~ /<link[^>]+rel=["']canonical["'][^>]+href=["']([^"']+)["']/i
      puts "✅ Canonical: #{$1}"
      score += 10
    else
      issues << "⚠️  Missing canonical URL"
    end

    # Mobile viewport
    if /<meta[^>]+name=["']viewport["']/i.match?(html_content)
      puts "✅ Mobile viewport set"
      score += 10
    else
      issues << "❌ Missing viewport meta tag"
    end

    # Images with alt
    images = html_content.scan(/<img[^>]+>/i)
    images_with_alt = html_content.scan(/<img[^>]+alt=["'][^"']+["'][^>]*>/i)
    if images.any?
      alt_percentage = (images_with_alt.count.to_f / images.count * 100).round(0)
      puts "📷 Images: #{images_with_alt.count}/#{images.count} with alt (#{alt_percentage}%)"
      score += (alt_percentage * 0.1).round(0)
      if alt_percentage < 50
        issues << "⚠️  #{images.count - images_with_alt.count} images missing alt text"
      end
    end

    # SSL/HTTPS check
    if url.start_with?("https://")
      puts "🔒 HTTPS enabled"
      score += 10
    else
      issues << "❌ Not using HTTPS"
    end

    # Favicon
    if /<link[^>]+rel=["'](?:icon|shortcut icon)["']/i.match?(html_content)
      puts "✅ Favicon found"
      score += 10
    else
      issues << "⚠️  Missing favicon"
    end

    # Score summary
    puts "\n" + "-" * 40
    puts "📊 SEO Score: #{score}/#{max_score}"

    if issues.any?
      puts "\n⚠️  Issues Found:"
      issues.each { |i| puts "  #{i}" }
    else
      puts "\n🟢 No major issues found!"
    end

    score
  end

  # ============================================
  # Content Analysis (No API needed)
  # ============================================

  def analyze_content(url)
    puts "\n" + "=" * 60
    puts "📝 Content Analysis: #{url}"
    puts "=" * 60

    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      html = response.body

      # Word count
      text = html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
      words = text.split.length
      puts "\n📊 Word count: #{words}"

      # Headings structure
      h2s = html.scan(/<h2[^>]*>([^<]+)<\/h2>/i)
      h3s = html.scan(/<h3[^>]*>([^<]+)<\/h3>/i)
      puts "📑 Headings: #{h2s.count} H2, #{h3s.count} H3"

      if h2s.any?
        puts "\n  H2 Headings:"
        h2s.first(5).each { |h| puts "    • #{$1 if h.is_a?(Array)}#{h.first}" }
      end

      # Internal/external links
      internal_links = html.scan(/href=["']https?:\/\/bookrhub\.com[^"']+["']/i).count
      external_links = html.scan(/href=["']https?:\/\/(?!bookrhub)[^"']+["']/i).count
      puts "\n🔗 Links: #{internal_links} internal, #{external_links} external"

      # Images
      images = html.scan(/<img[^>]+>/i)
      puts "📷 Images: #{images.count}"

    else
      puts "\n❌ Could not fetch page: #{response.code}"
    end
  end

  # ============================================
  # Generate SEO Audit Report
  # ============================================

  def generate_audit_report(pages)
    puts "\n" + "=" * 60
    puts "📋 SEO Audit Report"
    puts "=" * 60

    CSV.open("seo_audit_report.csv", "w") do |csv|
      csv << ["URL", "HTTPS", "Title", "Title Length", "Meta Desc", "Meta Desc Length",
        "H1 Count", "H2 Count", "Images", "Images with Alt", "Has Favicon",
        "Has Canonical", "Has Viewport", "OG Tags"]

      pages.each do |url|
        puts "\n📄 Analyzing: #{url}"

        begin
          uri = URI(url)
          response = Net::HTTP.get_response(uri)

          if response.is_a?(Net::HTTPSuccess)
            html = response.body

            row = {
              "URL" => url,
              "HTTPS" => url.start_with?("https://"),
              "Title" => (html[/<title>([^<]+)<\/title>/i, 1] || "")[],
              "Title Length" => (html[/<title>([^<]+)<\/title>/i, 1] || "").length,
              "Meta Desc" => (html[/<meta[^>]+name=["']description["'][^>]+content=["']([^"']+)["']/i, 1] || "")[0..100],
              "Meta Desc Length" => (html[/<meta[^>]+name=["']description["'][^>]+content=["']([^"']+)["']/i, 1] || "").length,
              "H1 Count" => html.scan(/<h1[^>]*>/i).count,
              "H2 Count" => html.scan(/<h2[^>]*>/i).count,
              "Images" => html.scan(/<img[^>]+>/i).count,
              "Images with Alt" => html.scan(/<img[^>]+alt=["'][^"']+["'][^>]*>/i).count,
              "Has Favicon" => !!(html =~ /<link[^>]+rel=["'](?:icon|shortcut icon)["']/i),
              "Has Canonical" => !!(html =~ /<link[^>]+rel=["']canonical["']/i),
              "Has Viewport" => !!(html =~ /<meta[^>]+name=["']viewport["']/i),
              "OG Tags" => html.scan(/<meta property=["']og:[^"']+["']/i).count
            }

            csv << row.values
            puts "  ✅ Score calculable"
          else
            csv << [url, "ERROR", response.code]
            puts "  ❌ #{response.code}"
          end
        rescue => e
          csv << [url, "ERROR", e.message]
          puts "  ❌ #{e.message}"
        end

        sleep 0.5 # Rate limiting
      end
    end

    puts "\n✅ Report saved to seo_audit_report.csv"
  end

  private

  def fetch_pagespeed_data(url)
    return nil unless @pagespeed_key

    uri = URI("#{PAGESPEED_API}?url=#{URI.encode_www_form_component(url)}&key=#{@pagespeed_key}")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end
end

# ============================================
# Main Execution
# ============================================

if __FILE__ == $0
  analyzer = SEOAnalyzer.new(pagespeed_key: ENV["PAGESPEED_API_KEY"])

  puts "\n" + "=" * 60
  puts "🚀 BookrHub SEO Analysis Tool"
  puts "=" * 60
  puts "\nOptions:"
  puts "1. PageSpeed analysis (free API key needed)"
  puts "2. On-page SEO audit (no API needed)"
  puts "3. Batch PageSpeed analysis"
  puts "4. Generate full audit CSV report"
  puts "5. Analyze single URL"
  print "\nEnter choice: "

  choice = STDIN.gets.chomp

  case choice
  when "1"
    analyzer.analyze_pagespeed("https://bookrhub.com/")

  when "2"
    require "net/http"
    url = "https://bookrhub.com/"
    uri = URI(url)
    html = Net::HTTP.get_response(uri).body
    analyzer.calculate_seo_score(html, url)

  when "3"
    urls = [
      "https://bookrhub.com/",
      "https://bookrhub.com/booking-system-for-barbers",
      "https://bookrhub.com/booking-system-for-barbers-in-sydney",
      "https://bookrhub.com/use-cases",
      "https://bookrhub.com/free-booking"
    ]
    analyzer.analyze_multiple_pagespeed(urls)

  when "4"
    urls = [
      "https://bookrhub.com/",
      "https://bookrhub.com/booking-system-for-barbers",
      "https://bookrhub.com/booking-system-for-barbers-in-sydney",
      "https://bookrhub.com/use-cases",
      "https://bookrhub.com/free-booking",
      "https://bookrhub.com/why-bookrhub"
    ]
    analyzer.generate_audit_report(urls)

  when "5"
    print "Enter URL: "
    url = STDIN.gets.chomp
    require "net/http"
    uri = URI(url)
    html = Net::HTTP.get_response(uri).body
    analyzer.calculate_seo_score(html, url)
    puts "\n"
    analyzer.analyze_pagespeed(url)

  else
    puts "Invalid choice"
  end
end
