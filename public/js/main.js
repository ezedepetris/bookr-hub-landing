(function() {
  'use strict';

  function ready(fn) {
    if (document.readyState !== 'loading') {
      fn();
    } else {
      document.addEventListener('DOMContentLoaded', fn);
    }
  }

  ready(function() {

    // Pricing toggle (monthly/annual)
    var pricingBtns = document.querySelectorAll('.pricing-toggle-btn');
    var planPeriods = document.querySelectorAll('.plan-period[data-monthly][data-annual]');
    var businessAnnualBonus = document.getElementById('pricing-business-annual-bonus');

    function setPricingInterval(interval) {
      var isAnnual = interval === 'annual';
      pricingBtns.forEach(function(btn) {
        var active = btn.dataset.interval === interval;
        btn.classList.toggle('active', active);
        btn.setAttribute('aria-pressed', active ? 'true' : 'false');
      });
      planPeriods.forEach(function(p) {
        p.textContent = p.dataset[interval] || p.textContent;
      });
      document.querySelectorAll('.pricing-price-toggle').forEach(function(el) {
        var value = el.getAttribute(isAnnual ? 'data-annual' : 'data-monthly');
        if (value) el.textContent = value;
      });
      if (businessAnnualBonus) {
        businessAnnualBonus.hidden = !isAnnual;
      }
      document.querySelectorAll('.pricing-signup-link[data-signup-base]').forEach(function(link) {
        var base = link.getAttribute('data-signup-base');
        link.href = base + (isAnnual ? '&interval=annual' : '&interval=month');
      });
    }

    if (pricingBtns.length) {
      pricingBtns.forEach(function(btn) {
        btn.addEventListener('click', function() {
          setPricingInterval(this.dataset.interval);
        });
      });
      setPricingInterval('annual');
    }

    // Screenshot tab switcher
    var tabButtons = document.querySelectorAll('.tab-button');
    var screenshotGrid = document.getElementById('screenshot-grid');
    var screenshotGridCustomer = document.getElementById('screenshot-grid-customer');

    if (tabButtons.length && screenshotGrid) {
      tabButtons.forEach(function(button) {
        button.addEventListener('click', function() {
          tabButtons.forEach(function(b) { b.classList.remove('active'); });
          this.classList.add('active');
          var tab = this.dataset.tab;
          if (tab === 'admin') {
            screenshotGrid.style.display = '';
            if (screenshotGridCustomer) screenshotGridCustomer.style.display = 'none';
          } else {
            screenshotGrid.style.display = 'none';
            if (screenshotGridCustomer) screenshotGridCustomer.style.display = '';
          }
        });
      });
    }

    // FAQ accordion
    document.querySelectorAll('.faq-question').forEach(function(button) {
      button.addEventListener('click', function() {
        var item = this.parentElement;
        var isActive = item.classList.contains('active');
        document.querySelectorAll('.faq-item').forEach(function(i) { i.classList.remove('active'); });
        if (!isActive) item.classList.add('active');
      });
    });

    // Templates carousel
    var templatesTrack = document.getElementById('templates-carousel-track');
    var templatesPrev = document.querySelector('.templates-carousel-prev');
    var templatesNext = document.querySelector('.templates-carousel-next');

    if (templatesTrack && templatesPrev && templatesNext) {
      function updateTemplatesCarouselButtons() {
        var st = templatesTrack;
        templatesPrev.disabled = st.scrollLeft <= 0;
        templatesNext.disabled = st.scrollLeft >= st.scrollWidth - st.clientWidth - 2;
      }
      templatesPrev.addEventListener('click', function() {
        templatesTrack.scrollBy({ left: -templatesTrack.clientWidth, behavior: 'smooth' });
      });
      templatesNext.addEventListener('click', function() {
        templatesTrack.scrollBy({ left: templatesTrack.clientWidth, behavior: 'smooth' });
      });
      templatesTrack.addEventListener('scroll', updateTemplatesCarouselButtons);
      updateTemplatesCarouselButtons();
    }

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(function(anchor) {
      anchor.addEventListener('click', function(e) {
        var href = this.getAttribute('href');
        if (href === '#') return;
        e.preventDefault();
        var target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });

    // Scroll animations with Intersection Observer
    var observerOptions = { threshold: 0.1, rootMargin: '0px 0px -50px 0px' };
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, observerOptions);

    document.querySelectorAll('.animate-on-scroll').forEach(function(el) {
      observer.observe(el);
    });

    // Mobile menu toggle
    var mobileToggle = document.getElementById('mobile-menu-toggle');
    var mobileMenu = document.getElementById('mobile-menu');

    if (mobileToggle && mobileMenu) {
      mobileToggle.addEventListener('click', function() {
        mobileToggle.classList.toggle('active');
        mobileMenu.classList.toggle('active');
        document.body.style.overflow = mobileMenu.classList.contains('active') ? 'hidden' : '';
      });

      mobileMenu.querySelectorAll('a').forEach(function(link) {
        link.addEventListener('click', function() {
          mobileToggle.classList.remove('active');
          mobileMenu.classList.remove('active');
          document.body.style.overflow = '';
        });
      });
    }

    // Scroll progress bar
    var scrollProgress = document.getElementById('scroll-progress');
    function updateScrollProgress() {
      if (!scrollProgress) return;
      var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
      var height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      scrollProgress.style.transform = 'scaleX(' + (height ? scrollTop / height : 0) + ')';
    }
    if (scrollProgress) {
      window.addEventListener('scroll', updateScrollProgress, { passive: true });
      updateScrollProgress();
    }

    // Nav scroll effect
    var mainNav = document.getElementById('main-nav');
    function updateNavScroll() {
      if (mainNav) mainNav.classList.toggle('nav-scrolled', window.scrollY > 80);
    }
    if (mainNav) {
      window.addEventListener('scroll', updateNavScroll, { passive: true });
      updateNavScroll();
    }

    // Floating CTA visibility
    var floatingCta = document.getElementById('floating-cta');
    function updateFloatingCta() {
      if (!floatingCta) return;
      var hero = document.querySelector('.hero');
      var heroBottom = hero ? hero.offsetTop + hero.offsetHeight : 400;
      var show = window.scrollY > heroBottom - 100;
      floatingCta.classList.toggle('floating-cta-visible', show);
      floatingCta.setAttribute('aria-hidden', show ? 'false' : 'true');
    }
    if (floatingCta) {
      window.addEventListener('scroll', updateFloatingCta, { passive: true });
      updateFloatingCta();
    }

    // Back to top
    var backToTop = document.getElementById('back-to-top');
    function updateBackToTop() {
      if (backToTop) backToTop.classList.toggle('back-to-top-visible', window.scrollY > 600);
    }
    if (backToTop) {
      window.addEventListener('scroll', updateBackToTop, { passive: true });
      updateBackToTop();
      backToTop.addEventListener('click', function() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

  });
})();
