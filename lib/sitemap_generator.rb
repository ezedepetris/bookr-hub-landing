module SitemapGenerator
  def self.generate(locale_currency_map)
    base_url = I18n.t('site.canonical_url', locale: :en)
    today = Date.today.strftime('%Y-%m-%d')

    # Get all available locales
    available_locales = I18n.available_locales

    xml = ['<?xml version="1.0" encoding="UTF-8"?>']
    xml << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
    xml << '        xmlns:xhtml="http://www.w3.org/1999/xhtml">'

    # Home page with all locale variations
    available_locales.each do |locale|
      locale_str = locale.to_s
      currency = locale_currency_map[locale_str] || locale_currency_map[locale_str.split('-').first] || 'USD'
      url = "#{base_url}/?locale=#{locale_str}&currency=#{currency}"
      # Escape ampersands for XML
      url_escaped = url.gsub('&', '&amp;')

      xml << '  <url>'
      xml << "    <loc>#{url_escaped}</loc>"
      xml << "    <lastmod>#{today}</lastmod>"
      xml << '    <changefreq>weekly</changefreq>'
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

    # Privacy page
    xml << '  <url>'
    xml << "    <loc>#{base_url}/privacy</loc>"
    xml << "    <lastmod>#{today}</lastmod>"
    xml << '    <changefreq>monthly</changefreq>'
    xml << '    <priority>0.5</priority>'
    xml << '  </url>'

    xml << '</urlset>'

    xml.join("\n")
  end
end

