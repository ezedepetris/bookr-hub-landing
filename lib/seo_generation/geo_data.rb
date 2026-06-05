# GeoData module — market statistics for GEO/SEO pages
# Uses publicly cited industry data and proportional city estimates

module GeoData
  # Country-level beauty & wellness market data
  # Sources: IBISWorld, Statista, Euromonitor, local industry bodies
  COUNTRY_DATA = {
    'australia' => {
      name: 'Australia',
      code: 'AU',
      currency: 'AUD',
      locale: 'en-AU',
      population: 26_600_000,
      beauty_market_size: 4_200_000_000,
      beauty_businesses: 25_000,
      market_growth: 4.9,
      internet_penetration: 94,
      online_booking_adoption: 62,
      online_booking_preference: 67,
      avg_ticket: 85,
      avg_ticket_currency: 'AUD',
      no_show_rate_manual: 20,
      no_show_rate_online: 4,
      source: 'IBISWorld 2025',
      niche_share: {
        'barbers' => 0.22,
        'hair-salons' => 0.38,
        'beauty-salons' => 0.15,
        'nail-salons' => 0.10,
        'massage-spa' => 0.08,
        'personal-trainers' => 0.04,
        'cleaners' => 0.03
      },
      cities: {
        'sydney'     => { region: 'NSW', population: 5_300_000, known_for: 'largest city' },
        'melbourne'  => { region: 'VIC', population: 5_000_000, known_for: 'culture capital' },
        'brisbane'   => { region: 'QLD', population: 2_500_000, known_for: 'sunshine coast' },
        'perth'      => { region: 'WA',  population: 2_000_000, known_for: 'western hub' },
        'adelaide'   => { region: 'SA',  population: 1_300_000, known_for: 'festival city' },
        'gold-coast' => { region: 'QLD', population: 679_000,  known_for: 'tourist destination' },
        'canberra'   => { region: 'ACT', population: 457_000,  known_for: 'capital city' },
        'newcastle'  => { region: 'NSW', population: 322_000,  known_for: 'harbour city' },
        'wollongong' => { region: 'NSW', population: 302_000,  known_for: 'beach city' },
        'sunshine-coast' => { region: 'QLD', population: 343_000, known_for: 'coastal lifestyle' },
        'hobart'     => { region: 'TAS', population: 240_000,  known_for: 'heritage city' },
        'geelong'    => { region: 'VIC', population: 268_000,  known_for: 'port city' },
        'townsville' => { region: 'QLD', population: 193_000,  known_for: 'north queensland' },
        'cairns'     => { region: 'QLD', population: 153_000,  known_for: 'great barrier reef' },
        'darwin'     => { region: 'NT',  population: 148_000,  known_for: 'northern gateway' },
        'toowoomba'  => { region: 'QLD', population: 136_000,  known_for: 'garden city' },
        'bundaberg'  => { region: 'QLD', population: 73_000,   known_for: 'rum city' },
        'rockhampton' => { region: 'QLD', population: 78_000,  known_for: 'beef capital' },
        'mackay'     => { region: 'QLD', population: 80_000,   known_for: 'sugar city' },
        'hervey-bay' => { region: 'QLD', population: 54_000,   known_for: 'whale watching' },
        'port-macquarie' => { region: 'NSW', population: 48_000, known_for: 'coastal town' },
        'orange'     => { region: 'NSW', population: 38_000,   known_for: 'food and wine' },
        'bendigo'    => { region: 'VIC', population: 100_000,  known_for: 'gold rush city' },
        'launceston' => { region: 'TAS', population: 87_000,   known_for: 'historic city' },
        'ballarat'   => { region: 'VIC', population: 110_000,  known_for: 'heritage city' }
      }
    },

    'new-zealand' => {
      name: 'New Zealand',
      code: 'NZ',
      currency: 'NZD',
      locale: 'en-NZ',
      population: 5_200_000,
      beauty_market_size: 1_200_000_000,
      beauty_businesses: 8_500,
      market_growth: 4.7,
      internet_penetration: 96,
      online_booking_adoption: 60,
      online_booking_preference: 64,
      avg_ticket: 75,
      avg_ticket_currency: 'NZD',
      no_show_rate_manual: 20,
      no_show_rate_online: 4,
      source: 'Stats NZ / IBISWorld 2025',
      niche_share: {
        'barbers' => 0.18,
        'hair-salons' => 0.42,
        'beauty-salons' => 0.15,
        'nail-salons' => 0.08,
        'massage-spa' => 0.10,
        'personal-trainers' => 0.04,
        'cleaners' => 0.03
      },
      cities: {
        'auckland'         => { region: 'Auckland',     population: 1_700_000, known_for: 'city of sails' },
        'wellington'       => { region: 'Wellington',   population: 412_000,  known_for: 'capital city' },
        'christchurch'     => { region: 'Canterbury',   population: 380_000,  known_for: 'garden city' },
        'dunedin'          => { region: 'Otago',        population: 131_000,  known_for: 'student city' },
        'tauranga'         => { region: 'Bay of Plenty', population: 135_000, known_for: 'beach city' },
        'napier-hastings'  => { region: "Hawke's Bay",  population: 130_000,  known_for: 'art deco' },
        'hamilton'         => { region: 'Waikato',      population: 176_000,  known_for: 'river city' },
        'new-plymouth'     => { region: 'Taranaki',     population: 87_000,   known_for: 'mountain views' },
        'invercargill'     => { region: 'Southland',    population: 50_000,   known_for: 'southern city' },
        'rotorua'          => { region: 'Bay of Plenty', population: 57_000,  known_for: 'geothermal' },
        'palmerston-north' => { region: 'Manawatu',     population: 81_000,   known_for: 'student city' },
        'nelson'           => { region: 'Nelson',       population: 51_000,   known_for: 'sunshine city' },
        'whangarei'        => { region: 'Northland',    population: 56_000,   known_for: 'winterless north' },
        'blenheim'         => { region: 'Marlborough',  population: 31_000,   known_for: 'wine country' },
        'pukekohe'         => { region: 'Auckland',     population: 19_000,   known_for: 'countryside' },
        'gisborne'         => { region: 'Gisborne',     population: 36_000,   known_for: 'sunrise city' },
        'timaru'           => { region: 'Canterbury',   population: 29_000,   known_for: 'port town' },
        'morrinsville'     => { region: 'Waikato',      population: 8_000,    known_for: 'town' },
        'feilding'         => { region: 'Manawatu',     population: 16_000,   known_for: 'town' },
        'levin'            => { region: 'Wellington',   population: 20_000,   known_for: 'town' },
        'kaiapoi'          => { region: 'Canterbury',   population: 6_000,    known_for: 'town' },
        'rolleston'        => { region: 'Canterbury',   population: 18_000,   known_for: 'town' },
        'greymouth'        => { region: 'West Coast',   population: 9_000,    known_for: 'west coast' }
      }
    },

    'argentina' => {
      name: 'Argentina',
      code: 'AR',
      currency: 'ARS',
      locale: 'es-AR',
      population: 46_200_000,
      beauty_market_size: 3_500_000_000,
      beauty_businesses: 210_000,
      market_growth: 4.9,
      internet_penetration: 88,
      online_booking_adoption: 35,
      online_booking_preference: 60,
      avg_ticket: 12_000,
      avg_ticket_currency: 'ARS',
      no_show_rate_manual: 25,
      no_show_rate_online: 5,
      source: 'Rentec Digital / INDEC 2025',
      niche_share: {
        'barbers' => 0.28,
        'hair-salons' => 0.32,
        'beauty-salons' => 0.15,
        'nail-salons' => 0.08,
        'massage-spa' => 0.07,
        'personal-trainers' => 0.05,
        'cleaners' => 0.05
      },
      cities: {
        'buenos-aires'      => { region: 'Buenos Aires', population: 15_000_000, known_for: 'capital city' },
        'cordoba'           => { region: 'Cordoba',      population: 1_500_000,  known_for: 'university city' },
        'rosario'           => { region: 'Santa Fe',     population: 1_300_000,  known_for: 'port city' },
        'mendoza'           => { region: 'Mendoza',      population: 1_000_000,  known_for: 'wine region' },
        'la-plata'          => { region: 'Buenos Aires', population: 849_000,    known_for: 'capital province' },
        'mar-del-plata'     => { region: 'Buenos Aires', population: 614_000,    known_for: 'beach destination' },
        'tucuman'           => { region: 'Tucuman',      population: 548_000,    known_for: 'independence city' },
        'salta'             => { region: 'Salta',        population: 536_000,    known_for: 'colonial city' },
        'quilmes'           => { region: 'Buenos Aires', population: 583_000,    known_for: 'suburb' },
        'lanus'             => { region: 'Buenos Aires', population: 453_000,    known_for: 'suburb' },
        'moreno'            => { region: 'Buenos Aires', population: 452_000,    known_for: 'suburb' },
        'santa-fe'          => { region: 'Santa Fe',     population: 391_000,    known_for: 'river city' },
        'pilar'             => { region: 'Buenos Aires', population: 395_000,    known_for: 'growing suburb' },
        'corrientes'        => { region: 'Corrientes',   population: 353_000,    known_for: 'littoral city' },
        'avellaneda'        => { region: 'Buenos Aires', population: 340_000,    known_for: 'industrial suburb' },
        'rio-negro'         => { region: 'Rio Negro',    population: 320_000,    known_for: 'patagonia' },
        'moron'             => { region: 'Buenos Aires', population: 315_000,    known_for: 'suburb' },
        'temuco'            => { region: 'Araucania',    population: 301_000,    known_for: '—' },
        'san-isidro'        => { region: 'Buenos Aires', population: 292_000,    known_for: 'northern suburb' },
        'neuquen'           => { region: 'Neuquen',      population: 291_000,    known_for: 'patagonia hub' },
        'bahia-blanca'      => { region: 'Buenos Aires', population: 274_000,    known_for: 'port city' },
        'vicente-lopez'     => { region: 'Buenos Aires', population: 274_000,    known_for: 'suburb' },
        'jujuy'             => { region: 'Jujuy',        population: 273_000,    known_for: 'northern city' },
        'chaco'             => { region: 'Chaco',        population: 276_000,    known_for: 'northern city' },
        'santiago-del-estero' => { region: 'Santiago del Estero', population: 252_000, known_for: 'oldest city' },
        'rancagua'          => { region: "O'Higgins",    population: 251_000,    known_for: '—' },
        'formosa'           => { region: 'Formosa',      population: 222_000,    known_for: 'northern city' },
        'escobar'           => { region: 'Buenos Aires', population: 213_000,    known_for: 'suburb' },
        'chubut'            => { region: 'Chubut',       population: 196_000,    known_for: 'patagonia' },
        'tierra-del-fuego'  => { region: 'Tierra del Fuego', population: 127_000, known_for: 'southern city' },
        'la-rioja'          => { region: 'La Rioja',     population: 180_000,    known_for: 'northwest city' },
        'san-luis'          => { region: 'San Luis',     population: 169_000,    known_for: 'central city' },
        'ituzaingo'         => { region: 'Buenos Aires', population: 168_000,    known_for: 'suburb' },
        'catamarca'         => { region: 'Catamarca',    population: 159_000,    known_for: 'northwest city' },
        'san-miguel'        => { region: 'Buenos Aires', population: 157_000,    known_for: 'suburb' },
        'martinez'          => { region: 'Buenos Aires', population: 154_000,    known_for: 'suburb' },
        'flores'            => { region: 'Buenos Aires', population: 153_000,    known_for: 'neighborhood' },
        'hurlingham'        => { region: 'Buenos Aires', population: 181_000,    known_for: 'suburb' },
        'recoleta'          => { region: 'Buenos Aires', population: 187_000,    known_for: 'upscale neighborhood' },
        'belgrano'          => { region: 'Buenos Aires', population: 138_000,    known_for: 'neighborhood' },
        'almagro'           => { region: 'Buenos Aires', population: 135_000,    known_for: 'neighborhood' },
        'lomas-de-zamora'   => { region: 'Buenos Aires', population: 616_000,    known_for: 'south suburb' },
        'villa-crespo'      => { region: 'Buenos Aires', population: 85_000,     known_for: 'neighborhood' },
        'nunez'             => { region: 'Buenos Aires', population: 85_000,     known_for: 'neighborhood' },
        'palermo'           => { region: 'Buenos Aires', population: 253_000,    known_for: 'trendy neighborhood' },
        'tandil'            => { region: 'Buenos Aires', population: 101_000,    known_for: 'hill city' },
        'olivos'            => { region: 'Buenos Aires', population: 54_000,     known_for: 'suburb' },
        'beccar'            => { region: 'Buenos Aires', population: 59_000,     known_for: 'suburb' },
        'victoria'          => { region: 'Buenos Aires', population: 87_000,     known_for: 'suburb' }
      }
    },

    'chile' => {
      name: 'Chile',
      code: 'CL',
      currency: 'CLP',
      locale: 'es-CL',
      population: 19_600_000,
      beauty_market_size: 1_800_000_000,
      beauty_businesses: 85_000,
      market_growth: 4.2,
      internet_penetration: 90,
      online_booking_adoption: 38,
      online_booking_preference: 62,
      avg_ticket: 25_000,
      avg_ticket_currency: 'CLP',
      no_show_rate_manual: 22,
      no_show_rate_online: 5,
      source: 'INE Chile / Euromonitor 2025',
      niche_share: {
        'barbers' => 0.25,
        'hair-salons' => 0.33,
        'beauty-salons' => 0.16,
        'nail-salons' => 0.09,
        'massage-spa' => 0.07,
        'personal-trainers' => 0.05,
        'cleaners' => 0.05
      },
      cities: {
        'santiago'       => { region: 'Santiago',     population: 6_300_000, known_for: 'capital city' },
        'concepcion'     => { region: 'Biobio',       population: 863_000,  known_for: 'university city' },
        'maipu'          => { region: 'Santiago',     population: 544_000,  known_for: 'district' },
        'puente-alto'    => { region: 'Santiago',     population: 568_000,  known_for: 'district' },
        'la-florida'     => { region: 'Santiago',     population: 402_000,  known_for: 'district' },
        'antofagasta'    => { region: 'Antofagasta',  population: 390_000,  known_for: 'mining city' },
        'vina-del-mar'   => { region: 'Valparaiso',   population: 324_000,  known_for: 'garden city' },
        'temuco'         => { region: 'Araucania',    population: 301_000,  known_for: 'southern hub' },
        'las-condes'     => { region: 'Santiago',     population: 295_000,  known_for: 'business district' },
        'valparaiso'     => { region: 'Valparaiso',   population: 284_000,  known_for: 'port city' },
        'rancagua'       => { region: "O'Higgins",    population: 251_000,  known_for: 'central hub' },
        'penalolen'      => { region: 'Santiago',     population: 241_000,  known_for: 'district' },
        'la-serena'      => { region: 'Coquimbo',     population: 222_000,  known_for: 'beach city' },
        'nunoa'          => { region: 'Santiago',     population: 208_000,  known_for: 'district' },
        'iquique'        => { region: 'Tarapaca',     population: 190_000,  known_for: 'northern city' },
        'copiapo'        => { region: 'Atacama',      population: 171_000,  known_for: 'desert city' },
        'san-bernardo'   => { region: 'Santiago',     population: 158_000,  known_for: 'district' },
        'osorno'         => { region: 'Los Lagos',    population: 158_000,  known_for: 'lakes district' },
        'recoleta'       => { region: 'Santiago',     population: 147_000,  known_for: 'district' },
        'providencia'    => { region: 'Santiago',     population: 126_000,  known_for: 'upscale district' },
        'macul'          => { region: 'Santiago',     population: 131_000,  known_for: 'district' },
        'estacion-central' => { region: 'Santiago',   population: 108_000,  known_for: 'transport hub' },
        'santiago-centro' => { region: 'Santiago',    population: 200_000,  known_for: 'downtown' },
        'independencia'  => { region: 'Santiago',     population: 83_000,   known_for: 'district' },
        'puerto-varas'   => { region: 'Los Lagos',    population: 45_000,   known_for: 'tourist town' }
      }
    },

    'uruguay' => {
      name: 'Uruguay',
      code: 'UY',
      currency: 'UYU',
      locale: 'es-UY',
      population: 3_500_000,
      beauty_market_size: 400_000_000,
      beauty_businesses: 18_000,
      market_growth: 3.8,
      internet_penetration: 85,
      online_booking_adoption: 30,
      online_booking_preference: 55,
      avg_ticket: 1_500,
      avg_ticket_currency: 'UYU',
      no_show_rate_manual: 25,
      no_show_rate_online: 5,
      source: 'INE Uruguay / Euromonitor 2025',
      niche_share: {
        'barbers' => 0.27,
        'hair-salons' => 0.30,
        'beauty-salons' => 0.17,
        'nail-salons' => 0.09,
        'massage-spa' => 0.07,
        'personal-trainers' => 0.05,
        'cleaners' => 0.05
      },
      cities: {
        'montevideo'        => { region: 'Montevideo',    population: 1_300_000, known_for: 'capital city' },
        'salto'             => { region: 'Salto',         population: 104_000,  known_for: 'northern city' },
        'ciudad-de-la-costa' => { region: 'Canelones',    population: 112_000,  known_for: 'coastal city' },
        'paysandu'          => { region: 'Paysandu',      population: 76_000,   known_for: 'port city' },
        'las-piedras'       => { region: 'Canelones',     population: 71_000,   known_for: 'suburb' },
        'rivera'            => { region: 'Rivera',        population: 64_000,   known_for: 'border city' },
        'melo'              => { region: 'Cerro Largo',   population: 51_000,   known_for: 'eastern city' },
        'mercedes'          => { region: 'Soriano',       population: 42_000,   known_for: 'river city' },
        'san-jose'          => { region: 'San Jose',      population: 35_000,   known_for: 'central city' },
        'durazno'           => { region: 'Durazno',       population: 30_000,   known_for: 'central city' },
        'rocha'             => { region: 'Rocha',         population: 25_000,   known_for: 'eastern city' },
        'treinta-y-tres'    => { region: 'Treinta y Tres', population: 25_000,  known_for: 'eastern city' },
        'colonia'           => { region: 'Colonia',       population: 22_000,   known_for: 'historic city' },
        'trinidad'          => { region: 'Flores',        population: 21_000,   known_for: 'central town' },
        'santa-lucia'       => { region: 'Canelones',     population: 17_000,   known_for: 'town' },
        'david-areco'       => { region: 'Canelones',     population: 15_000,   known_for: 'town' },
        'pereira'           => { region: 'Canelones',     population: 12_000,   known_for: 'town' },
        'punta-del-este'    => { region: 'Maldonado',     population: 9_000,    known_for: 'resort city' },
        'san-ramon'         => { region: 'Canelones',     population: 7_000,    known_for: 'town' },
        'pan-de-azucar'     => { region: 'Maldonado',     population: 5_000,    known_for: 'town' },
        'atlantida'         => { region: 'Canelones',     population: 5_000,    known_for: 'beach town' },
        'la-paloma'         => { region: 'Rocha',         population: 3_000,    known_for: 'beach town' }
      }
    }
  }.freeze

  NICHE_NAMES = {
    'barbers' => {
      en: { singular: 'barber', plural: 'barbers' },
      es: { singular: 'barbería', plural: 'barberías' }
    },
    'hair-salons' => {
      en: { singular: 'hair salon', plural: 'hair salons' },
      es: { singular: 'peluquería', plural: 'peluquerías' }
    },
    'beauty-salons' => {
      en: { singular: 'beauty salon', plural: 'beauty salons' },
      es: { singular: 'salón de belleza', plural: 'salones de belleza' }
    },
    'nail-salons' => {
      en: { singular: 'nail salon', plural: 'nail salons' },
      es: { singular: 'salón de uñas', plural: 'salones de uñas' }
    },
    'massage-spa' => {
      en: { singular: 'massage and spa', plural: 'massage and spa businesses' },
      es: { singular: 'spa y masajes', plural: 'spas y masajes' }
    },
    'personal-trainers' => {
      en: { singular: 'personal trainer', plural: 'personal trainers' },
      es: { singular: 'entrenador personal', plural: 'entrenadores personales' }
    },
    'cleaners' => {
      en: { singular: 'cleaning service', plural: 'cleaning services' },
      es: { singular: 'servicio de limpieza', plural: 'servicios de limpieza' }
    }
  }.freeze

  # Estimate number of businesses of a given niche in a given city
  def self.estimate_businesses(country_key, city_slug, niche)
    country = COUNTRY_DATA[country_key]
    return nil unless country

    city = country[:cities][city_slug]
    return nil unless city

    niche_share = country.dig(:niche_share, niche) || 0.05
    city_proportion = city[:population].to_f / country[:population]
    (country[:beauty_businesses] * city_proportion * niche_share).round
  end

  # Build a stat callout HTML block for a page
  def self.stat_callout_html(country_key, city_slug, niche, locale = :en)
    country = COUNTRY_DATA[country_key]
    return '' unless country

    city = country[:cities][city_slug]
    return '' unless country && city

    biz_count = estimate_businesses(country_key, city_slug, niche)
    return '' unless biz_count && biz_count > 0

    niche_name = NICHE_NAMES.dig(niche, locale, :plural) || niche
    city_name = city_slug.split('-').map(&:capitalize).join(' ')
    currency = country[:avg_ticket_currency]
    avg_ticket = country[:avg_ticket]
    market_growth = country[:market_growth]

    <<~HTML
      <div class="stat-callout">
        <div class="stat-callout-grid">
          <div class="stat-item">
            <span class="stat-number">#{biz_count}+</span>
            <span class="stat-label">#{niche_name.capitalize} in #{city_name}</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">#{currency} #{format_number(avg_ticket)}</span>
            <span class="stat-label">Average ticket per visit</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">#{country[:online_booking_preference]}%</span>
            <span class="stat-label">Of clients prefer online booking</span>
          </div>
          <div class="stat-item">
            <span class="stat-number">#{market_growth}%</span>
            <span class="stat-label">Annual market growth</span>
          </div>
        </div>
        <p class="stat-source">Source: #{country[:source]} | Based on #{city_name}#{city_name.end_with?('s') ? "'" : "'s"} population of #{format_number(city[:population])}</p>
      </div>
    HTML
  end

  def self.format_number(n)
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
