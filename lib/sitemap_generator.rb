module SitemapGenerator
  def self.generate(locale_currency_map)
    base_url = I18n.t('site.canonical_url', locale: :en)
    today = Date.today.strftime('%Y-%m-%d')

    available_locales = I18n.available_locales

    xml = ['<?xml version="1.0" encoding="UTF-8"?>']
    xml << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
    xml << '        xmlns:xhtml="http://www.w3.org/1999/xhtml">'

    # Home page with all locale variations
    available_locales.each do |locale|
      locale_str = locale.to_s
      currency = locale_currency_map[locale_str] || locale_currency_map[locale_str.split('-').first] || 'USD'
      url = "#{base_url}/?locale=#{locale_str}&currency=#{currency}"
      url_escaped = url.gsub('&', '&amp;')

      xml << '  <url>'
      xml << "    <loc>#{url_escaped}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>daily</changefreq>'
      xml << '    <priority>1.0</priority>'

      # Add alternate language links
      available_locales.each do |alt_locale|
        alt_locale_str = alt_locale.to_s
        alt_currency = locale_currency_map[alt_locale_str] || locale_currency_map[alt_locale_str.split('-').first] || 'USD'
        alt_url = "#{base_url}/?locale=#{alt_locale_str}&currency=#{alt_currency}"
        alt_url_escaped = alt_url.gsub('&', '&amp;')
        xml << "    <xhtml:link rel=\"alternate\" hreflang=\"#{alt_locale_str}\" href=\"#{alt_url_escaped}\"/>"
      end
      default_url = "#{base_url}/?locale=en&currency=USD"
      default_url_escaped = default_url.gsub('&', '&amp;')
      xml << "    <xhtml:link rel=\"alternate\" hreflang=\"x-default\" href=\"#{default_url_escaped}\"/>"

      xml << '  </url>'
    end

    # Static pages
    static_pages = [
      ['/privacy', 'monthly', '0.5'],
      ['/about', 'monthly', '0.7'],
      ['/contact', 'monthly', '0.7'],
      ['/features', 'weekly', '0.8'],
      ['/pricing', 'weekly', '0.8'],
      ['/free-booking', 'weekly', '0.8'],
    ]
    
    static_pages.each do |path, freq, prio|
      xml << '  <url>'
      xml << "    <loc>#{base_url}#{path}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << "    <changefreq>#{freq}</changefreq>"
      xml << "    <priority>#{prio}</priority>"
      xml << '  </url>'
    end

    # Spanish SEO pages
    spanish_pages = [
      '/turnos',
      '/reservas-online',
      '/agendar',
      '/reserva-de-citas',
      '/turnos-online',
      '/alternativa-a-fresha',
      '/alternativa-a-agendapro'
    ]
    
    spanish_pages.each do |path|
      xml << '  <url>'
      xml << "    <loc>#{base_url}#{path}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>weekly</changefreq>'
      xml << '    <priority>0.8</priority>'
      xml << '  </url>'
    end

    # Competitor alternative pages
    competitors = ['fresha', 'calendly', 'setmore', 'timely', 'kitomba']
    competitors.each do |comp|
      xml << '  <url>'
      xml << "    <loc>#{base_url}/vs-#{comp}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>monthly</changefreq>'
      xml << '    <priority>0.7</priority>'
      xml << '  </url>'
    end

    # Niche pages
    niches = ['barbers', 'hair-salons', 'nail-salons', 'personal-trainers', 'cleaners', 'massage-spa', 'medical-clinics', 'dentists', 'pet-grooming', 'photographers']
    niches.each do |niche|
      xml << '  <url>'
      xml << "    <loc>#{base_url}/booking-system-for-#{niche}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>weekly</changefreq>'
      xml << '    <priority>0.8</priority>'
      xml << '  </url>'
    end

    # Location pages (top cities)
    cities = ['buenos-aires', 'montevideo', 'santiago', 'medellin', 'bogota', 'auckland', 'sydney', 'berlin', 'new-york']
    cities.first(5).each do |city|
      niches.first(3).each do |niche|
        xml << '  <url>'
        xml << "    <loc>#{base_url}/booking-system-for-#{niche}-in-#{city}</loc>"
        xml << "    <lastmod>#{today}</lastmod>"
        xml << '    <changefreq>weekly</changefreq>'
        xml << '    <priority>0.6</priority>'
        xml << '  </url>'
      end
    end

    # Template pages
    templates = ['barber', 'medical-clinic', 'dental', 'fitness', 'hair-salon', 'nails', 'pet-grooming', 'photography', 'spa-massage']
    templates.each do |template|
      xml << '  <url>'
      xml << "    <loc>#{base_url}/templates/#{template}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>monthly</changefreq>'
      xml << '    <priority>0.7</priority>'
      xml << '  </url>'
    end

    xml << '</urlset>'
    xml.join("\n")
  end
end
