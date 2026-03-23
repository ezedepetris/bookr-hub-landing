#!/usr/bin/env ruby
# Script to update all programmatic SEO pages with:
# 1. FAQ sections
# 2. FAQ schema
# 3. "Last updated" date
# 4. Fix WhatsApp -> Email reminders

require "fileutils"
require "json"

SEO_DIR = File.join(__dir__, "..", "public", "seo")

def get_industry_faqs(industry)
  case industry.downcase
  when "barbers", "barber"
    {
      "question1" => "How do barbers use BookrHub for online booking?",
      "answer1" => "Barbers sign up for free, customize their booking page with services like cuts, fades, and beard trims, then share their booking link. Clients can book 24/7, and barbers receive email notifications for each appointment.",
      "question2" => "Does BookrHub charge commission on barber bookings?",
      "answer2" => "No, BookrHub charges zero commission on all bookings. Unlike Fresha which takes 20% of new client bookings, you keep 100% of your revenue.",
      "question3" => "Can clients in Auckland book barbers through BookrHub?",
      "answer3" => "Yes, clients can book your barber services online from anywhere. BookrHub works globally and accepts bookings in any time zone.",
      "question4" => "How do I remind clients about their barber appointments?",
      "answer4" => "BookrHub sends automatic email reminders before appointments, reducing no-shows by up to 40%. You can customize reminder timing in your settings.",
      "question5" => "Can I use BookrHub on my mobile phone?",
      "answer5" => "Yes, BookrHub works on any device. Manage your bookings, view your calendar, and update your availability from your phone or computer."
    }
  when "hair-salons", "hair salons", "beauty-salons", "beauty salons"
    {
      "question1" => "How do hair salons use BookrHub for online booking?",
      "answer1" => "Hair salons create a free booking page, add their services and prices, set their availability, and share the link with clients. Clients book their favorite stylist online.",
      "question2" => "Is BookrHub really free for hair salons?",
      "answer2" => "Yes, BookrHub offers a free plan with no commission. Paid plans start at affordable monthly rates for additional features.",
      "question3" => "Can multiple stylists use the same BookrHub account?",
      "answer3" => "Yes, BookrHub supports multiple staff members. Each stylist can have their own schedule and services on the same booking page.",
      "question4" => "How do clients book hair salon appointments online?",
      "answer4" => "Clients visit your BookrHub page, select a service, choose a time slot, and confirm. They receive email confirmation and reminders automatically.",
      "question5" => "Does BookrHub work with my salon's existing website?",
      "answer5" => "Yes, you can embed your booking page on your existing website or use your BookrHub page as your main online presence."
    }
  when "nail-salons", "nail salons"
    {
      "question1" => "How do nail salons benefit from online booking?",
      "answer1" => "Online booking reduces phone tag and allows clients to book manicures and pedicures anytime. Studies show businesses with online booking see 40% fewer no-shows.",
      "question2" => "Can I set different prices for nail services?",
      "answer2" => "Yes, BookrHub lets you set individual prices for each service. You can also offer packages and add-ons.",
      "question3" => "How do clients know when their nail appointment is confirmed?",
      "answer3" => "Clients receive instant email confirmation and automatic reminders before their appointment.",
      "question4" => "Can nail technicians manage their own schedules?",
      "answer4" => "Yes, each technician can have their own calendar and availability settings within your BookrHub account.",
      "question5" => "Is BookrHub free to use for nail salons?",
      "answer5" => "BookrHub offers a free plan with no commission. Premium features are available on paid plans."
    }
  when "massage-spa", "spa", "massage"
    {
      "question1" => "How does BookrHub help massage and spa businesses?",
      "answer1" => "BookrHub lets clients book massage, spa, and wellness appointments online 24/7. You get automatic reminders, calendar management, and zero commission.",
      "question2" => "Can clients book specific massage therapists?",
      "answer2" => "Yes, clients can select their preferred therapist when booking. Each therapist has their own schedule within your BookrHub account.",
      "question3" => "What types of spa services can I offer on BookrHub?",
      "answer3" => "You can offer any service: deep tissue massage, facials, body treatments, acupuncture, and more. Each service can have its own duration and price.",
      "question4" => "How do I reduce no-shows for spa appointments?",
      "answer4" => "BookrHub sends automatic email reminders to clients before their appointment, reducing no-shows by up to 40%.",
      "question5" => "Can I take payments through BookrHub?",
      "answer5" => "Yes, BookrHub supports online payments. You can require prepayment for certain services or accept payment at the time of visit."
    }
  when "personal-trainers", "personal trainers", "fitness"
    {
      "question1" => "How do personal trainers use BookrHub?",
      "answer1" => "Personal trainers create a booking page, add training services like one-on-one sessions or group classes, and let clients book online. Perfect for gym owners and independent trainers.",
      "question2" => "Can clients book personal training sessions online?",
      "answer2" => "Yes, clients can view your availability and book training sessions directly through your BookrHub page, 24/7.",
      "question3" => "Does BookrHub work for fitness studios and gyms?",
      "answer3" => "Yes, fitness studios, CrossFit boxes, yoga studios, and any fitness business can use BookrHub for online scheduling.",
      "question4" => "How do I send workout reminders?",
      "answer4" => "BookrHub sends automatic email reminders before scheduled sessions. You can customize when reminders are sent.",
      "question5" => "Can I offer online training bookings?",
      "answer5" => "Yes, you can offer both in-person and online training sessions. Add video call links or location details to each booking."
    }
  when "cleaners", "cleaning"
    {
      "question1" => "How do cleaning businesses use BookrHub?",
      "answer1" => "Cleaning businesses create a booking page, add their services (residential, commercial, deep clean), set availability, and let clients book online.",
      "question2" => "Can clients schedule recurring cleaning appointments?",
      "answer2" => "While BookrHub doesn't automatically create recurring bookings, clients can easily book their next appointment after each service is complete.",
      "question3" => "How do I manage multiple cleaning teams?",
      "answer3" => "BookrHub supports multiple staff members. Assign services to specific team members and track bookings on your calendar.",
      "question4" => "Can cleaning clients pay online?",
      "answer4" => "Yes, BookrHub supports online payments. Require deposits or full payment for commercial cleaning jobs.",
      "question5" => "Is BookrHub free for cleaning businesses?",
      "answer5" => "Yes, BookrHub offers a free plan with no commission. Paid plans add features like multiple staff and custom branding."
    }
  else
    {
      "question1" => "How does BookrHub work for online booking?",
      "answer1" => "BookrHub lets businesses create a free booking page where clients can schedule appointments 24/7. You get automatic email reminders, calendar management, and zero commission on bookings.",
      "question2" => "Is BookrHub really free?",
      "answer2" => "Yes, BookrHub offers a free plan with no commission on bookings. Premium features are available on paid plans starting at affordable monthly rates.",
      "question3" => "How do clients book appointments?",
      "answer3" => "Clients visit your BookrHub page, select a service, choose a time that works for them, and confirm. They receive email confirmation instantly.",
      "question4" => "Does BookrHub send reminders?",
      "answer4" => "Yes, BookrHub sends automatic email reminders to reduce no-shows. Studies show this reduces missed appointments by up to 40%.",
      "question5" => "Can I use BookrHub for my business?",
      "answer5" => "BookrHub works for any appointment-based business including salons, barbers, fitness trainers, cleaners, photographers, and more."
    }
  end
