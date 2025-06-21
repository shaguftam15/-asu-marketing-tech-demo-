// Marketing Technology Demo - Enhanced Analytics & Tracking
document.addEventListener('DOMContentLoaded', function() {
    // Initialize dataLayer for Google Tag Manager
    window.dataLayer = window.dataLayer || [];
    
    // Initialize Segment Analytics (Mock CDP)
    if (window.analytics) {
        window.analytics.ready(function() {
            console.log('Segment Analytics loaded successfully');
        });
    }
    
    // Cookie Consent Management
    const cookieBanner = document.getElementById('cookie-banner');
    const acceptCookies = document.getElementById('accept-cookies');
    const declineCookies = document.getElementById('decline-cookies');
    
    // Check if user has already made a cookie choice
    const cookieConsent = localStorage.getItem('cookieConsent');
    
    if (!cookieConsent && cookieBanner) {
        setTimeout(() => {
            cookieBanner.classList.add('show');
        }, 2000);
    }
    
    // Handle cookie consent
    if (acceptCookies) {
        acceptCookies.addEventListener('click', function() {
            localStorage.setItem('cookieConsent', 'accepted');
            localStorage.setItem('cookieConsentDate', new Date().toISOString());
            cookieBanner.classList.remove('show');
            
            // Track consent acceptance
            trackEvent('cookie_consent', 'accepted', 'user_preference');
            
            // Enable full analytics
            enableFullAnalytics();
        });
    }
    
    if (declineCookies) {
        declineCookies.addEventListener('click', function() {
            localStorage.setItem('cookieConsent', 'declined');
            localStorage.setItem('cookieConsentDate', new Date().toISOString());
            cookieBanner.classList.remove('show');
            
            // Track consent decline
            trackEvent('cookie_consent', 'declined', 'user_preference');
            
            // Enable limited analytics only
            enableLimitedAnalytics();
        });
    }
    
    // Enhanced Page View Tracking
    function trackPageView() {
        const pageData = {
            page_title: document.title,
            page_url: window.location.href,
            page_referrer: document.referrer,
            user_agent: navigator.userAgent,
            timestamp: new Date().toISOString()
        };
        
        // GTM Page View
        dataLayer.push({
            'event': 'page_view',
            'page_title': pageData.page_title,
            'page_url': pageData.page_url,
            'page_referrer': pageData.page_referrer
        });
        
        // Segment Page View
        if (window.analytics) {
            window.analytics.page(pageData.page_title, {
                url: pageData.page_url,
                referrer: pageData.page_referrer,
                userAgent: pageData.user_agent
            });
        }
        
        console.log('Page view tracked:', pageData);
    }
    
    // Enhanced Event Tracking Function
    function trackEvent(eventName, eventAction, eventLabel, additionalData = {}) {
        const eventData = {
            event: eventName,
            event_category: 'engagement',
            event_action: eventAction,
            event_label: eventLabel,
            timestamp: new Date().toISOString(),
            session_id: getSessionId(),
            user_id: getUserId(),
            ...additionalData
        };
        
        // Push to GTM dataLayer
        dataLayer.push(eventData);
        
        // Track with Segment
        if (window.analytics) {
            window.analytics.track(eventName, {
                action: eventAction,
                label: eventLabel,
                ...additionalData
            });
        }
        
        console.log('Event tracked:', eventData);
    }
    
    // Session Management
    function getSessionId() {
        let sessionId = sessionStorage.getItem('sessionId');
        if (!sessionId) {
            sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            sessionStorage.setItem('sessionId', sessionId);
        }
        return sessionId;
    }
    
    // User ID Management
    function getUserId() {
        let userId = localStorage.getItem('userId');
        if (!userId) {
            userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            localStorage.setItem('userId', userId);
        }
        return userId;
    }
    
    // Analytics Control Functions
    function enableFullAnalytics() {
        console.log('Full analytics enabled');
        // Enable all tracking features
        enableScrollTracking();
        enableHeatmapTracking();
        enableFormAnalytics();
    }
    
    function enableLimitedAnalytics() {
        console.log('Limited analytics enabled');
        // Enable only essential tracking
        enableFormAnalytics();
    }
    
    // Enhanced Scroll Tracking
    function enableScrollTracking() {
        let scrollDepthTriggered = {
            '25': false,
            '50': false,
            '75': false,
            '90': false,
            '100': false
        };
        
        let timeOnPage = 0;
        const timeInterval = setInterval(() => {
            timeOnPage += 10;
            
            // Track time on page milestones
            if (timeOnPage === 30 || timeOnPage === 60 || timeOnPage === 120) {
                trackEvent('time_on_page', timeOnPage.toString(), 'seconds');
            }
        }, 10000);
        
        window.addEventListener('scroll', function() {
            const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight;
            const scrollPercentage = (window.scrollY / scrollableHeight) * 100;
            
            for (const depth in scrollDepthTriggered) {
                if (scrollPercentage >= parseInt(depth) && !scrollDepthTriggered[depth]) {
                    trackEvent('scroll_depth', depth, `${depth}%`);
                    scrollDepthTriggered[depth] = true;
                }
            }
        });
    }
    
    // Heatmap Tracking (Mock)
    function enableHeatmapTracking() {
        document.addEventListener('click', function(e) {
            const element = e.target;
            const rect = element.getBoundingClientRect();
            
            trackEvent('element_click', element.tagName.toLowerCase(), element.textContent.substring(0, 50), {
                element_id: element.id || 'no_id',
                element_class: element.className || 'no_class',
                position_x: Math.round(rect.left + rect.width / 2),
                position_y: Math.round(rect.top + rect.height / 2),
                viewport_width: window.innerWidth,
                viewport_height: window.innerHeight
            });
        });
    }
    
    // Enhanced Form Analytics
    function enableFormAnalytics() {
        const forms = document.querySelectorAll('form');
        
        forms.forEach(form => {
            // Track form start
            const formFields = form.querySelectorAll('input, select, textarea');
            formFields.forEach(field => {
                field.addEventListener('focus', function() {
                    trackEvent('form_field_focus', field.name || field.id, 'form_interaction');
                });
                
                field.addEventListener('blur', function() {
                    trackEvent('form_field_blur', field.name || field.id, 'form_interaction');
                });
            });
            
            // Track form submission
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(form);
                const formValues = {};
                
                for (let [key, value] of formData.entries()) {
                    formValues[key] = value;
                }
                
                // Track form submission
                trackEvent('form_submission', 'success', form.id || 'contact_form', {
                    form_id: form.id || 'contact_form',
                    form_fields: Object.keys(formValues).length,
                    has_email: formValues.email ? 'yes' : 'no',
                    has_phone: formValues.phone ? 'yes' : 'no',
                    interest_area: formValues.interest || 'not_specified',
                    experience_level: formValues.experience || 'not_specified',
                    newsletter_opt_in: formValues.newsletter ? 'yes' : 'no'
                });
                
                // Simulate form processing
                showFormSuccess(form);
            });
        });
    }
    
    // Form Success Handler
    function showFormSuccess(form) {
        const submitButton = form.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;
        
        submitButton.textContent = 'Thank You!';
        submitButton.disabled = true;
        submitButton.style.background = '#10B981';
        
        // Reset form after delay
        setTimeout(() => {
            form.reset();
            submitButton.textContent = originalText;
            submitButton.disabled = false;
            submitButton.style.background = '';
        }, 3000);
    }
    
    // Enhanced CTA Button Tracking
    function setupCTATracking() {
        const ctaButtons = document.querySelectorAll('[data-tracking]');
        
        ctaButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                const trackingId = this.getAttribute('data-tracking');
                const buttonText = this.textContent.trim();
                const buttonType = this.className.includes('btn-primary') ? 'primary' : 
                                 this.className.includes('btn-secondary') ? 'secondary' : 'outline';
                
                trackEvent('cta_click', trackingId, buttonText, {
                    button_type: buttonType,
                    button_position: getElementPosition(this),
                    page_section: getPageSection(this)
                });
                
                // Handle specific CTA actions
                if (trackingId === 'video_cta') {
                    openVideoModal();
                } else if (trackingId === 'hero_cta') {
                    scrollToForm();
                }
            });
        });
    }
    
    // Navigation Tracking
    function setupNavigationTracking() {
        const navLinks = document.querySelectorAll('.nav-link');
        
        navLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                const trackingId = this.getAttribute('data-tracking');
                const linkText = this.textContent.trim();
                
                trackEvent('navigation_click', trackingId, linkText, {
                    link_url: this.href,
                    link_position: 'header_nav'
                });
            });
        });
    }
    
    // Social Media Tracking
    function setupSocialTracking() {
        const socialLinks = document.querySelectorAll('.social-link');
        
        socialLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                const trackingId = this.getAttribute('data-tracking');
                const platform = trackingId.replace('social_', '');
                
                trackEvent('social_click', platform, this.textContent.trim(), {
                    platform: platform,
                    link_position: 'footer'
                });
            });
        });
    }
    
    // Program Card Tracking
    function setupProgramTracking() {
        const programCards = document.querySelectorAll('.program-card');
        
        programCards.forEach(card => {
            const trackingId = card.getAttribute('data-tracking');
            const programName = card.querySelector('h3').textContent;
            
            // Track card hover
            card.addEventListener('mouseenter', function() {
                trackEvent('program_card_hover', trackingId, programName);
            });
            
            // Track learn more clicks
            const learnMoreBtn = card.querySelector('.btn-outline');
            if (learnMoreBtn) {
                learnMoreBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    trackEvent('program_learn_more', trackingId, programName, {
                        program_name: programName,
                        card_position: getElementPosition(card)
                    });
                    
                    // Simulate program detail view
                    alert(`Learn more about ${programName} - This would open a detailed program page in a real implementation.`);
                });
            }
        });
    }
    
    // Utility Functions
    function getElementPosition(element) {
        const rect = element.getBoundingClientRect();
        const viewportHeight = window.innerHeight;
        
        if (rect.top < viewportHeight * 0.33) return 'top';
        if (rect.top < viewportHeight * 0.66) return 'middle';
        return 'bottom';
    }
    
    function getPageSection(element) {
        const section = element.closest('section');
        return section ? section.id : 'unknown';
    }
    
    function scrollToForm() {
        const formSection = document.getElementById('form-section');
        if (formSection) {
            formSection.scrollIntoView({ behavior: 'smooth' });
        }
    }
    
    // Video Modal Functionality
    function openVideoModal() {
        const modal = document.getElementById('video-modal');
        if (modal) {
            modal.style.display = 'block';
            trackEvent('video_modal_open', 'program_video', 'ASU MBA Overview');
        }
    }
    
    // Modal Close Functionality
    const modal = document.getElementById('video-modal');
    const closeBtn = document.querySelector('.close');
    
    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            modal.style.display = 'none';
            trackEvent('video_modal_close', 'program_video', 'ASU MBA Overview');
        });
    }
    
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                modal.style.display = 'none';
                trackEvent('video_modal_close', 'program_video', 'ASU MBA Overview');
            }
        });
    }
    
    // Initialize all tracking
    function initializeTracking() {
        trackPageView();
        setupCTATracking();
        setupNavigationTracking();
        setupSocialTracking();
        setupProgramTracking();
        
        // Enable analytics based on cookie consent
        const consent = localStorage.getItem('cookieConsent');
        if (consent === 'accepted') {
            enableFullAnalytics();
        } else if (consent === 'declined') {
            enableLimitedAnalytics();
        } else {
            // Default to limited analytics until consent is given
            enableLimitedAnalytics();
        }
    }
    
    // Performance Tracking
    function trackPerformance() {
        window.addEventListener('load', function() {
            const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
            
            trackEvent('page_load_time', 'performance', `${loadTime}ms`, {
                load_time_ms: loadTime,
                dom_content_loaded: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart
            });
        });
    }
    
    // Error Tracking
    function setupErrorTracking() {
        window.addEventListener('error', function(e) {
            trackEvent('javascript_error', 'error', e.message, {
                error_message: e.message,
                error_filename: e.filename,
                error_lineno: e.lineno,
                error_colno: e.colno
            });
        });
    }
    
    // Initialize everything
    initializeTracking();
    trackPerformance();
    setupErrorTracking();
    
    // Export functions for debugging
    window.marketingDemo = {
        trackEvent,
        getSessionId,
        getUserId,
        enableFullAnalytics,
        enableLimitedAnalytics
    };
    
    console.log('Marketing Technology Demo initialized successfully');
});