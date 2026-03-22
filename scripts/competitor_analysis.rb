#!/usr/bin/env ruby
# SEO Comparison Report Generator
# Analyzes why competitors rank better and what to do

require "json"

class SEOComparisonReport
  def initialize
    @competitors = {
      "fresha" => {
        domain: "fresha.com",
        strengths: [
          "5+ years old domain with high DA",
          "1000+ pages indexed",
          "Marketplace model (high traffic)",
          "Strong brand search volume",
          "Active content strategy (blog)",
          "200+ city/location pages",
          "Strong social proof (app store reviews)"
        ],
        weaknesses: [
          "Charges 5-20% commission",
          "Complex interface",
          "Limited free plan",
          "Payment processing issues reported"
        ],
        estimated_traffic: "2M+ monthly"
      },
      "setmore" => {
        domain: "setmore.com",
        strengths: [
          "Established domain (10+ years)",
          "Simple booking interface",
          "Calendar integrations",
          "Mobile app"
        ],
        weaknesses: [
          "Pricing ($15+/month)",
          "Limited free features",
          "Less feature-rich",
          "Fewer customization options"
        ],
        estimated_traffic: "500K+ monthly"
      },
      "calendly" => {
        domain: "calendly.com",
        strengths: [
          "Massive brand awareness",
          "Huge content/backlinks",
          "Enterprise customers",
          "Calendar-first approach"
        ],
        weaknesses: [
          "Not designed for service businesses",
          "No client management",
          "Meeting-focused, not appointments",
          "Expensive for teams"
        ],
        estimated_traffic: "5M+ monthly"
      },
      "simplybook" => {
        domain: "simplybook.me",
        strengths: [
          "Good for small businesses",
          "Website widget option",
          "Multiple languages"
        ],
        weaknesses: [
          "Outdated UI",
          "Limited marketing features",
          "Smaller team than competitors",
          "Less known brand"
        ],
        estimated_traffic: "300K+ monthly"
      }
    }

    @your_strengths = [
      "✅ FREE (no commission)",
      "✅ Simple, modern interface",
      "✅ Designed for service businesses",
      "✅ Growing backlink profile",
      "✅ City-specific pages created",
      "✅ Multi-language support (EN/ES)",
      "✅ Niche-specific content"
    ]

    @your_weaknesses = [
      "❌ New domain (less trust)",
      "❌ Limited backlinks",
      "❌ Low brand search volume",
      "❌ No blog content yet",
      "❌ Limited backlinks",
      "❌ No case studies/testimonials"
    ]
  end

  def generate_report
    puts "
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║     🔍 BOOKRHUB SEO COMPETITIVE ANALYSIS                                    ║
║     Why You're Not Ranking & How to Fix It                                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"

    puts "\n📊 THE RANKING FACTORS - WHY COMPETITORS OUTRANK YOU"
    puts "=" * 78
    puts "
Google ranks pages based on:

┌─────────────────────────────────────────────────────────────────────────────┐
│ FACTOR              │ YOUR SITE        │ COMPETITORS      │ PRIORITY       │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. Domain Authority │ Low (new)       │ High (old)       │ ⭐⭐⭐ CRITICAL │
│ 2. Backlinks        │ Few (~100)       │ Thousands         │ ⭐⭐⭐ CRITICAL │
│ 3. Content Quality   │ Good             │ Extensive         │ ⭐⭐ HIGH      │
│ 4. Content Quantity │ 2,000+ pages    │ 10,000+ pages    │ ⭐⭐ HIGH      │
│ 5. Brand Searches   │ Low              │ High              │ ⭐⭐ HIGH      │
│ 6. Technical SEO    │ Good             │ Good              │ ⭐ MEDIUM      │
│ 7. User Signals     │ Unknown          │ Good              │ ⭐ MEDIUM      │
└─────────────────────────────────────────────────────────────────────────────┘

💡 KEY INSIGHT: You have good content but lack authority signals.
   Focus on backlinks AND brand awareness first.
