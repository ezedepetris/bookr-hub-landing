#!/usr/bin/env ruby
# Google Search Console SEO Analyzer
#
# Setup:
# 1. Install dependencies: gem install google-apis-searchconsole googleauth oauth2
# 2. Create OAuth credentials at https://console.cloud.google.com/
# 3. Run this script and authorize in your browser
#
# Usage:
#   ruby scripts/search_console_analyzer.rb

require "json"

# Install gems if missing
begin
  require "google/apis/searchconsole_v1"
  require "googleauth"
  require "googleauth/stores/file_token_store"
rescue LoadError
  puts "Installing required gems..."
  system("gem install google-apis-searchconsole googleauth oauth2")
  require "google/apis/searchconsole_v1"
  require "googleauth"
  require "googleauth/stores/file_token_store"
end

class SearchConsoleAnalyzer
  SCOPE = Google::Apis::SearchconsoleV1::AUTH_SCOPES
  APPLICATION_NAME = "BookrHub SEO Analyzer"
  CREDENTIALS_PATH = "config/google_credentials.json"
  TOKEN_STORE_PATH = ".searchconsole_token.yaml"

  def initialize
    @service = Google::Apis::SearchconsoleV1::SearchConsoleService.new
    @service.client_options.application_name = APPLICATION_NAME
  end

  def authorize!
    puts "\n" + "=" * 60
    puts "🔐 Google Search Console Authorization"
    puts "=" * 60

    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_STORE_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

    # Check for existing token
    if File.exist?(TOKEN_STORE_PATH)
      puts "✅ Found existing token"
    else
      puts "\n📋 Authorization required!"
      puts "1. Open this URL in your browser:"
      puts authorizer.get_authorization_url(base_url: "http://localhost:8080")
      puts "\n2. Copy the authorization code from the URL"
      print "\n3. Paste the code here: "
      code = STDIN.gets.chomp
      authorizer.get_and_store_credentials_from_code(
        user_id: "default",
        code: code,
        base_url: "http://localhost:8080"
      )
      puts "✅ Token saved!"
    end

    @service.authorization = authorizer.get_credentials(user_id: "default")
    puts "\n✅ Authorized successfully!"
  end

  def analyze_unindexed_pages!
    puts "\n" + "=" * 60
    puts "📊 Analyzing Indexing Status"
    puts "=" * 60

    # Get the list of pages from sitemap
    sitemap_url = "https://bookrhub.com/sitemap.xml"
    puts "\nFetching sitemap..."

    # Try to get pages from API
    begin
      response = @service.list_urlcrawlerrors_samples(
        "https://bookrhub.com/",
        category: "not_found"
      )

      puts "\n🚫 Pages with 404 Errors (Not Found):"
      if response.url_crawl_errors
        response.url_crawl_errors.first(20).each do |error|
          puts "  - #{error.url}"
        end
        puts "  ... and #{response.url_crawl_errors.count - 20} more" if response.url_crawl_errors.count > 20
      else
        puts "  No 404 errors found"
      end
    rescue => e
      puts "⚠️  Could not fetch crawl errors: #{e.message}"
      puts "   (You may need to grant full site access in Search Console)"
    end
  end

  def analyze_performance!(days: 28)
    puts "\n" + "=" * 60
    puts "📈 Search Performance Analysis (#{days} days)"
    puts "=" * 60

    end_date = Date.today
    start_date = end_date - days

    response = @service.query_search_analytics(
      "https://bookrhub.com/",
      {
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        dimensions: ["query"],
        row_limit: 50
      }
    )

    if response.rows
      puts "\n🔍 Top Search Queries:"
      puts "-" * 60
      response.rows.first(25).each do |row|
        clicks = row.clicks.to_i
        impressions = row.impressions.to_i
        ctr = (row.ctr * 100).round(2)
        position = row.position.round(1)
        query = row.keys.first

        puts "#{query}"
        puts "  Clicks: #{clicks} | Impressions: #{impressions} | CTR: #{ctr}% | Position: #{position}"
        puts
      end

      # Summary stats
      total_clicks = response.rows.sum { |r| r.clicks }
      total_impressions = response.rows.sum { |r| r.impressions }
      avg_ctr = begin
        response.rows.map { |r| r.ctr * r.clicks }.sum / total_clicks * 100
      rescue
        0
      end
      avg_position = begin
        response.rows.map { |r| r.position * r.clicks }.sum / total_clicks
      rescue
        0
      end

      puts "-" * 60
      puts "📊 Summary:"
      puts "  Total Clicks: #{total_clicks.to_i}"
      puts "  Total Impressions: #{total_impressions.to_i}"
      puts "  Average CTR: #{avg_ctr.round(2)}%"
      puts "  Average Position: #{avg_position.round(1)}"
    else
      puts "  No data available for this period"
      puts "  (Data may take 2-3 days to appear for new pages)"
    end
  end

  def analyze_page_performance!(days: 28)
    puts "\n" + "=" * 60
    puts "📄 Page Performance Analysis"
    puts "=" * 60

    end_date = Date.today
    start_date = end_date - days

    response = @service.query_search_analytics(
      "https://bookrhub.com/",
      {
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        dimensions: ["page"],
        row_limit: 50
      }
    )

    if response.rows
      puts "\n📑 Top Performing Pages:"
      puts "-" * 60
      response.rows.first(20).each do |row|
        page = row.keys.first
        clicks = row.clicks.to_i
        impressions = row.impressions.to_i
        ctr = (row.ctr * 100).round(2)
        position = row.position.round(1)

        # Shorten page URL for display
        short_page = page.gsub("https://bookrhub.com", "")
        short_page = (short_page.length > 50) ? short_page[0..47] + "..." : short_page

        puts "#{short_page}"
        puts "  Clicks: #{clicks} | Impressions: #{impressions} | CTR: #{ctr}% | Avg Pos: #{position}"
        puts
      end
    else
      puts "  No page data available"
    end
  end

  def analyze_seo_opportunities!(days: 28)
    puts "\n" + "=" * 60
    puts "🎯 SEO Opportunities & Recommendations"
    puts "=" * 60

    end_date = Date.today
    start_date = end_date - days

    # Get queries with high impressions but low CTR
    response = @service.query_search_analytics(
      "https://bookrhub.com/",
      {
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        dimensions: ["query"],
        row_limit: 100
      }
    )

    if response.rows
      opportunities = []
      response.rows.each do |row|
        clicks = row.clicks.to_i
        impressions = row.impressions.to_i
        ctr = row.ctr
        position = row.position

        # High impressions, low CTR = opportunity
        if impressions > 100 && ctr < 0.05 && position > 10
          opportunities << {
            query: row.keys.first,
            impressions: impressions,
            ctr: ctr,
            position: position,
            clicks: clicks
          }
        end

        # Good position but few clicks = title/desc issue
        if position <= 10 && clicks < 10 && impressions > 50
          opportunities << {
            query: row.keys.first,
            impressions: impressions,
            ctr: ctr,
            position: position,
            clicks: clicks,
            issue: "low_clicks_despite_position"
          }
        end
      end

      puts "\n🚨 High Impressions, Low CTR (Title/Meta issues):"
      puts "-" * 60
      high_imp_low_ctr = opportunities.select { |o| o[:impressions] > 500 && o[:ctr] < 0.03 }
      high_imp_low_ctr.first(10).each do |opp|
        puts "\n  Query: \"#{opp[:query]}\""
        puts "  Position: #{opp[:position].round(1)} | CTR: #{(opp[:ctr] * 100).round(2)}% | Impressions: #{opp[:impressions]}"
        puts "  💡 Fix: Improve title and meta description to increase clicks"
      end

      puts "\n\n📈 Position 5-10 (Almost Ranking):"
      puts "-" * 60
      almost_ranking = response.rows.select { |r| r.position >= 5 && r.position <= 10 && r.clicks < 5 }
      almost_ranking.first(10).each do |row|
        puts "\n  Query: \"#{row.keys.first}\""
        puts "  Position: #{row.position.round(1)} | Clicks: #{row.clicks} | Impressions: #{row.impressions}"
        puts "  💡 Fix: Build more backlinks or improve content"
      end

      puts "\n\n❓ Queries Bringing Traffic But Not Converting:"
      puts "-" * 60
      not_converting = response.rows.select { |r| r.clicks > 20 && r.ctr < 0.02 }
      not_converting.first(10).each do |row|
        puts "\n  Query: \"#{row.keys.first}\""
        puts "  Clicks: #{row.clicks} | CTR: #{(row.ctr * 100).round(2)}%"
        puts "  💡 Fix: Review if page content matches search intent"
      end
    end
  end

  def export_data!(days: 28)
    puts "\n" + "=" * 60
    puts "💾 Exporting Data to JSON"
    puts "=" * 60

    end_date = Date.today
    start_date = end_date - days

    # Query all data
    response = @service.query_search_analytics(
      "https://bookrhub.com/",
      {
        start_date: start_date.to_s,
        end_date: end_date.to_s,
        dimensions: ["query", "page"],
        row_limit: 1000
      }
    )

    data = {
      exported_at: Time.now.iso8601,
      period: "#{start_date} to #{end_date}",
      queries: response.rows&.map { |row|
        {
          query: row.keys[0],
          page: row.keys[1],
          clicks: row.clicks,
          impressions: row.impressions,
          ctr: row.ctr,
          position: row.position
        }
      } || []
    }

    File.write("seo_analysis_export.json", JSON.pretty_generate(data))
    puts "✅ Data exported to seo_analysis_export.json"
    puts "   #{data[:queries].count} query records"
  end
