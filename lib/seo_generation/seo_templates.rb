# SEO Page Templates Module
# Contains ERB templates for generating SEO pages

class String
  def titleize
    split(/[-_\s]/).map { |word| word.capitalize }.join(" ")
  end
end

module SEOTemplates
  # Base HTML template with common elements
  def self.base_html(locale:, title:, description:, h1:, content:, canonical_url:, lang_path:, page_type:, schema: nil)
    locale_param = (locale == "es") ? "es" : "en"
    signup_url = "https://my.bookrhub.com/signup?locale=#{locale_param}"
    login_url = "https://my.bookrhub.com/session/new?locale=#{locale_param}"

    <<~HTML
      <!DOCTYPE html>
      <html lang="#{locale}">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title}</title>
        <meta name="description" content="#{description}">
        <link rel="canonical" href="https://www.bookrhub.com#{canonical_url}">
        
        <!-- Open Graph -->
        <meta property="og:type" content="website">
        <meta property="og:url" content="https://www.bookrhub.com#{canonical_url}">
        <meta property="og:title" content="#{title}">
        <meta property="og:description" content="#{description}">
        <meta property="og:image" content="https://www.bookrhub.com/images/og-image.png">
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/styles.css?v=2.5.1">
        
        <!-- Structured Data -->
        #{schema || ""}
      </head>
      <body>
        <!-- Navigation -->
        <nav class="navbar">
          <div class="container">
            <a href="https://www.bookrhub.com/?locale=#{locale_param}" class="logo">BookrHub</a>
            <div class="nav-links">
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#features">Features</a>
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#pricing">Pricing</a>
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#why-us">Why Us</a>
              <a href="#{login_url}" class="btn btn-secondary">Sign In</a>
              <a href="#{signup_url}" class="btn btn-primary">Get Started Free</a>
            </div>
          </div>
        </nav>

        <!-- Main Content -->
        <main>
          <header class="hero-seo">
            <div class="container">
              <h1>#{h1}</h1>
              <p class="lead">#{(locale == "es") ? "Software de reservas simple y gratis para tu negocio. Sin comisión, sin mensualidades." : "Simple, free booking software for your business. No commission, no monthly fees."}</p>
              <a href="#{signup_url}" class="btn btn-primary btn-large">#{(locale == "es") ? "Empezar Gratis" : "Create Your Free Page"}</a>
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
              <h2>#{(locale == "es") ? "¿Listo para Empezar?" : "Ready to Get Started?"}</h2>
              <p>#{(locale == "es") ? "Unite a miles de negocios que usan BookrHub para reservas online gratis." : "Join thousands of businesses using BookrHub for free online booking."}</p>
              <div class="cta-buttons">
                <a href="#{signup_url}" class="btn btn-primary btn-large">#{(locale == "es") ? "Crear Cuenta Gratis" : "Create Free Account"}</a>
                <a href="https://www.bookrhub.com/?locale=#{locale_param}#templates" class="btn btn-secondary btn-large">#{(locale == "es") ? "Ver Plantillas" : "See Demo"}</a>
              </div>
            </div>
          </section>
        </main>

        <!-- Footer -->
        <footer>
          <div class="container">
            <div class="footer-links">
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#privacy">#{(locale == "es") ? "Privacidad" : "Privacy"}</a>
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#terms">#{(locale == "es") ? "Términos" : "Terms"}</a>
              <a href="https://www.bookrhub.com/?locale=#{locale_param}#contact">#{(locale == "es") ? "Contacto" : "Contact"}</a>
            </div>
            <p>&copy; 2026 BookrHub. #{(locale == "es") ? "Todos los derechos reservados." : "All rights reserved."}</p>
            <p class="last-updated" style="font-size: 0.8rem; opacity: 0.7; margin-top: 8px;">Last updated: March 2026</p>
          </div>
        </footer>
      </body>
      </html>
    HTML
  end

  # Niche page content template (English)
  def self.niche_page_en(niche_key:, niche_data:, locale: "en")
    services_list = niche_data[:services_en].map { |s| "<li>#{s.titleize}</li>" }.join
    benefits_list = niche_data[:benefits_en].map { |b| "<li>#{b}</li>" }.join
    pain_points_list = niche_data[:pain_points_en].map { |p| "<li>#{p}</li>" }.join

    canonical = "/#{locale}/booking-system-for-#{niche_key}"
    title = "Booking System for #{niche_data[:name_en]} | Free Online Appointments"
    description = "The best free booking system for #{niche_data[:name_en].downcase}. Let clients book online 24/7, reduce no-shows with reminders, and grow your business. No commission."

    faq_schema = <<~JSON
      {
        "@type": "FAQPage",
        "mainEntity": [
          {
            "@type": "Question",
            "name": "Is BookrHub really free for #{niche_data[:name_en].downcase}?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Yes! BookrHub offers a free forever plan perfect for #{niche_data[:name_en].downcase}. You get unlimited appointments, online booking page, and automated reminders at no cost."
            }
          },
          {
            "@type": "Question",
            "name": "How does BookrHub help reduce no-shows?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "BookrHub automatically sends reminders to clients before their appointments. Studies show this reduces no-shows by 40% on average."
            }
          },
          {
            "@type": "Question",
            "name": "Can clients book #{niche_data[:name_en].downcase} appointments outside business hours?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Yes! BookrHub allows clients to book 24/7. They can see your availability and book time slots anytime, even when you're closed."
            }
          },
          {
            "@type": "Question",
            "name": "Does BookrHub charge commission on bookings?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "No. BookrHub charges 0% commission on all bookings. Unlike competitors like Fresha (20% commission), you keep 100% of what you earn."
            }
          },
          {
            "@type": "Question",
            "name": "How long does it take to set up?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Most #{niche_data[:name_en].downcase} owners are up and running in under 5 minutes. Just sign up, add your services, and share your booking link."
            }
          }
        ]
      }
    JSON

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": "BookrHub - #{niche_data[:name_en]} Booking",
        "applicationCategory": "BusinessApplication",
        "operatingSystem": "Web, iOS, Android",
        "offers": {
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "USD"
        }
      }
      </script>
      <script type="application/ld+json">
      #{faq_schema}
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content">
        <p class="intro">Running a #{niche_data[:singular_en]} is busy work. Between managing clients, delivering great service, and running the business, the last thing you need is chaos around scheduling. BookrHub gives your clients an easy way to book appointments online while you stay focused on what you do best.</p>

        <h2>Why #{niche_data[:name_en]} Need Online Booking</h2>
        <p>Modern customers expect convenience. They want to book #{niche_data[:name_en].downcase} services at any time, not just when you're available to answer the phone. Online booking meets them where they are. Businesses using online booking systems see a <strong>40% reduction in no-shows</strong> and save an average of <strong>10 hours per week</strong> on phone scheduling.</p>
        <ul class="feature-list">
          #{pain_points_list}
        </ul>

        <h2>How BookrHub Helps Your #{niche_data[:name_en].delete("s")}</h2>
        <p>BookrHub is designed specifically for #{niche_data[:name_en].downcase} like yours. Here's what you get:</p>
        <ul class="feature-list">
          #{benefits_list}
        </ul>

        <h2>Services You Can Offer</h2>
        <p>Configure your #{niche_data[:name_en].downcase} services with custom pricing:</p>
        <ul class="feature-list">
          #{services_list}
        </ul>

        <h2>Getting Started Is Free</h2>
        <p>No monthly fees, no commission on bookings, and no contracts. Just sign up, add your services, and start accepting appointments online today.</p>
        <ol class="steps-list">
          <li><strong>Create your account</strong> - It takes less than 2 minutes</li>
          <li><strong>Add your services</strong> - Include #{niche_data[:name_en].downcase} services and prices</li>
          <li><strong>Set your availability</strong> - Define when you're open for appointments</li>
          <li><strong>Share your booking link</strong> - Add it to your social media, website, or WhatsApp</li>
        </ol>

        <h2>Frequently Asked Questions</h2>
        <div class="faq-block">
          <h3>Is BookrHub really free for #{niche_data[:name_en].downcase}?</h3>
          <p>Yes! BookrHub offers a free forever plan perfect for #{niche_data[:name_en].downcase}. You get unlimited appointments, online booking page, and automated reminders at no cost.</p>

          <h3>How does BookrHub help reduce no-shows?</h3>
          <p>BookrHub automatically sends reminders to clients before their appointments. Studies show this reduces no-shows by 40% on average.</p>

          <h3>Can clients book #{niche_data[:name_en].downcase} appointments outside business hours?</h3>
          <p>Yes! BookrHub allows clients to book 24/7. They can see your availability and book time slots anytime, even when you're closed.</p>

          <h3>Does BookrHub charge commission on bookings?</h3>
          <p>No. BookrHub charges 0% commission on all bookings. Unlike competitors like Fresha (20% commission), you keep 100% of what you earn.</p>

          <h3>How long does it take to set up?</h3>
          <p>Most #{niche_data[:name_en].downcase} owners are up and running in under 5 minutes. Just sign up, add your services, and share your booking link.</p>
        </div>
      </div>
    HTML

    {
      title: title,
      description: description,
      canonical: canonical,
      h1: "Free Booking System for #{niche_data[:name_en]}",
      content: content,
      schema: schema
    }
  end

  # Niche page content template (Spanish)
  def self.niche_page_es(niche_key:, niche_data:, locale: "es")
    services_list = niche_data[:services_es].map { |s| "<li>#{s}</li>" }.join
    benefits_list = niche_data[:benefits_es].map { |b| "<li>#{b}</li>" }.join
    pain_points_list = niche_data[:pain_points_es].map { |p| "<li>#{p}</li>" }.join

    canonical = "/#{locale}/sistema-de-turnos-para-#{niche_key}"
    title = "Sistema de Turnos para #{niche_data[:name_es]} | Reservas Online Gratis"
    description = "El mejor sistema de turnos gratis para #{niche_data[:name_es].downcase}. Deja que tus clientes reserven online 24/7, reduce inasistencias con recordatorios por WhatsApp, y hace crecer tu negocio. Sin comisión."

    faq_schema = <<~JSON
      {
        "@type": "FAQPage",
        "mainEntity": [
          {
            "@type": "Question",
            "name": "¿BookrHub es realmente gratis para #{niche_data[:name_es].downcase}?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "¡Sí! BookrHub ofrece un plan gratis para siempre, perfecto para #{niche_data[:name_es].downcase}. Obtenés turnos ilimitados, página de reservas online, y recordatorios automáticos sin costo."
            }
          },
          {
            "@type": "Question",
            "name": "¿Cómo ayuda BookrHub a reducir las inasistencias?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "BookrHub envía automáticamente recordatorios por WhatsApp y email antes de los turnos. Estudios muestran que esto reduce las inasistencias en un 40% en promedio."
            }
          },
          {
            "@type": "Question",
            "name": "¿Pueden los clientes reservar turnos de #{niche_data[:name_es].downcase} fuera del horario comercial?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "¡Sí! BookrHub permite a los clientes reservar 24/7. Pueden ver tu disponibilidad y reservar horarios en cualquier momento, incluso cuando estás cerrado."
            }
          },
          {
            "@type": "Question",
            "name": "¿BookrHub cobra comisión en las reservas?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "No. BookrHub cobra 0% de comisión en todas las reservas. A diferencia de competidores como Fresha (20% de comisión), vos te quedás con el 100% de lo que ganás."
            }
          },
          {
            "@type": "Question",
            "name": "¿Cuánto tiempo lleva configurarlo?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "La mayoría de los dueños de #{niche_data[:name_es].downcase} están listos en menos de 5 minutos. Solo registrate, agregá tus servicios, y compartí tu link de reservas."
            }
          }
        ]
      }
    JSON

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": "BookrHub - Reservas para #{niche_data[:name_es]}",
        "applicationCategory": "BusinessApplication",
        "operatingSystem": "Web, iOS, Android",
        "offers": {
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "USD"
        }
      }
      </script>
      <script type="application/ld+json">
      #{faq_schema}
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content">
        <p class="intro">Gestionar un #{niche_data[:singular_es]} es un trabajo ocupado. Entre atender clientes, dar buen servicio, y correr el negocio, lo último que necesitas es caos con la agenda. BookrHub les da a tus clientes una forma fácil de reservar turnos online mientras vos te concentrás en lo que mejor hacés.</p>

        <h2>Por Qué las #{niche_data[:name_es]} Necesitan Reservas Online</h2>
        <p>Los clientes modernos esperan comodidad. Quieren reservar servicios de #{niche_data[:name_es].downcase} a cualquier hora, no solo cuando estás disponible para atender el teléfono. Las reservas online los encuentran donde están. Los negocios que usan sistemas de reservas online ven una <strong>reducción del 40% en inasistencias</strong> y ahorran un promedio de <strong>10 horas semanales</strong> en llamadas de agenda.</p>
        <ul class="feature-list">
          #{pain_points_list}
        </ul>

        <h2>Cómo BookrHub Ayuda a Tu #{niche_data[:name_es].delete("s")}</h2>
        <p>BookrHub está diseñado específicamente para #{niche_data[:name_es].downcase} como el tuyo. Esto es lo que obtenés:</p>
        <ul class="feature-list">
          #{benefits_list}
        </ul>

        <h2>Servicios Que Podés Ofrecer</h2>
        <p>Configurá los servicios de tu #{niche_data[:name_es].downcase} con precios personalizados:</p>
        <ul class="feature-list">
          #{services_list}
        </ul>

        <h2>Empezar Es Gratis</h2>
        <p>Sin mensualidades, sin comisión en reservas, y sin contratos. Solo registrate, agregá tus servicios, y comenzá a aceptar turnos online hoy.</p>
        <ol class="steps-list">
          <li><strong>Creá tu cuenta</strong> - Toma menos de 2 minutos</li>
          <li><strong>Agregá tus servicios</strong> - Incluí servicios y precios de #{niche_data[:name_es].downcase}</li>
          <li><strong>Definí tu disponibilidad</strong> - Establecé cuándo estás abierto para turnos</li>
          <li><strong>Compartí tu link de reservas</strong> - Agregalo a tus redes, página web, o WhatsApp</li>
        </ol>

        <h2>Preguntas Frecuentes</h2>
        <div class="faq-block">
          <h3>¿BookrHub es realmente gratis para #{niche_data[:name_es].downcase}?</h3>
          <p>¡Sí! BookrHub ofrece un plan gratis para siempre, perfecto para #{niche_data[:name_en].downcase}. Obtenés turnos ilimitados, página de reservas online, y recordatorios automáticos sin costo.</p>

          <h3>¿Cómo ayuda BookrHub a reducir las inasistencias?</h3>
          <p>BookrHub envía automáticamente recordatorios por WhatsApp y email antes de los turnos. Estudios muestran que esto reduce las inasistencias en un 40% en promedio.</p>

          <h3>¿Pueden los clientes reservar turnos de #{niche_data[:name_es].downcase} fuera del horario comercial?</h3>
          <p>¡Sí! BookrHub permite a los clientes reservar 24/7. Pueden ver tu disponibilidad y reservar horarios en cualquier momento, incluso cuando estás cerrado.</p>

          <h3>¿BookrHub cobra comisión en las reservas?</h3>
          <p>No. BookrHub cobra 0% de comisión en todas las reservas. A diferencia de competidores como Fresha (20% de comisión), vos te quedás con el 100% de lo que ganás.</p>

          <h3>¿Cuánto tiempo lleva configurarlo?</h3>
          <p>La mayoría de los dueños de #{niche_data[:name_es].downcase} están listos en menos de 5 minutos. Solo registrate, agregá tus servicios, y compartí tu link de reservas.</p>
        </div>
      </div>
    HTML

    {
      title: title,
      description: description,
      canonical: canonical,
      h1: "Sistema de Turnos Gratis para #{niche_data[:name_es]}",
      content: content,
      schema: schema
    }
  end

  # Niche + City page content template (English)
  def self.city_page_en(niche_key:, niche_data:, city_data:, country_data:, locale: "en")
    services_list = niche_data[:services_en].first(3).map { |s| "<li>#{s.titleize}</li>" }.join

    canonical = "/#{locale}/booking-system-for-#{niche_key}-in-#{city_data[:slug]}"
    title = "Booking System for #{niche_data[:name_en]} in #{city_data[:name]} | Free Online Appointments"
    description = "Looking for a booking system for #{niche_data[:name_en].downcase} in #{city_data[:name]}? Let clients book online 24/7, reduce no-shows with reminders. Free to start."

    faq_schema = <<~JSON
      {
        "@type": "FAQPage",
        "mainEntity": [
          {
            "@type": "Question",
            "name": "Is BookrHub free for #{niche_data[:name_en].downcase} in #{city_data[:name]}?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Yes! BookrHub offers a free forever plan. Get unlimited appointments, online booking, and automated reminders at no cost."
            }
          },
          {
            "@type": "Question",
            "name": "How does BookrHub reduce no-shows for #{city_data[:name]} businesses?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "BookrHub sends automatic reminders before appointments. Businesses see a 40% reduction in no-shows."
            }
          },
          {
            "@type": "Question",
            "name": "Can clients in #{city_data[:name]} book outside business hours?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Yes! Clients can book 24/7, even when you're closed. They'll see your available slots and book instantly."
            }
          },
          {
            "@type": "Question",
            "name": "Does BookrHub charge commission?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "No commission. Unlike Fresha (20%), you keep 100% of every booking."
            }
          }
        ]
      }
    JSON

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        "name": "#{niche_data[:name_en]} Booking in #{city_data[:name]}",
        "areaServed": {
          "@type": "City",
          "name": "#{city_data[:name]}",
          "addressRegion": "#{city_data[:region]}",
          "addressCountry": "#{country_data[:code]}"
        }
      }
      </script>
      <script type="application/ld+json">
      #{faq_schema}
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content">
        <p class="intro">If you run a #{niche_data[:singular_en]} in #{city_data[:name]}, you know how challenging it can be to manage appointments. Between phone calls, walk-ins, and messages, staying organized is tough. BookrHub makes it easy for your clients in #{city_data[:name]} to book online while you focus on running your business.</p>

        <h2>Why #{niche_data[:name_en]} in #{city_data[:name]} Need Online Booking</h2>
        <p>Clients in #{city_data[:name]} expect convenience. They want to book #{niche_data[:name_en].downcase} services when it suits them, not just during your business hours. Online booking gives them 24/7 access to your schedule. Businesses using online booking see a <strong>40% reduction in no-shows</strong> and save <strong>10+ hours per week</strong> on phone calls.</p>
        <ul class="feature-list">
          <li>Clients in #{city_data[:name]} book at their convenience, day or night</li>
          <li>Automatic reminders reduce missed appointments</li>
          <li>Manage your #{niche_data[:name_en].downcase} schedule from anywhere</li>
          <li>Accept bookings even when you're busy or closed</li>
        </ul>

        <h2>Perfect for #{city_data[:name]}'s #{niche_data[:name_en]}</h2>
        <p>Whether you're just starting out or have been serving #{city_data[:name]} for years, BookrHub helps you manage your #{niche_data[:name_en].downcase} appointments professionally:</p>
        <ul class="feature-list">
          #{services_list}
        </ul>

        <h2>Get Started in #{city_data[:name]}</h2>
        <p>Join other #{niche_data[:name_en].downcase} businesses in #{city_data[:name]} using BookrHub:</p>
        <ol class="steps-list">
          <li><strong>Create your free account</strong> - Takes less than 2 minutes</li>
          <li><strong>Add your services</strong> - Set up your #{niche_data[:name_en].downcase} offerings</li>
          <li><strong>Set your #{city_data[:name]} availability</strong> - Define when you're open</li>
          <li><strong>Share your booking link</strong> - With clients in #{city_data[:name]}</li>
        </ol>

        <h2>Frequently Asked Questions</h2>
        <div class="faq-block">
          <h3>Is BookrHub free for #{niche_data[:name_en].downcase} in #{city_data[:name]}?</h3>
          <p>Yes! BookrHub offers a free forever plan. Get unlimited appointments, online booking, and automated reminders at no cost.</p>

          <h3>How does BookrHub reduce no-shows for #{city_data[:name]} businesses?</h3>
          <p>BookrHub sends automatic reminders before appointments. Businesses see a 40% reduction in no-shows.</p>

          <h3>Can clients in #{city_data[:name]} book outside business hours?</h3>
          <p>Yes! Clients can book 24/7, even when you're closed. They'll see your available slots and book instantly.</p>

          <h3>Does BookrHub charge commission?</h3>
          <p>No commission. Unlike Fresha (20%), you keep 100% of every booking.</p>
        </div>

        <p>Start accepting online bookings for your #{niche_data[:name_en].downcase} in #{city_data[:name]} today. It's free to get started with no commission on bookings.</p>
      </div>
    HTML

    {
      title: title,
      description: description,
      canonical: canonical,
      h1: "Booking System for #{niche_data[:name_en]} in #{city_data[:name]}",
      content: content,
      schema: schema
    }
  end

  # Niche + City page content template (Spanish)
  def self.city_page_es(niche_key:, niche_data:, city_data:, country_data:, locale: "es")
    services_list = niche_data[:services_es].first(3).map { |s| "<li>#{s}</li>" }.join

    canonical = "/#{locale}/sistema-de-turnos-para-#{niche_key}-en-#{city_data[:slug]}"
    title = "Sistema de Turnos para #{niche_data[:name_es]} en #{city_data[:name]} | Reservas Online Gratis"
    description = "¿Buscás un sistema de turnos para #{niche_data[:name_es].downcase} en #{city_data[:name]}? Deja que tus clientes reserven online 24/7, reduce inasistencias con recordatorios por WhatsApp. Gratis para empezar."

    faq_schema = <<~JSON
      {
        "@type": "FAQPage",
        "mainEntity": [
          {
            "@type": "Question",
            "name": "¿BookrHub es gratis para #{niche_data[:name_es].downcase} en #{city_data[:name]}?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "¡Sí! BookrHub ofrece un plan gratis para siempre. Obtené turnos ilimitados, reservas online, y recordatorios automáticos sin costo."
            }
          },
          {
            "@type": "Question",
            "name": "¿Cómo ayuda BookrHub a reducir inasistencias en #{city_data[:name]}?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "BookrHub envía recordatorios automáticos por WhatsApp y email antes de los turnos. Los negocios ven una reducción del 40% en inasistencias."
            }
          },
          {
            "@type": "Question",
            "name": "¿Pueden los clientes en #{city_data[:name]} reservar fuera del horario comercial?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "¡Sí! Los clientes pueden reservar 24/7, incluso cuando estás cerrado. Verán tus horarios disponibles y reservarán al instante."
            }
          },
          {
            "@type": "Question",
            "name": "¿BookrHub acepta Mercado Pago?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "¡Sí! BookrHub se integra con Mercado Pago para que puedas cobrar seña o el total de tus turnos directamente. Aceptamos tarjetas, Mercado Pago, y efectivo."
            }
          },
          {
            "@type": "Question",
            "name": "¿BookrHub cobra comisión?",
            "acceptedAnswer": {
              "@type": "Answer",
              "text": "Sin comisión. A diferencia de Fresha (20%), vos te quedás con el 100% de cada reserva."
            }
          }
        ]
      }
    JSON

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        "name": "Reservas para #{niche_data[:name_es]} en #{city_data[:name]}",
        "areaServed": {
          "@type": "City",
          "name": "#{city_data[:name]}",
          "addressRegion": "#{city_data[:region]}",
          "addressCountry": "#{country_data[:code]}"
        },
        "paymentAccepted": "Cash, Credit Card, Debit Card, Mercado Pago",
        "priceRange": "$-$$"
      }
      </script>
      <script type="application/ld+json">
      #{faq_schema}
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content">
        <p class="intro">Si manejás un #{niche_data[:singular_es]} en #{city_data[:name]}, sabés lo desafiante que puede ser gestionar turnos. Entre llamadas, clientes sin turno, y mensajes, mantener todo organizado es difícil. BookrHub facilita que tus clientes en #{city_data[:name]} reserven online mientras vos te concentrás en correr tu negocio.</p>

        <h2>Por Qué las #{niche_data[:name_es]} en #{city_data[:name]} Necesitan Reservas Online</h2>
        <p>Los clientes en #{city_data[:name]} esperan comodidad. Quieren reservar servicios de #{niche_data[:name_es].downcase} cuando les convenga, no solo durante tu horario comercial. Las reservas online les dan acceso 24/7 a tu agenda.</p>
        <ul class="feature-list">
          <li>Clientes en #{city_data[:name]} reservan cuando les resulta conveniente, de día o de noche</li>
          <li>Recordatorios automáticos por WhatsApp reducen inasistencias</li>
          <li>Gestioná la agenda de tu #{niche_data[:name_es].downcase} desde cualquier lugar</li>
          <li>Aceptá reservas incluso cuando estás ocupado o cerrado</li>
          <li>Integración con Mercado Pago para cobrar seña o pagos completos</li>
        </ul>

        <h2>Perfecto para #{niche_data[:name_es]} de #{city_data[:name]}</h2>
        <p>Ya sea que estés comenzando o lleves años sirviendo a #{city_data[:name]}, BookrHub te ayuda a gestionar los turnos de tu #{niche_data[:name_es].downcase} profesionalmente:</p>
        <ul class="feature-list">
          #{services_list}
        </ul>

        <h2>Empezá en #{city_data[:name]}</h2>
        <p>Unite a otros negocios de #{niche_data[:name_es].downcase} en #{city_data[:name]} que usan BookrHub:</p>
        <ol class="steps-list">
          <li><strong>Creá tu cuenta gratis</strong> - Toma menos de 2 minutos</li>
          <li><strong>Agregá tus servicios</strong> - Configurá tus ofertas de #{niche_data[:name_es].downcase}</li>
          <li><strong>Definí tu disponibilidad en #{city_data[:name]}</strong> - Establecé cuándo estás abierto</li>
          <li><strong>Compartí tu link de reservas</strong> - Con clientes en #{city_data[:name]}</li>
        </ol>

        <h2>Preguntas Frecuentes</h2>
        <div class="faq-block">
          <h3>¿BookrHub es gratis para #{niche_data[:name_es].downcase} en #{city_data[:name]}?</h3>
          <p>¡Sí! BookrHub ofrece un plan gratis para siempre. Obtené turnos ilimitados, reservas online, y recordatorios automáticos sin costo.</p>

          <h3>¿Cómo ayuda BookrHub a reducir inasistencias en #{city_data[:name]}?</h3>
          <p>BookrHub envía recordatorios automáticos por WhatsApp y email antes de los turnos. Los negocios ven una reducción del 40% en inasistencias.</p>

          <h3>¿Pueden los clientes en #{city_data[:name]} reservar fuera del horario comercial?</h3>
          <p>¡Sí! Los clientes pueden reservar 24/7, incluso cuando estás cerrado. Verán tus horarios disponibles y reservarán al instante.</p>

          <h3>¿BookrHub acepta Mercado Pago?</h3>
          <p>¡Sí! BookrHub se integra con Mercado Pago para que puedas cobrar seña o el total de tus turnos directamente. Aceptamos tarjetas, Mercado Pago, y efectivo.</p>

          <h3>¿BookrHub cobra comisión?</h3>
          <p>Sin comisión. A diferencia de Fresha (20%), vos te quedás con el 100% de cada reserva.</p>
        </div>

        <p>Empezá a aceptar reservas online para tu #{niche_data[:name_es].downcase} en #{city_data[:name]} hoy. Es gratis para empezar sin comisión en reservas.</p>
      </div>
    HTML

    {
      title: title,
      description: description,
      canonical: canonical,
      h1: "Sistema de Turnos para #{niche_data[:name_es]} en #{city_data[:name]}",
      content: content,
      schema: schema
    }
  end

  # How-to page template
  def self.howto_page(data:, locale:)
    sections_html = data[:sections].map do |section|
      <<~HTML
        <h2>#{section[:title]}</h2>
        <p>#{section[:content]}</p>
      HTML
    end.join("\n")

    canonical = (locale == "es") ? "/#{locale}/#{data[:slug]}" : "/#{data[:slug]}"

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": "#{data[:h1]}",
        "description": "#{data[:description]}",
        "author": {
          "@type": "Organization",
          "name": "BookrHub"
        },
        "publisher": {
          "@type": "Organization",
          "name": "BookrHub",
          "logo": {
            "@type": "ImageObject",
            "url": "https://www.bookrhub.com/images/logo.png"
          }
        }
      }
      </script>
    JSON

    locale_param = (locale == "es") ? "es" : "en"
    signup_url = "https://my.bookrhub.com/signup?locale=#{locale_param}"

    content = <<~HTML
      <div class="seo-content article-content">
        <p class="intro">#{data[:intro]}</p>
        #{sections_html}
        
        <div class="cta-box">
          <h3>#{(locale == "es") ? "¿Listo para Empezar?" : "Ready to Get Started?"}</h3>
          <p>#{(locale == "es") ? "BookrHub hace fácil implementar todo lo que aprendiste. Registrate gratis y empezá a aceptar reservas online hoy." : "BookrHub makes it easy to implement everything you've learned. Sign up free and start accepting online bookings today."}</p>
          <a href="#{signup_url}" class="btn btn-primary">#{(locale == "es") ? "Crear Cuenta Gratis" : "Create Free Account"}</a>
        </div>
      </div>
    HTML

    {
      title: data[:title],
      description: data[:description],
      canonical: canonical,
      h1: data[:h1],
      content: content,
      schema: schema
    }
  end

  # Comparison page template
  def self.comparison_page(competitor_key:, competitor_data:, locale:)
    locale_suffix = (locale == "es") ? "es" : ""
    locale_param = (locale == "es") ? "es" : "en"
    signup_url = "https://my.bookrhub.com/signup?locale=#{locale_param}"
    canonical = (locale == "es") ? "/#{locale}/vs-#{competitor_key}" : "/vs-#{competitor_key}"

    title = (locale == "es") ?
      "BookrHub vs #{competitor_data[:name]}: ¿Cuál es Mejor?" :
      "BookrHub vs #{competitor_data[:name]}: Which is Better?"

    description = (locale == "es") ?
      "Comparamos BookrHub con #{competitor_data[:name]}. Sin comisión, sin mensualidades, y mejor valor. Descubre por qué miles de negocios eligen BookrHub." :
      "We compare BookrHub with #{competitor_data[:name]}. No commission, no monthly fees, and better value. Discover why thousands of businesses choose BookrHub."

    strong_points = competitor_data[:strong_points].map { |p| "<li>+ #{p}</li>" }.join
    weak_points = competitor_data[:weak_points].map { |p| "<li>- #{p}</li>" }.join

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "ComparisonReview",
        "itemReviewed": {
          "@type": "SoftwareApplication",
          "name": "#{competitor_data[:name]}"
        },
        "reviewRating": {
          "@type": "Rating",
          "ratingValue": "4",
          "bestRating": "5"
        },
        "reviewBody": "Comparison of booking software features"
      }
      </script>
    JSON

    content = if locale == "es"
      <<~HTML
        <div class="seo-content">
          <p class="intro">#{competitor_data[:name]} es una plataforma popular de reservas, pero ¿es la mejor opción para tu negocio? Comparamos las características, precios, y beneficios de #{competitor_data[:name]} con BookrHub.</p>

          <h2>Sobre #{competitor_data[:name]}</h2>
          <p>#{competitor_data[:description]}</p>

          <div class="comparison-grid">
            <div class="comparison-pros">
              <h3>Fortalezas de #{competitor_data[:name]}</h3>
              <ul>#{strong_points}</ul>
            </div>
            <div class="comparison-cons">
              <h3>Debilidades de #{competitor_data[:name]}</h3>
              <ul>#{weak_points}</ul>
            </div>
          </div>

          <h2>BookrHub vs #{competitor_data[:name]}</h2>
          <table class="comparison-table">
            <tr>
              <th>Característica</th>
              <th>BookrHub</th>
              <th>#{competitor_data[:name]}</th>
            </tr>
            <tr>
              <td>Comisión</td>
              <td><strong>Sin comisión</strong></td>
              <td>#{competitor_data[:commissions]}</td>
            </tr>
            <tr>
              <td>Plan gratis</td>
              <td><strong>Completamente gratis</strong></td>
              <td>#{competitor_data[:free_plan]}</td>
            </tr>
            <tr>
              <td>Recordatorios WhatsApp</td>
              <td><strong>Incluido gratis</strong></td>
              <td>Variable</td>
            </tr>
            <tr>
              <td>Reservas ilimitadas</td>
              <td><strong>Sí</strong></td>
              <td>Sí</td>
            </tr>
            <tr>
              <td>Página de reservas personalizada</td>
              <td><strong>Sí</strong></td>
              <td>Sí</td>
            </tr>
          </table>

          <h2>¿Por Qué Elegir BookrHub?</h2>
          <ul class="feature-list">
            <li><strong>Sin comisiones:</strong> #{competitor_data[:name]} cobra #{competitor_data[:commissions].downcase}. BookrHub es completamente gratis.</li>
            <li><strong>Sin mensualidades:</strong> Empezá gratis y seguí gratis. Sin costos ocultos.</li>
            <li><strong>Recordatorios por WhatsApp:</strong> Incluidos automáticamente en el plan gratis.</li>
            <li><strong>Diseñado para servicios:</strong> BookrHub está construido específicamente para negocios de servicios como el tuyo.</li>
          </ul>

          <div class="cta-box">
            <h3>Probá BookrHub Gratis</h3>
            <p>Únete a miles de negocios que ya switchearon a BookrHub. Sin riesgo, sin compromiso.</p>
            <a href="#{signup_url}" class="btn btn-primary">Crear Cuenta Gratis</a>
          </div>
        </div>
      HTML
    else
      <<~HTML
        <div class="seo-content">
          <p class="intro">#{competitor_data[:name]} is a popular booking platform, but is it the best choice for your business? We compare features, pricing, and benefits of #{competitor_data[:name]} with BookrHub.</p>

          <h2>About #{competitor_data[:name]}</h2>
          <p>#{competitor_data[:description]}</p>

          <div class="comparison-grid">
            <div class="comparison-pros">
              <h3>#{competitor_data[:name]}'s Strengths</h3>
              <ul>#{strong_points}</ul>
            </div>
            <div class="comparison-cons">
              <h3>#{competitor_data[:name]}'s Weaknesses</h3>
              <ul>#{weak_points}</ul>
            </div>
          </div>

          <h2>BookrHub vs #{competitor_data[:name]}</h2>
          <table class="comparison-table">
            <tr>
              <th>Feature</th>
              <th>BookrHub</th>
              <th>#{competitor_data[:name]}</th>
            </tr>
            <tr>
              <td>Commission</td>
              <td><strong>Zero commission</strong></td>
              <td>#{competitor_data[:commissions]}</td>
            </tr>
            <tr>
              <td>Free plan</td>
              <td><strong>Completely free</strong></td>
              <td>#{competitor_data[:free_plan]}</td>
            </tr>
            <tr>
              <td>Reminders</td>
              <td><strong>Included free</strong></td>
              <td>Varies</td>
            </tr>
            <tr>
              <td>Unlimited bookings</td>
              <td><strong>Yes</strong></td>
              <td>Yes</td>
            </tr>
            <tr>
              <td>Custom booking page</td>
              <td><strong>Yes</strong></td>
              <td>Yes</td>
            </tr>
          </table>

          <h2>Why Choose BookrHub?</h2>
          <ul class="feature-list">
            <li><strong>No commission:</strong> #{competitor_data[:name]} charges #{competitor_data[:commissions].downcase}. BookrHub is completely free.</li>
            <li><strong>No monthly fees:</strong> Start free and stay free. No hidden costs.</li>
            <li><strong>Reminders:</strong> Included automatically in the free plan.</li>
            <li><strong>Built for service businesses:</strong> BookrHub is designed specifically for appointment-based service businesses like yours.</li>
          </ul>

          <div class="cta-box">
            <h3>Try BookrHub Free</h3>
            <p>Join thousands of businesses who've switched to BookrHub. No risk, no commitment.</p>
            <a href="#{signup_url}" class="btn btn-primary">Create Free Account</a>
          </div>
        </div>
      HTML
    end

    {
      title: title,
      description: description,
      canonical: canonical,
      h1: (locale == "es") ? "BookrHub vs #{competitor_data[:name]}" : "BookrHub vs #{competitor_data[:name]}",
      content: content,
      schema: schema
    }
  end

  # General SEO page template (English)
  def self.general_page_en(data)
    canonical = "/#{data[:slug]}"
    signup_url = "https://my.bookrhub.com/signup?locale=en"

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": "#{data[:h1]}",
        "description": "#{data[:description]}",
        "author": {
          "@type": "Organization",
          "name": "BookrHub"
        },
        "publisher": {
          "@type": "Organization",
          "name": "BookrHub",
          "logo": {
            "@type": "ImageObject",
            "url": "https://www.bookrhub.com/images/logo.png"
          }
        }
      }
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content article-content">
        <p class="intro">#{data[:intro]}</p>

        <h2>Why BookrHub?</h2>
        <p>BookrHub is designed specifically for service businesses that want to grow. Here's why thousands of businesses trust us:</p>
        <ul class="feature-list">
          <li><strong>Zero Commission:</strong> Keep 100% of what you earn. Unlike competitors who charge 5-20% per booking.</li>
          <li><strong>No Monthly Fees:</strong> Start free and stay free. No hidden costs or surprise charges.</li>
          <li><strong>Reminders:</strong> Automatic reminders reduce no-shows by up to 50%.</li>
          <li><strong>24/7 Online Booking:</strong> Clients book whenever it's convenient for them.</li>
          <li><strong>Mobile-Friendly:</strong> Manage everything from your phone or computer.</li>
        </ul>

        <h2>How to Get Started</h2>
        <p>Getting started with BookrHub takes less than 5 minutes:</p>
        <ol class="steps-list">
          <li><strong>Create your free account</strong> - No credit card required</li>
          <li><strong>Add your services</strong> - List what you offer and your prices</li>
          <li><strong>Set your availability</strong> - Define when you're open for appointments</li>
          <li><strong>Share your booking link</strong> - Add it to social media, your website, or WhatsApp</li>
        </ol>

        <h2>Who Uses BookrHub?</h2>
        <p>BookrHub is perfect for any service business that takes appointments:</p>
        <ul class="feature-list">
          <li>Hair salons and barbershops</li>
          <li>Nail salons and beauty studios</li>
          <li>Spas and massage therapists</li>
          <li>Personal trainers and fitness coaches</li>
          <li>Cleaning services</li>
          <li>And many more service businesses</li>
        </ul>

        <h2>Trusted by Thousands</h2>
        <p>Businesses across Argentina, New Zealand, Australia, and beyond trust BookrHub to manage their appointments. Join them and see the difference a good booking system can make.</p>

        <div class="cta-box">
          <h3>Ready to Simplify Your Booking?</h3>
          <p>Join thousands of businesses using BookrHub. It's free, it's easy, and it works.</p>
          <a href="#{signup_url}" class="btn btn-primary">Create Free Account</a>
        </div>
      </div>
    HTML

    {
      title: data[:title],
      description: data[:description],
      canonical: canonical,
      h1: data[:h1],
      content: content,
      schema: schema
    }
  end

  # General SEO page template (Spanish)
  def self.general_page_es(data)
    canonical = "/#{data[:slug]}"
    signup_url = "https://my.bookrhub.com/signup?locale=es"

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Article",
        "headline": "#{data[:h1]}",
        "description": "#{data[:description]}",
        "author": {
          "@type": "Organization",
          "name": "BookrHub"
        },
        "publisher": {
          "@type": "Organization",
          "name": "BookrHub",
          "logo": {
            "@type": "ImageObject",
            "url": "https://www.bookrhub.com/images/logo.png"
          }
        }
      }
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content article-content">
        <p class="intro">#{data[:intro]}</p>

        <h2>Por Qué BookrHub?</h2>
        <p>BookrHub está diseñado específicamente para negocios de servicios que quieren crecer. Por esto miles de negocios confían en nosotros:</p>
        <ul class="feature-list">
          <li><strong>Sin Comisión:</strong> Guardá el 100% de lo que ganás. A diferencia de competidores que cobran 5-20% por reserva.</li>
          <li><strong>Sin Mensualidades:</strong> Empezá gratis y seguí gratis. Sin costos ocultos ni sorpresas.</li>
          <li><strong>Recordatorios por WhatsApp:</strong> Automáticos, reducen las inasistencias hasta en un 50%.</li>
          <li><strong>Reservas Online 24/7:</strong> Los clientes reservan cuando les resulta conveniente.</li>
          <li><strong>Compatible con Móvil:</strong> Gestioná todo desde tu celular o computadora.</li>
        </ul>

        <h2>Cómo Empezar</h2>
        <p>Empezar con BookrHub toma menos de 5 minutos:</p>
        <ol class="steps-list">
          <li><strong>Creá tu cuenta gratis</strong> - No requiere tarjeta de crédito</li>
          <li><strong>Agregá tus servicios</strong> - Listá lo que ofrecés y tus precios</li>
          <li><strong>Definí tu disponibilidad</strong> - Establecé cuándo estás abierto para turnos</li>
          <li><strong>Compartí tu link de reservas</strong> - Agregalo a redes sociales, tu web, o WhatsApp</li>
        </ol>

        <h2>Quién Usa BookrHub?</h2>
        <p>BookrHub es perfecto para cualquier negocio de servicios que toma turnos:</p>
        <ul class="feature-list">
          <li>Peluquerías y barberías</li>
          <li>Salones de uñas y estudios de belleza</li>
          <li>Spas y terapeutas de masaje</li>
          <li>Entrenadores personales y coaches de fitness</li>
          <li>Servicios de limpieza</li>
          <li>Y muchos más negocios de servicios</li>
        </ul>

        <h2>Confiado por Miles</h2>
        <p>Negocios en Argentina, Nueva Zelanda, Australia, y más confían en BookrHub para gestionar sus turnos. Unite a ellos y ve la diferencia que un buen sistema de reservas puede hacer.</p>

        <div class="cta-box">
          <h3>Listo para Simplificar Tus Reservas?</h3>
          <p>Unite a miles de negocios que usan BookrHub. Es gratis, es fácil, y funciona.</p>
          <a href="#{signup_url}" class="btn btn-primary">Crear Cuenta Gratis</a>
        </div>
      </div>
    HTML

    {
      title: data[:title],
      description: data[:description],
      canonical: canonical,
      h1: data[:h1],
      content: content,
      schema: schema
    }
  end

  def self.use_cases_page(locale:)
    locale_param = (locale == "es") ? "es" : "en"
    signup_url = "https://my.bookrhub.com/signup?locale=#{locale_param}"

    # Build niche links
    niche_links = SEOConfig::NICHES.map do |key, data|
      name = (locale == "es") ? data[:name_es] : data[:name_en]
      url = (locale == "es") ? "/sistema-de-turnos-para-#{key}" : "/booking-system-for-#{key}"
      "<li><a href=\"https://www.bookrhub.com#{url}\">#{name}</a></li>"
    end.join

    # Build country + city links
    city_links = SEOConfig::CITIES.map do |country_key, country_data|
      cities_html = country_data[:cities].map do |city|
        city_name = city[:name]
        if locale == "es"
          niche_links_sample = SEOConfig::NICHES.first[1][:name_es]
          "<li><a href=\"https://www.bookrhub.com/sistema-de-turnos-para-barbers-en-#{city[:slug]}\">#{city_name}</a></li>"
        else
          niche_links_sample = SEOConfig::NICHES.first[1][:name_en]
          "<li><a href=\"https://www.bookrhub.com/booking-system-for-barbers-in-#{city[:slug]}\">#{city_name}</a></li>"
        end
      end.join
      "<div class=\"use-cases-country\"><h3>#{country_data[:name]}</h3><ul>#{cities_html}</ul></div>"
    end.join

    # Build general page links
    general_pages = if locale == "es"
      [
        ["Reservas Gratis", "/reservas-gratis"],
        ["Por Qué BookrHub", "/por-que-bookrhub"],
        ["Mejor Sistema de Reservas", "/mejor-sistema-de-reservas"],
        ["Turnos Online", "/sistema-de-reservas-online-gratis"]
      ]
    else
      [
        ["Free Booking", "/free-booking"],
        ["Why BookrHub", "/why-bookrhub"],
        ["Best Booking System", "/best-booking-system"],
        ["Online Booking", "/online-booking-system"]
      ]
    end
    general_links = general_pages.map { |name, slug| "<li><a href=\"https://www.bookrhub.com#{slug}\">#{name}</a></li>" }.join

    # Build comparison links
    comparison_links = SEOConfig::COMPETITORS.map do |key, data|
      if locale == "es"
        "<li><a href=\"https://www.bookrhub.com/alternativa-a-#{key}\">BookrHub vs #{data[:name]}</a></li>"
      else
        "<li><a href=\"https://www.bookrhub.com/vs-#{key}\">BookrHub vs #{data[:name]}</a></li>"
      end
    end.join

    canonical = (locale == "es") ? "/casos-de-uso" : "/use-cases"

    schema = <<~JSON
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "CollectionPage",
        "name": "#{(locale == "es") ? "Casos de Uso - BookrHub" : "Use Cases - BookrHub"}",
        "description": "#{(locale == "es") ? "Encontrá el sistema de turnos perfecto para tu industria" : "Find the perfect booking system for your industry"}"
      }
      </script>
    JSON

    content = <<~HTML
      <div class="seo-content use-cases-content">
        <p class="intro">#{(locale == "es") ? "Cada industria tiene necesidades únicas de reservas. Encontrá la solución perfecta para tu tipo de negocio." : "Every industry has unique booking needs. Find the perfect solution for your type of business."}</p>

        <h2>#{(locale == "es") ? "Por Industria" : "By Industry"}</h2>
        <div class="use-cases-grid">
          <ul class="use-cases-list">
            #{niche_links}
          </ul>
        </div>

        <h2>#{(locale == "es") ? "Por Ubicación" : "By Location"}</h2>
        <div class="use-cases-cities">
          #{city_links}
        </div>

        <h2>#{(locale == "es") ? "Recursos" : "Resources"}</h2>
        <div class="use-cases-grid">
          <ul class="use-cases-list">
            #{general_links}
          </ul>
        </div>

        <h2>#{(locale == "es") ? "Comparativas" : "Comparisons"}</h2>
        <div class="use-cases-grid">
          <ul class="use-cases-list">
            #{comparison_links}
          </ul>
        </div>

        <div class="cta-box">
          <h3>#{(locale == "es") ? "¿Listo para Empezar?" : "Ready to Get Started?"}</h3>
          <p>#{(locale == "es") ? "Unite a miles de negocios que ya usan BookrHub." : "Join thousands of businesses already using BookrHub."}</p>
          <a href="#{signup_url}" class="btn btn-primary">#{(locale == "es") ? "Crear Cuenta Gratis" : "Create Free Account"}</a>
        </div>
      </div>
    HTML

    {
      title: (locale == "es") ? "Casos de Uso | BookrHub" : "Use Cases | BookrHub",
      description: (locale == "es") ? "Encontrá el sistema de turnos perfecto para tu industria y ubicación" : "Find the perfect booking system for your industry and location",
      canonical: canonical,
      h1: (locale == "es") ? "Sistemas de Turnos por Industria y Ubicación" : "Booking Systems by Industry and Location",
      content: content,
      schema: schema
    }
  end
end
