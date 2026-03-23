module SitemapGenerator
  def self.generate(locale_currency_map)
    base_url = I18n.t("site.canonical_url", locale: :en)
    today = Date.today.strftime("%Y-%m-%d")

    # Load SEO configuration
    require_relative "seo_generation/seo_config"

    available_locales = I18n.available_locales

    xml = ['<?xml version="1.0" encoding="UTF-8"?>']
    xml << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
    xml << '        xmlns:xhtml="http://www.w3.org/1999/xhtml">'

    # ===== HOME PAGES =====
    available_locales.each do |locale|
      locale_str = locale.to_s
      currency = locale_currency_map[locale_str] || locale_currency_map[locale_str.split("-").first] || "USD"
      url = "#{base_url}/?locale=#{locale_str}&currency=#{currency}"
      url_escaped = url.gsub("&", "&amp;")

      xml << "  <url>"
      xml << "    <loc>#{url_escaped}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>daily</changefreq>"
      xml << "    <priority>1.0</priority>"
      xml << "  </url>"
    end

    # ===== STATIC PAGES (features/pricing are sections on landing - not in sitemap) =====
    static_pages = [
      ["/privacy", "monthly", "0.5"]
    ]

    static_pages.each do |path, freq, prio|
      xml << "  <url>"
      xml << "    <loc>#{base_url}#{path}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>#{freq}</changefreq>"
      xml << "    <priority>#{prio}</priority>"
      xml << "  </url>"
    end

    # ===== NICHE PAGES (English) =====
    SEOConfig::NICHES.each do |niche_key, niche_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/en/booking-system-for-#{niche_key}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>weekly</changefreq>"
      xml << "    <priority>0.8</priority>"
      xml << "  </url>"
    end

    # ===== NICHE PAGES (Spanish) =====
    SEOConfig::NICHES.each do |niche_key, niche_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/es/sistema-de-turnos-para-#{niche_key}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>weekly</changefreq>"
      xml << "    <priority>0.8</priority>"
      xml << "  </url>"
    end

    # ===== CITY PAGES =====
    SEOConfig::CITIES.each do |country_key, country_data|
      country_data[:cities].each do |city|
        SEOConfig::NICHES.each do |niche_key, niche_data|
          if country_key == "argentina" || country_key == "chile" || country_key == "uruguay"
            # Spanish pages for LATAM
            xml << "  <url>"
            xml << "    <loc>#{base_url}/es/sistema-de-turnos-para-#{niche_key}-en-#{city[:slug]}</loc>"
            xml << "    <lastmod>#{today}</lastmod>"
            xml << "    <changefreq>weekly</changefreq>"
            xml << "    <priority>0.7</priority>"
            xml << "  </url>"
          else
            # English pages for ANZ
            xml << "  <url>"
            xml << "    <loc>#{base_url}/en/booking-system-for-#{niche_key}-in-#{city[:slug]}</loc>"
            xml << "    <lastmod>#{today}</lastmod>"
            xml << "    <changefreq>weekly</changefreq>"
            xml << "    <priority>0.7</priority>"
            xml << "  </url>"
          end
        end
      end
    end

    # ===== HOW-TO PAGES (English) =====
    SEOConfig::HOW_TO_EN.each do |page_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/#{page_data[:slug]}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>monthly</changefreq>"
      xml << "    <priority>0.7</priority>"
      xml << "  </url>"
    end

    # ===== HOW-TO PAGES (Spanish) =====
    SEOConfig::HOW_TO_ES.each do |page_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/es/#{page_data[:slug]}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>monthly</changefreq>"
      xml << "    <priority>0.7</priority>"
      xml << "  </url>"
    end

    # ===== COMPETITOR COMPARISON PAGES =====
    SEOConfig::COMPETITORS.each do |competitor_key, competitor_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/vs-#{competitor_key}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>monthly</changefreq>"
      xml << "    <priority>0.7</priority>"
      xml << "  </url>"
    end

    # ===== GENERAL PAGES (English) =====
    SEOConfig::GENERAL_PAGES_EN.each do |page_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/#{page_data[:slug]}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>weekly</changefreq>"
      xml << "    <priority>0.8</priority>"
      xml << "  </url>"
    end

    # ===== HUB PAGES (Directory pages for SEO discovery) =====
    xml << "  <url>"
    xml << "    <loc>#{base_url}/all-booking-system-solutions</loc>"
    xml << "    <lastmod>#{today}</lastmod>"
    xml << "    <changefreq>weekly</changefreq>"
    xml << "    <priority>0.9</priority>"
    xml << "  </url>"

    # ===== GENERAL PAGES (Spanish) =====
    SEOConfig::GENERAL_PAGES_ES.each do |page_data|
      xml << "  <url>"
      xml << "    <loc>#{base_url}/es/#{page_data[:slug]}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>weekly</changefreq>"
      xml << "    <priority>0.8</priority>"
      xml << "  </url>"
    end

    # ===== HUB PAGES (Spanish) =====
    xml << "  <url>"
    xml << "    <loc>#{base_url}/soluciones-sistema-de-turnos</loc>"
    xml << "    <lastmod>#{today}</lastmod>"
    xml << "    <changefreq>weekly</changefreq>"
    xml << "    <priority>0.9</priority>"
    xml << "  </url>"

    xml << "</urlset>"
    xml.join("\n")
  end
end