end

def get_faqs_html(faqs)
  faq_items = faqs.map do |key, question|
    answer_key = key.sub("question", "answer")
    answer = faqs[answer_key]
    <<~HTML
      <details class="faq-item">
        <summary class="faq-question">#{question}</summary>
        <div class="faq-answer">#{answer}</div>
      </details>
    HTML
  end.join("\n")

  <<~FAQ_SECTION
    <!-- FAQ Section -->
    <section class="faq-section">
      <div class="container">
        <h2>Frequently Asked Questions</h2>
        <div class="faq-container">
          #{faq_items}
        </div>
      </div>
    </section>
    
    <style>
      .faq-section {
        background: #f8f9fa;
        padding: 60px 0;
      }
      .faq-section h2 {
        text-align: center;
        margin-bottom: 40px;
        color: #1a1a2e;
      }
      .faq-container {
        max-width: 800px;
        margin: 0 auto;
      }
      .faq-item {
        background: white;
        border-radius: 8px;
        margin-bottom: 15px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        overflow: hidden;
      }
      .faq-question {
        padding: 20px;
        cursor: pointer;
        font-weight: 600;
        color: #1a1a2e;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .faq-question::after {
        content: '+';
        font-size: 1.5rem;
        color: #667eea;
        transition: transform 0.3s;
      }
      .faq-item[open] .faq-question::after {
        transform: rotate(45deg);
      }
      .faq-answer {
        padding: 0 20px 20px;
        color: #555;
        line-height: 1.7;
      }
    </style>
    
    <script>
      document.querySelectorAll('.faq-item summary').forEach(summary => {
        summary.addEventListener('click', (e) => {
          e.preventDefault();
          const details = summary.parentElement;
          details.hasAttribute('open') ? details.removeAttribute('open') : details.setAttribute('open', '');
        });
      });
    </script>
  FAQ_SECTION
