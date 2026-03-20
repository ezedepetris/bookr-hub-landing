#!/usr/bin/env ruby
# SEO Page Generator for BookrHub
# Generates all static HTML pages for SEO

require "fileutils"
require_relative "seo_config"
require_relative "seo_templates"

class SEOPageGenerator
  BASE_DIR = File.expand_path("../../../public/seo", __FILE__)

  def initialize
    FileUtils.mkdir_p(BASE_DIR)
    FileUtils.mkdir_p("#{BASE_DIR}/en")
    FileUtils.mkdir_p("#{BASE_DIR}/es")

    @generated_pages = []
    @errors = []
  end

  def generate_all
    puts "🚀 Starting SEO page generation..."
    puts "=" * 50

    puts "\n📄 Generating niche landing pages..."
    generate_niche_pages

    puts "\n📄 Generating how-to pages..."
    generate_howto_pages

    puts "\n📄 Generating comparison pages..."
    generate_comparison_pages

    puts "\n📄 Generating general SEO pages..."
    generate_general_pages

    puts "\n📄 Generating city pages..."
    generate_city_pages

    puts "\n" + "=" * 50
    puts "✅ Generation complete!"
    puts "📊 Total pages generated: #{@generated_pages.count}"
    puts "❌ Errors: #{@errors.count}"

    save_sitemap_urls
  end

  def generate_niche_pages
    # English niche pages
    SEOConfig::NICHES.each do |niche_key, niche_data|
      page_data = SEOTemplates.niche_page_en(niche_key: niche_key, niche_data: niche_data)
      output_path = "#{BASE_DIR}/en/booking-system-for-#{niche_key}.html"
      generate_html_page(
        path: output_path,
        locale: "en",
        **page_data
      )
      @generated_pages << "/en/booking-system-for-#{niche_key}"
    end

    # Spanish niche pages
    SEOConfig::NICHES.each do |niche_key, niche_data|
      page_data = SEOTemplates.niche_page_es(niche_key: niche_key, niche_data: niche_data)
      output_path = "#{BASE_DIR}/es/sistema-de-turnos-para-#{niche_key}.html"
      generate_html_page(
        path: output_path,
        locale: "es",
        **page_data
      )
      @generated_pages << "/es/sistema-de-turnos-para-#{niche_key}"
    end

    puts "   ✅ Generated #{SEOConfig::NICHES.count * 2} niche pages"
  end

  def generate_howto_pages
    # English how-to pages
    SEOConfig::HOW_TO_EN.each do |page_data|
      full_data = SEOTemplates.howto_page(data: page_data, locale: "en")
      output_path = "#{BASE_DIR}/en/#{page_data[:slug]}.html"
      generate_html_page(
        path: output_path,
        locale: "en",
        **full_data
      )
      @generated_pages << "/en/#{page_data[:slug]}"
    end

    # Spanish how-to pages
    SEOConfig::HOW_TO_ES.each do |page_data|
      full_data = SEOTemplates.howto_page(data: page_data, locale: "es")
      output_path = "#{BASE_DIR}/es/#{page_data[:slug]}.html"
      generate_html_page(
        path: output_path,
        locale: "es",
        **full_data
      )
      @generated_pages << "/es/#{page_data[:slug]}"
    end

    puts "   ✅ Generated #{SEOConfig::HOW_TO_EN.count + SEOConfig::HOW_TO_ES.count} how-to pages"
  end

  def generate_comparison_pages
    # Both languages share the same competitor slugs
    SEOConfig::COMPETITORS.each do |competitor_key, competitor_data|
      # English version
      page_data = SEOTemplates.comparison_page(
        competitor_key: competitor_key,
        competitor_data: competitor_data,
        locale: "en"
      )
      output_path = "#{BASE_DIR}/en/vs-#{competitor_key}.html"
      generate_html_page(
        path: output_path,
        locale: "en",
        **page_data
      )
      @generated_pages << "/en/vs-#{competitor_key}"

      # Spanish version
      page_data = SEOTemplates.comparison_page(
        competitor_key: competitor_key,
        competitor_data: competitor_data,
        locale: "es"
      )
      output_path = "#{BASE_DIR}/es/vs-#{competitor_key}.html"
      generate_html_page(
        path: output_path,
        locale: "es",
        **page_data
      )
      @generated_pages << "/es/vs-#{competitor_key}"
    end

    puts "   ✅ Generated #{SEOConfig::COMPETITORS.count * 2} comparison pages"
  end

  def generate_general_pages
    # English general pages
    SEOConfig::GENERAL_PAGES_EN.each do |page_data|
      full_data = SEOTemplates.general_page_en(page_data)
      output_path = "#{BASE_DIR}/en/#{page_data[:slug]}.html"
      generate_html_page(
        path: output_path,
        locale: "en",
        **full_data
      )
      @generated_pages << "/en/#{page_data[:slug]}"
    end

    # Spanish general pages
    SEOConfig::GENERAL_PAGES_ES.each do |page_data|
      full_data = SEOTemplates.general_page_es(page_data)
      output_path = "#{BASE_DIR}/es/#{page_data[:slug]}.html"
      generate_html_page(
        path: output_path,
        locale: "es",
        **full_data
      )
      @generated_pages << "/es/#{page_data[:slug]}"
    end

    puts "   ✅ Generated #{SEOConfig::GENERAL_PAGES_EN.count} EN + #{SEOConfig::GENERAL_PAGES_ES.count} ES general pages"
  end

  def generate_city_pages
    total_city_pages = 0

    SEOConfig::CITIES.each do |country_key, country_data|
      # Generate BOTH English and Spanish pages for all cities
      # English for international visitors searching for booking in that city
      # Spanish for local LATAM audience

      country_data[:cities].each do |city|
        SEOConfig::NICHES.each do |niche_key, niche_data|
          # English page
          page_data_en = SEOTemplates.city_page_en(
            niche_key: niche_key,
            niche_data: niche_data,
            city_data: city,
            country_data: country_data
          )
          output_path_en = "#{BASE_DIR}/en/booking-system-for-#{niche_key}-in-#{city[:slug]}.html"
          generate_html_page(
            path: output_path_en,
            locale: "en",
            **page_data_en
          )
          @generated_pages << "/en/booking-system-for-#{niche_key}-in-#{city[:slug]}"
          total_city_pages += 1

          # Spanish page (for LATAM cities)
          page_data_es = SEOTemplates.city_page_es(
            niche_key: niche_key,
            niche_data: niche_data,
            city_data: city,
            country_data: country_data
          )
          output_path_es = "#{BASE_DIR}/es/sistema-de-turnos-para-#{niche_key}-en-#{city[:slug]}.html"
          generate_html_page(
            path: output_path_es,
            locale: "es",
            **page_data_es
          )
          @generated_pages << "/es/sistema-de-turnos-para-#{niche_key}-en-#{city[:slug]}"
          total_city_pages += 1
        end
      end

      puts "   ✅ Generated #{country_data[:cities].count} cities × #{SEOConfig::NICHES.count} niches × 2 languages = #{country_data[:cities].count * SEOConfig::NICHES.count * 2} pages for #{country_data[:name]}"
    end

    puts "   ✅ Total city pages: #{total_city_pages}"
  end

  def generate_html_page(path:, locale:, title:, description:, h1:, content:, canonical:, schema:)
    page_html = build_full_html(
      locale: locale,
      title: title,
      description: description,
      h1: h1,
      content: content,
      canonical: canonical,
      schema: schema
    )

    begin
      File.write(path, page_html)
    rescue => e
      @errors << {path: path, error: e.message}
      puts "   ❌ Error generating #{path}: #{e.message}"
    end
  end

  def build_full_html(locale:, title:, description:, h1:, content:, canonical:, schema:)
    lang_path = (locale == "es") ? "es" : ""

    <<~HTML
      <!DOCTYPE html>
      <html lang="#{locale}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title}</title>
        <meta name="description" content="#{description}">
        <link rel="canonical" href="https://bookrhub.com#{canonical}">
        <link rel="alternate" hreflang="en" href="https://bookrhub.com#{canonical.sub("/es/", "/en/")}">
        <link rel="alternate" hreflang="es" href="https://bookrhub.com#{canonical.sub("/en/", "/es/")}">
        <link rel="alternate" hreflang="x-default" href="https://bookrhub.com#{canonical.sub("/es/", "/en/")}">
        
        <!-- Open Graph -->
        <meta property="og:type" content="website">
        <meta property="og:url" content="https://bookrhub.com#{canonical}">
        <meta property="og:title" content="#{title}">
        <meta property="og:description" content="#{description}">
        <meta property="og:image" content="https://bookrhub.com/images/og-image.png">
        
        <!-- Styles -->
        <link rel="stylesheet" href="https://bookrhub.com/css/styles.css?v=2.5.1">
        
        <!-- Structured Data -->
        #{schema}
      </head>
      <body>
        <!-- Navigation -->
        <nav class="navbar">
          <div class="container">
            <a href="https://bookrhub.com#{lang_path}/" class="logo">BookrHub</a>
            <div class="nav-links">
              <a href="https://bookrhub.com#{lang_path}/features">#{(locale == "es") ? "Funciones" : "Features"}</a>
              <a href="https://bookrhub.com#{lang_path}/pricing">#{(locale == "es") ? "Precios" : "Pricing"}</a>
              <a href="https://bookrhub.com#{lang_path}/signup" class="btn btn-primary">#{(locale == "es") ? "Comenzar Gratis" : "Get Started Free"}</a>
            </div>
          </div>
        </nav>

        <!-- Main Content -->
        <main>
          <header class="hero-seo">
            <div class="container">
              <h1>#{h1}</h1>
              <p class="lead">#{(locale == "es") ? "Software de reservas simple y gratis para tu negocio. Sin comisión, sin mensualidades." : "Simple, free booking software for your business. No commission, no monthly fees."}</p>
              <a href="https://bookrhub.com#{lang_path}/signup" class="btn btn-primary btn-large">#{(locale == "es") ? "Crea Tu Página Gratis" : "Create Your Free Page"}</a>
            </div>
          </header>

          <section class="content-section">
            <div class="container">
              #{content}
            </div>
          </section>

          <!-- CTA Section -->
          <section class="cta-section">
            <div class="container">
              <h2>#{(locale == "es") ? "¿Listo para Comenzar?" : "Ready to Get Started?"}</h2>
              <p>#{(locale == "es") ? "Unite a miles de negocios que usan BookrHub para reservas online gratis." : "Join thousands of businesses using BookrHub for free online booking."}</p>
              <div class="cta-buttons">
                <a href="https://bookrhub.com#{lang_path}/signup" class="btn btn-primary btn-large">#{(locale == "es") ? "Crear Cuenta Gratis" : "Create Free Account"}</a>
              </div>
            </div>
          </section>
        </main>

        <!-- Footer -->
        <footer>
          <div class="container">
            <div class="footer-links">
              <a href="https://bookrhub.com#{lang_path}/privacy">#{(locale == "es") ? "Privacidad" : "Privacy"}</a>
              <a href="https://bookrhub.com#{lang_path}/terms">#{(locale == "es") ? "Términos" : "Terms"}</a>
              <a href="https://bookrhub.com#{lang_path}/contact">#{(locale == "es") ? "Contacto" : "Contact"}</a>
            </div>
            <p>&copy; 2026 BookrHub. #{(locale == "es") ? "Todos los derechos reservados." : "All rights reserved."}</p>
          </div>
        </footer>
        
        <style>
          /* SEO Page Specific Styles */
          .hero-seo {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 80px 0;
            text-align: center;
          }
          .hero-seo h1 {
            font-size: 2.5rem;
            margin-bottom: 20px;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
          }
          .hero-seo .lead {
            font-size: 1.25rem;
            margin-bottom: 30px;
            opacity: 0.95;
          }
          .content-section {
            padding: 60px 0;
            background: #f9fafb;
          }
          .seo-content {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
          }
          .seo-content .intro {
            font-size: 1.1rem;
            line-height: 1.8;
            color: #374151;
            margin-bottom: 30px;
          }
          .seo-content h2 {
            font-size: 1.5rem;
            margin-top: 40px;
            margin-bottom: 20px;
            color: #111827;
          }
          .seo-content p {
            line-height: 1.8;
            color: #4b5563;
            margin-bottom: 20px;
          }
          .seo-content ul, .seo-content ol {
            margin: 20px 0;
            padding-left: 25px;
          }
          .seo-content li {
            line-height: 1.8;
            color: #4b5563;
            margin-bottom: 10px;
          }
          .feature-list li {
            list-style: none;
            padding-left: 0;
            position: relative;
          }
          .feature-list li::before {
            content: "✓";
            color: #10b981;
            font-weight: bold;
            margin-right: 10px;
          }
          .steps-list {
            counter-reset: step;
          }
          .steps-list li {
            list-style: none;
            padding-left: 40px;
            position: relative;
            counter-increment: step;
          }
          .steps-list li::before {
            content: counter(step);
            position: absolute;
            left: 0;
            top: 0;
            width: 28px;
            height: 28px;
            background: #667eea;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 28px;
            font-size: 0.9rem;
            font-weight: bold;
          }
          .cta-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            margin-top: 40px;
          }
          .cta-box h3 {
            color: white;
            margin-bottom: 15px;
          }
          .cta-box p {
            color: rgba(255,255,255,0.9);
            margin-bottom: 20px;
          }
          .cta-box .btn {
            background: white;
            color: #667eea;
          }
          .cta-box .btn:hover {
            background: #f3f4f6;
          }
          .cta-section {
            background: #1f2937;
            color: white;
            padding: 60px 0;
            text-align: center;
          }
          .cta-section h2 {
            color: white;
            font-size: 2rem;
            margin-bottom: 15px;
          }
          .cta-section p {
            color: rgba(255,255,255,0.8);
            margin-bottom: 30px;
            font-size: 1.1rem;
          }
          .cta-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
          }
          .btn {
            display: inline-block;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
          }
          .btn-primary {
            background: #667eea;
            color: white;
          }
          .btn-primary:hover {
            background: #5a67d8;
            transform: translateY(-2px);
          }
          .btn-secondary {
            background: transparent;
            color: white;
            border: 2px solid white;
          }
          .btn-secondary:hover {
            background: rgba(255,255,255,0.1);
          }
          .btn-large {
            padding: 15px 40px;
            font-size: 1.1rem;
          }
          .comparison-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin: 30px 0;
          }
          .comparison-pros, .comparison-cons {
            padding: 20px;
            border-radius: 8px;
          }
          .comparison-pros {
            background: #ecfdf5;
          }
          .comparison-pros li::before {
            content: "✓";
            color: #10b981;
            font-weight: bold;
            margin-right: 8px;
          }
          .comparison-cons {
            background: #fef2f2;
          }
          .comparison-cons li::before {
            content: "✗";
            color: #ef4444;
            font-weight: bold;
            margin-right: 8px;
          }
          .comparison-table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
          }
          .comparison-table th, .comparison-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
          }
          .comparison-table th {
            background: #f9fafb;
            font-weight: 600;
          }
          .comparison-table td strong {
            color: #10b981;
          }
          footer {
            background: #111827;
            color: rgba(255,255,255,0.7);
            padding: 40px 0;
            text-align: center;
          }
          .footer-links {
            display: flex;
            gap: 30px;
            justify-content: center;
            margin-bottom: 20px;
          }
          .footer-links a {
            color: rgba(255,255,255,0.7);
            text-decoration: none;
          }
          .footer-links a:hover {
            color: white;
          }
          .navbar {
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
          }
          .navbar .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: #667eea;
            text-decoration: none;
          }
          .nav-links {
            display: flex;
            gap: 30px;
            align-items: center;
          }
          .nav-links a {
            color: #4b5563;
            text-decoration: none;
            font-weight: 500;
          }
          .nav-links a:hover {
            color: #667eea;
          }
          @media (max-width: 768px) {
            .hero-seo {
              padding: 50px 20px;
            }
            .hero-seo h1 {
              font-size: 1.8rem;
            }
            .seo-content {
              padding: 25px;
            }
            .comparison-grid {
              grid-template-columns: 1fr;
            }
            .nav-links {
              display: none;
            }
          }
        </style>
      </body>
      </html>
    HTML
  end

  def save_sitemap_urls
    urls_file = File.expand_path("sitemap_urls.txt", __dir__)
    File.write(urls_file, @generated_pages.join("\n"))
    puts "\n📍 Saved #{@generated_pages.count} URLs to #{urls_file}"
  end
end

# Run the generator
if __FILE__ == $0
  generator = SEOPageGenerator.new
  generator.generate_all
end