end

# Main execution
if __FILE__ == $0
  puts "\n" + "=" * 60
  puts "🚀 BookrHub SEO Analyzer"
  puts "=" * 60
  puts "\nThis tool will help you analyze:"
  puts "  • Pages not indexed by Google"
  puts "  • Search performance (clicks, impressions, CTR)"
  puts "  • Top queries bringing traffic"
  puts "  • SEO opportunities and recommendations"
  puts "\n"

  analyzer = SearchConsoleAnalyzer.new

  begin
    analyzer.authorize!

    puts "\n\nWhat would you like to analyze?"
    puts "1. Full analysis (all reports)"
    puts "2. Indexing status only"
    puts "3. Performance only"
    puts "4. SEO opportunities only"
    puts "5. Export data to JSON"
    print "\nEnter choice (1-5): "

    choice = STDIN.gets.chomp

    case choice
    when "1"
      analyzer.analyze_unindexed_pages!
      analyzer.analyze_performance!
      analyzer.analyze_page_performance!
      analyzer.analyze_seo_opportunities!
    when "2"
      analyzer.analyze_unindexed_pages!
    when "3"
      analyzer.analyze_performance!
      analyzer.analyze_page_performance!
    when "4"
      analyzer.analyze_seo_opportunities!
    when "5"
      analyzer.export_data!
    end

    puts "\n" + "=" * 60
    puts "✅ Analysis complete!"
    puts "=" * 60
  rescue Errno::ENOENT => e
    puts "\n❌ Error: #{e.message}"
    puts "\n📋 Setup Required:"
    puts "1. Create OAuth credentials at:"
    puts "   https://console.cloud.google.com/apis/credentials"
    puts "2. Download the JSON file and save it as:"
    puts "   config/google_credentials.json"
    puts "3. Enable the Search Console API at:"
    puts "   https://console.cloud.google.com/apis/library/searchconsole.googleapis.com"
    puts "\nFor detailed setup instructions, see:"
    puts "https://developers.google.com/webmaster-tools/search-console-api-original"
  rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError => e
    puts "\n❌ API Error: #{e.message}"
    puts "\nMake sure you have:"
    puts "  • Authorized access to the Search Console property"
    puts "• Verified ownership of bookrhub.com in Search Console"
  end
end
