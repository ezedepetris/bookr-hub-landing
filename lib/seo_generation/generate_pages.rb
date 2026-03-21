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

    puts "\n📄 Generating use-cases hub page..."
    generate_use_cases_pages

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

  def generate_use_cases_pages
    # English use-cases page
    page_data_en = SEOTemplates.use_cases_page(locale: "en")
    output_path_en = "#{BASE_DIR}/en/use-cases.html"
    generate_html_page(
      path: output_path_en,
      locale: "en",
      **page_data_en
    )
    @generated_pages << "/en/use-cases"

    # Spanish use-cases page
    page_data_es = SEOTemplates.use_cases_page(locale: "es")
    output_path_es = "#{BASE_DIR}/es/casos-de-uso.html"
    generate_html_page(
      path: output_path_es,
      locale: "es",
      **page_data_es
    )
    @generated_pages << "/es/casos-de-uso"

    puts "   ✅ Generated use-cases pages"
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
    locale_param = (locale == "es") ? "es" : "en"
    signup_url = "https://my.bookrhub.com/signup?locale=#{locale_param}"
    login_url = "https://my.bookrhub.com/session/new?locale=#{locale_param}"
    base_url = "https://bookrhub.com/?locale=#{locale_param}"

    nav_labels = (locale == "es") ? {
      features: "Funciones",
      why_us: "Por Qué Nosotros",
      how_it_works: "Cómo Funciona",
      templates: "Plantillas",
      pricing: "Precios",
      sign_in: "Iniciar Sesión",
      get_started: "Empezar Gratis"
    } : {
      features: "Features",
      why_us: "Why Us",
      how_it_works: "How It Works",
      templates: "Templates",
      pricing: "Pricing",
      sign_in: "Sign In",
      get_started: "Get Started"
    }

    footer_labels = (locale == "es") ? {
      description: "Software de reservas gratis para salones, barberías, spas y negocios pequeños. Obtén tu propia página web con reservas online, recordatorios por WhatsApp, y cero comisión.",
      product: "Producto",
      company: "Empresa",
      support: "Soporte",
      legal: "Legal",
      about_us: "Sobre Nosotros",
      blog: "Blog",
      contact_us: "Contáctanos",
      help_center: "Centro de Ayuda",
      privacy_policy: "Política de Privacidad",
      terms_of_service: "Términos de Servicio",
      consent_preferences: "Preferencias de Consentimiento",
      powered_by: "Desarrollado por",
      rights_reserved: "Todos los derechos reservados."
    } : {
      description: "Free booking software for salons, barbershops, spas, and small businesses. Get your own website with online reservations, WhatsApp reminders, and zero commission.",
      product: "Product",
      company: "Company",
      support: "Support",
      legal: "Legal",
      about_us: "About Us",
      blog: "Blog",
      contact_us: "Contact Us",
      help_center: "Help Center",
      privacy_policy: "Privacy Policy",
      terms_of_service: "Terms of Service",
      consent_preferences: "Consent Preferences",
      powered_by: "Powered by",
      rights_reserved: "All rights reserved."
    }

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
        <!-- Scroll progress bar -->
        <div class="scroll-progress" id="scroll-progress" role="progressbar" aria-label="Page scroll progress"></div>

        <!-- Navigation -->
        <nav id="main-nav">
          <div class="nav-container">
            <a href="#{base_url}" class="logo">
              <img src="https://bookrhub.com/images/isologo.svg" alt="BookrHub" class="isologo-image" width="140">
            </a>
            <div class="nav-links">
              <a href="#{base_url}#features">#{nav_labels[:features]}</a>
              <a href="#{base_url}#why-us">#{nav_labels[:why_us]}</a>
              <a href="#{base_url}#screenshots">#{nav_labels[:how_it_works]}</a>
              <a href="#{base_url}#live-templates">#{nav_labels[:templates]}</a>
              <a href="#{base_url}#pricing">#{nav_labels[:pricing]}</a>
              <a href="#{login_url}" class="text-sm font-medium hover:text-primary">#{nav_labels[:sign_in]}</a>
              <a href="#{signup_url}" class="cta-button">#{nav_labels[:get_started]}</a>
            </div>
            <button class="mobile-menu-toggle" aria-label="Toggle menu" id="mobile-menu-toggle">
              <span></span>
              <span></span>
              <span></span>
            </button>
          </div>
        </nav>

        <!-- Mobile Menu -->
        <div class="mobile-menu" id="mobile-menu">
          <div class="mobile-menu-links">
            <a href="#{base_url}#features">#{nav_labels[:features]}</a>
            <a href="#{base_url}#why-us">#{nav_labels[:why_us]}</a>
            <a href="#{base_url}#screenshots">#{nav_labels[:how_it_works]}</a>
            <a href="#{base_url}#live-templates">#{nav_labels[:templates]}</a>
            <a href="#{base_url}#pricing">#{nav_labels[:pricing]}</a>
            <a href="#{login_url}" class="text-sm font-medium">#{nav_labels[:sign_in]}</a>
            <a href="#{signup_url}" class="cta-button">#{nav_labels[:get_started]}</a>
          </div>
        </div>

        <!-- Main Content -->
        <main>
          <header class="hero-seo">
            <div class="container">
              <h1>#{h1}</h1>
              <p class="lead">#{(locale == "es") ? "Software de reservas simple y gratis para tu negocio. Sin comisión, sin mensualidades." : "Simple, free booking software for your business. No commission, no monthly fees."}</p>
              <a href="#{signup_url}" class="btn btn-primary btn-large">#{(locale == "es") ? "Crea Tu Página Gratis" : "Create Your Free Page"}</a>
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
                <a href="#{signup_url}" class="btn btn-primary btn-large">#{(locale == "es") ? "Crear Cuenta Gratis" : "Create Free Account"}</a>
              </div>
            </div>
          </section>
        </main>

        <!-- Floating CTA -->
        <div class="floating-cta" id="floating-cta" aria-hidden="true">
          <a href="#{signup_url}" class="floating-cta-btn">
            #{(locale == "es") ? "Empezar Gratis" : "Get Started"}
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"></path></svg>
          </a>
        </div>

        <!-- Back to top -->
        <button type="button" class="back-to-top" id="back-to-top" aria-label="Back to top">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"></path></svg>
        </button>

        <!-- Footer -->
        <footer>
          <div class="footer-content">
            <div class="footer-brand">
              <a href="#{base_url}" class="logo">
                <img src="https://bookrhub.com/images/isologo.svg" alt="BookrHub" class="isologo-image" width="120">
              </a>
              <p>#{footer_labels[:description]}</p>
            </div>
            <div class="footer-section">
              <h3>#{footer_labels[:product]}</h3>
              <a href="#{base_url}#features">#{nav_labels[:features]}</a>
              <a href="#{base_url}#why-us">#{nav_labels[:why_us]}</a>
              <a href="#{base_url}#live-templates">#{nav_labels[:templates]}</a>
              <a href="#{base_url}#pricing">#{nav_labels[:pricing]}</a>
              <a href="#{base_url}#screenshots">#{nav_labels[:how_it_works]}</a>
              <a href="#{(locale == "es") ? base_url + "/casos-de-uso" : base_url + "/use-cases"}">#{(locale == "es") ? "Casos de Uso" : "Use Cases"}</a>
              <a href="#{login_url}">#{nav_labels[:sign_in]}</a>
              <a href="#{signup_url}">#{nav_labels[:get_started]}</a>
            </div>
            <div class="footer-section">
              <h3>#{footer_labels[:company]}</h3>
              <a href="https://bookrhub.com/about">#{footer_labels[:about_us]}</a>
              <a href="https://blog.bookrhub.com">#{footer_labels[:blog]}</a>
              <a href="https://bookrhub.com/contact">#{footer_labels[:contact_us]}</a>
            </div>
            <div class="footer-section">
              <h3>#{footer_labels[:support]}</h3>
              <a href="https://support.bookrhub.com">#{footer_labels[:help_center]}</a>
              <a href="mailto:admin@bookrhub.com">admin@bookrhub.com</a>
            </div>
            <div class="footer-section">
              <h3>#{footer_labels[:legal]}</h3>
              <a href="https://bookrhub.com/privacy">#{footer_labels[:privacy_policy]}</a>
              <a href="https://bookrhub.com/terms">#{footer_labels[:terms_of_service]}</a>
            </div>
          </div>
          <div class="footer-bottom">
            <p>&copy; 2026 BookrHub. #{footer_labels[:rights_reserved]}</p>
            <span>#{footer_labels[:powered_by]} <a href="https://plumdigital.co.nz" target="_blank" class="copyright-link">Plum Digital</a></span>
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
            background: white;
          }
          .seo-content {
            max-width: 800px;
            margin: 0 auto;
          }
          .seo-content .intro {
            font-size: 1.1rem;
            line-height: 1.8;
            color: #333;
            margin-bottom: 30px;
          }
          .seo-content h2 {
            font-size: 1.75rem;
            margin: 40px 0 20px;
            color: #1a1a2e;
          }
          .seo-content p {
            line-height: 1.8;
            color: #555;
            margin-bottom: 15px;
          }
          .seo-content .feature-list {
            list-style: none;
            padding: 0;
            margin: 20px 0;
          }
          .seo-content .feature-list li {
            padding: 12px 20px;
            background: #f8f9fa;
            margin: 8px 0;
            border-radius: 8px;
            border-left: 4px solid #667eea;
          }
          .seo-content .steps-list {
            counter-reset: step;
            list-style: none;
            padding: 0;
            margin: 20px 0;
          }
          .seo-content .steps-list li {
            counter-increment: step;
            padding: 20px 20px 20px 70px;
            position: relative;
            margin: 15px 0;
            background: #f8f9fa;
            border-radius: 8px;
          }
          .seo-content .steps-list li::before {
            content: counter(step);
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            width: 35px;
            height: 35px;
            background: #667eea;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
          }
          .cta-section {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            padding: 80px 20px;
            text-align: center;
          }
          .cta-section h2 {
            font-size: 2rem;
            margin-bottom: 15px;
          }
          .cta-section p {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 30px;
          }
          .cta-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
          }
          .comparison-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin: 30px 0;
          }
          .comparison-pros ul, .comparison-cons ul {
            list-style: none;
            padding: 0;
          }
          .comparison-pros li {
            padding: 10px;
            background: #f0fdf4;
            border-left: 4px solid #22c55e;
            margin: 8px 0;
          }
          .comparison-cons li {
            padding: 10px;
            background: #fef2f2;
            border-left: 4px solid #dc2626;
            margin: 8px 0;
          }
          .comparison-table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
          }
          .comparison-table th, .comparison-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
          }
          .comparison-table th {
            background: #f8f9fa;
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
            font-size: 1.5rem;
            margin-bottom: 10px;
          }
          .cta-box p {
            margin-bottom: 20px;
            opacity: 0.95;
          }
          .article-content h2 {
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
          }
          /* Use Cases Page Styles */
          .use-cases-content h2 {
            font-size: 1.75rem;
            margin: 40px 0 20px;
            color: #1a1a2e;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
          }
          .use-cases-grid {
            margin: 20px 0;
          }
          .use-cases-list {
            list-style: none;
            padding: 0;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
          }
          .use-cases-list li {
            background: #f8f9fa;
            border-radius: 8px;
            transition: all 0.3s ease;
          }
          .use-cases-list li:hover {
            background: #667eea;
            transform: translateY(-2px);
          }
          .use-cases-list li a {
            display: block;
            padding: 15px 20px;
            color: #333;
            text-decoration: none;
            font-weight: 500;
          }
          .use-cases-list li:hover a {
            color: white;
          }
          .use-cases-cities {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin: 20px 0;
          }
          .use-cases-country h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.25rem;
          }
          .use-cases-country ul {
            list-style: none;
            padding: 0;
          }
          .use-cases-country li {
            padding: 8px 0;
            border-bottom: 1px solid #eee;
          }
          .use-cases-country li a {
            color: #4b5563;
            text-decoration: none;
            transition: color 0.2s;
          }
          .use-cases-country li a:hover {
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
              padding: 0 15px;
            }
            .comparison-grid {
              grid-template-columns: 1fr;
            }
            .nav-links {
              display: none;
            }
          }
        </style>

        <script>
          // Mobile menu toggle
          const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
          const mobileMenu = document.getElementById('mobile-menu');
          if (mobileMenuToggle && mobileMenu) {
            mobileMenuToggle.addEventListener('click', () => {
              mobileMenu.classList.toggle('active');
            });
          }
          
          // Back to top button
          const backToTop = document.getElementById('back-to-top');
          if (backToTop) {
            window.addEventListener('scroll', () => {
              if (window.scrollY > 300) {
                backToTop.classList.add('visible');
              } else {
                backToTop.classList.remove('visible');
              }
            });
            backToTop.addEventListener('click', () => {
              window.scrollTo({ top: 0, behavior: 'smooth' });
            });
          }
          
          // Scroll progress
          const scrollProgress = document.getElementById('scroll-progress');
          if (scrollProgress) {
            window.addEventListener('scroll', () => {
              const scrollTop = window.scrollY;
              const docHeight = document.documentElement.scrollHeight - window.innerHeight;
              const progress = (scrollTop / docHeight) * 100;
              scrollProgress.style.width = progress + '%';
            });
          }
          
          // Nav scroll effect
          const mainNav = document.getElementById('main-nav');
          if (mainNav) {
            window.addEventListener('scroll', () => {
              if (window.scrollY > 50) {
                mainNav.classList.add('nav-scrolled');
              } else {
                mainNav.classList.remove('nav-scrolled');
              }
            });
          }
          
          // Floating CTA visibility
          const floatingCta = document.getElementById('floating-cta');
          if (floatingCta) {
            window.addEventListener('scroll', () => {
              if (window.scrollY > 500) {
                floatingCta.classList.add('visible');
              } else {
                floatingCta.classList.remove('visible');
              }
            });
          }
        </script>
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