"

    puts "\n\n🏢 COMPETITOR ANALYSIS"
    puts "=" * 78

    @competitors.each do |name, data|
      puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│ #{name.upcase.ljust(76)}│
├─────────────────────────────────────────────────────────────────────────────┤
│ Domain: #{data[:domain].ljust(68)}│
│ Est. Traffic: #{data[:estimated_traffic].ljust(62)}│
├─────────────────────────────────────────────────────────────────────────────┤
│ STRENGTHS:                                                                    │
"

      data[:strengths].each do |s|
        puts "│   • #{s.ljust(73)}│"
      end

      puts "|                                                                             │
│ WEAKNESSES TO EXPLOIT:                                                       │"

      data[:weaknesses].each do |w|
        puts "│   ⚠️  #{w.ljust(71)}│"
      end

      puts "└─────────────────────────────────────────────────────────────────────────────┘
"
    end

    puts "\n\n📈 WHERE YOU HAVE ADVANTAGES"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│  YOUR STRENGTHS (use these in content)                                     │
├─────────────────────────────────────────────────────────────────────────────┤"

    @your_strengths.each do |s|
      puts "│  #{s.ljust(74)}│"
    end

    puts "└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  YOUR WEAKNESSES (address these)                                          │
├─────────────────────────────────────────────────────────────────────────────┤"

    @your_weaknesses.each do |w|
      puts "│  #{w.ljust(74)}│"
    end

    puts "└─────────────────────────────────────────────────────────────────────────────┘
"

    puts "\n\n🎯 TOP 10 ACTIONS TO OUTRANK COMPETITORS"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│ #   ACTION                                         │ TIME   │ IMPACT        │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1   Submit key pages to Google Search Console      │ 30min  │ ⭐⭐⭐         │
│ 2   Get 50+ backlinks from industry directories    │ 2 weeks│ ⭐⭐⭐         │
│ 3   Add testimonials/reviews section to pages      │ 1 hour │ ⭐⭐⭐         │
│ 4   Expand content to 500+ words per page        │ 1 week │ ⭐⭐           │
│ 5   Create blog (2 posts/week targeting queries)   │ Ongoing│ ⭐⭐           │
│ 6   Add city-specific testimonials/case studies   │ 2 weeks│ ⭐⭐           │
│ 7   Build partnerships with local business groups│ 1 month│ ⭐⭐           │
│ 8   Get listed on directories (yelp, foursquare) │ 1 week │ ⭐             │
│ 9   Create comparison landing pages               │ 1 week │ ⭐             │
│ 10  PR outreach for guest posts                  │ Ongoing│ ⭐             │
└─────────────────────────────────────────────────────────────────────────────┘
"

    puts "\n\n💰 QUICK WINS (Do These First)"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. FIX PAGE TITLES FOR TOP QUERIES                                         │
│    ─────────────────────────────────────────────────────                   │
│    Your pages might rank but have low CTR. Check:                          │
│    • Are keywords in the title?                                            │
│    • Is the title compelling?                                              │
│    • Does it match search intent?                                          │
│                                                                             │
│    Example:                                                                 │
│    BAD:  \"BookrHub - Free Booking System\"                               │
│    GOOD: \"Free Booking System for Salons | No Commission\"                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ 2. ADD SOCIAL PROOF                                                        │
│    ───────────────────────                                                │
│    Add to every page:                                                       │
│    • \"Trusted by X businesses\"                                             │
│    • Star ratings (if you have them)                                       │
│    • Number of bookings completed                                           │
│    • Customer logos                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ 3. IMPROVE META DESCRIPTIONS                                              │
│    ───────────────────────────                                            │
│    Include:                                                                │
│    • Primary keyword                                                       │
│    • Value proposition                                                      │
│    • Call to action                                                        │
│                                                                             │
│    150-160 characters, compelling copy                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 4. ADD FAQ SECTION TO PAGES                                                │
│    ─────────────────────────                                             │
│    Google loves FAQ sections:                                               │
│    • Add 5-7 common questions                                               │
│    • Include keywords in questions                                          │
│    • Answer concisely                                                      │
│    • Schema markup for rich snippets                                       │
└─────────────────────────────────────────────────────────────────────────────┘
"

    puts "\n\n📋 COMPETITOR KEYWORDS TO TARGET"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│  QUERY                            │ COMPETITOR │ SEARCH INTENT│ YOUR CHANCE │