end

def get_faq_schema(faqs, industry)
  faq_entity = []
  (1..5).each do |i|
    q_key = "question#{i}"
    a_key = "answer#{i}"
    if faqs[q_key] && faqs[a_key]
      faq_entity << {
        "@type" => "Question",
        "name" => faqs[q_key],
        "acceptedAnswer" => {
          "@type" => "Answer",
          "text" => faqs[a_key]
        }
      }
    end
  end

  {
    "@context" => "https://schema.org",
    "@type" => "FAQPage",
    "mainEntity" => faq_entity
  }.to_json
end

def determine_industry(file_path)
  path = file_path.downcase

  if path.include?("barber")
    "barbers"
  elsif path.include?("hair-salon") || path.include?("hair-salon")
    "hair-salons"
  elsif path.include?("beauty-salon")
    "beauty-salons"
  elsif path.include?("nail-salon")
    "nail-salons"
  elsif path.include?("massage-spa") || path.include?("spa")
    "massage-spa"
  elsif path.include?("personal-trainer") || path.include?("fitness")
    "personal-trainers"
  elsif path.include?("cleaner")
    "cleaners"
  else
    "general"
  end
end

def extract_city_and_industry(file_path)
  basename = File.basename(file_path, ".html")

  industries = ["barbers", "hair-salons", "beauty-salons", "nail-salons", "massage-spa", "personal-trainers", "cleaners", "barber", "hair-salon", "beauty-salon", "nail-salon", "spa", "fitness"]

  industry = industries.find { |i| basename.include?(i) } || "business"

  city = basename
    .sub(/^booking-system-for-/, "")
    .sub(/-in-.*$/, "")
    .split("-")
    .map(&:capitalize)
    .join(" ")

  city_from_path = basename.match(/-in-(.+)$/)
  city = city_from_path ? city_from_path[1].split("-").map(&:capitalize).join(" ") : "Your Area"

  [city, industry]
end

def update_file(file_path)
  return unless File.extname(file_path) == ".html"

  content = File.read(file_path)

  # Skip if already has FAQ section
  return if content.include?("faq-section")

  # Determine industry and city for FAQ content
  industry = determine_industry(file_path)
  city, _ = extract_city_and_industry(file_path)
  faqs = get_industry_faqs(industry)

  # Replace WhatsApp with Email
  content = content.gsub(/WhatsApp/i, "Email")
  content = content.gsub(/whatsapp/i, "email")

  # Update meta description to remove WhatsApp
  content = content.gsub(
    /<meta name="description" content="[^"]*WhatsApp[^"]*">/i,
    '<meta name="description" content="Looking for a booking system? BookrHub lets clients book online 24/7 with automatic email reminders. Free to start with no commission.">'
  )

  # Add FAQ schema after existing structured data
  faq_schema = get_faq_schema(faqs, industry)
  existing_schema_end = content.include?("</script>") ? content.index("</script>", content.index("LocalBusiness") || 0) : nil
  if existing_schema_end
    insert_pos = content.index("</script>", existing_schema_end + 1) || existing_schema_end
    content = content.insert(insert_pos + "</script>".length, "\n\n  <!-- FAQ Schema -->\n  <script type=\"application/ld+json\">\n#{faq_schema}\n  </script>")
  end

  # Add FAQ section before CTA section
  faq_html = get_faqs_html(faqs)
  if content.include?('<section class="cta-section">')
    content = content.sub('<section class="cta-section">', faq_html + "\n\n    <section class=\"cta-section\">")
  end

  # Add last updated date to footer
  last_updated = "Last updated: March 2026"
  if content.include?("&copy; 2026 BookrHub")
    content = content.sub("&copy; 2026 BookrHub", "&copy; 2026 BookrHub | #{last_updated}")
  end

  File.write(file_path, content)
  puts "Updated: #{File.basename(file_path)}"
end

def process_directory(dir)
  count = 0
  Dir.glob(File.join(dir, "**", "*.html")).each do |file|
    update_file(file)
    count += 1
  end
  count
end

puts "Updating SEO pages..."
puts "=" * 50

en_count = process_directory(File.join(SEO_DIR, "en"))
es_count = process_directory(File.join(SEO_DIR, "es"))

puts "=" * 50
puts "Done! Updated #{en_count + es_count} files"
puts "  - #{en_count} English pages"
puts "  - #{es_count} Spanish pages"