├─────────────────────────────────────────────────────────────────────────────┤
│  \"free booking system\"           │ Fresha     │ Comparison  │ ⭐⭐⭐     │
│  \"appointment scheduler\"         │ Calendly   │ Product     │ ⭐⭐⭐     │
│  \"online booking for salons\"      │ Fresha     │ Product     │ ⭐⭐⭐     │
│  \"booking app for barbers\"       │ Timely     │ Product     │ ⭐⭐       │
│  \"no commission booking\"          │ -          │ Product     │ ⭐⭐⭐⭐    │
│  \"best booking system 2026\"       │ Various    │ Informational│ ⭐⭐     │
│  \"free salon booking software\"    │ SimplyBook │ Product     │ ⭐⭐⭐⭐    │
│  \"appointment reminders\"          │ Various    │ Feature     │ ⭐⭐⭐⭐    │
└─────────────────────────────────────────────────────────────────────────────┘

💡 OPPORTUNITY: Queries with NO dominant competitor = your ranking chance is HIGH
"

    puts "\n\n📊 EXPECTED TIMELINE TO RESULTS"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│  PHASE      │ ACTIONS                              │ TIMELINE │ METRICS   │
├─────────────────────────────────────────────────────────────────────────────┤
│  WEEK 1-2   │ Fix titles, meta, submit to GSC      │ Week 1   │ CTR ↑     │
│             │ Add FAQ sections                      │ Week 2   │ Impress ↑ │
├─────────────────────────────────────────────────────────────────────────────┤
│  MONTH 1    │ Build 20+ backlinks                  │ Month 1  │ Pos ↑5-10 │
│             │ Expand content                        │ Month 1  │ Traffic ↑ │
├─────────────────────────────────────────────────────────────────────────────┤
│  MONTH 2-3  │ Blog content, partnerships          │ Month 2-3│ Brand ↑   │
│             │ Directory listings                    │ Month 2-3│ Backlinks ↑│
├─────────────────────────────────────────────────────────────────────────────┤
│  MONTH 6    │ Case studies, PR                     │ Month 6  │ DA ↑      │
│             │ Guest posts                          │ Month 6  │ Rankings ↑│
└─────────────────────────────────────────────────────────────────────────────┘
"

    puts "\n\n🚀 NEXT STEPS"
    puts "=" * 78
    puts "
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  1. Export your Search Console data:                                       │
│     https://search.google.com/search-console → Performance → Export        │
│                                                                             │
│  2. Run the deep analysis:                                                  │
│     ruby scripts/deep_seo_analysis.rb                                       │
│                                                                             │
│  3. Implement the high-priority fixes this week                            │
│                                                                             │
│  4. Track your progress monthly                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
"

    puts "\n\n✅ ANALYSIS COMPLETE!"
    puts "=" * 78
  end

  def export_to_file
    report = {
      competitors: @competitors,
      your_strengths: @your_strengths,
      your_weaknesses: @your_weaknesses,
      top_actions: [
        "Submit key pages to Google Search Console",
        "Get 50+ backlinks from industry directories",
        "Add testimonials/reviews to pages",
        "Expand content to 500+ words per page",
        "Create blog content targeting keywords",
        "Add city-specific testimonials",
        "Build partnerships with local business groups",
        "Get listed on directories",
        "Create comparison landing pages",
        "PR outreach for guest posts"
      ],
      target_keywords: [
        "free booking system",
        "no commission booking",
        "free salon booking software",
        "appointment reminders",
        "online booking for salons",
        "booking app for barbers",
        "appointment scheduler"
      ]
    }

    File.write("competitor_analysis.json", JSON.pretty_generate(report))
    puts "\n💾 Competitor analysis saved to: competitor_analysis.json"
  end
end

if __FILE__ == $0
  report = SEOComparisonReport.new
  report.generate_report
  report.export_to_file
end
