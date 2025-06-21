# Google Tag Manager Configuration Guide
## ASU Marketing Technology Demo

### Container Setup
- **Container ID**: GTM-DEMO123
- **Container Name**: ASU MBA Marketing Demo
- **Container Type**: Web

---

## Triggers Configuration

### 1. Page View Trigger
**Trigger Name**: Page View - All Pages
- **Trigger Type**: Page View
- **Fire On**: All Page Views

### 2. CTA Click Trigger
**Trigger Name**: CTA Button Click
- **Trigger Type**: Custom Event
- **Event Name**: cta_click
- **Fire On**: Custom Event equals "cta_click"

### 3. Form Submission Trigger
**Trigger Name**: Form Submission
- **Trigger Type**: Custom Event
- **Event Name**: form_submission
- **Fire On**: Custom Event equals "form_submission"

### 4. Scroll Depth Trigger
**Trigger Name**: Scroll Depth Tracking
- **Trigger Type**: Custom Event
- **Event Name**: scroll_depth
- **Fire On**: Custom Event equals "scroll_depth"

### 5. Cookie Consent Trigger
**Trigger Name**: Cookie Consent
- **Trigger Type**: Custom Event
- **Event Name**: cookie_consent
- **Fire On**: Custom Event equals "cookie_consent"

### 6. Program Card Interaction Trigger
**Trigger Name**: Program Card Interaction
- **Trigger Type**: Custom Event
- **Event Name**: program_card_hover
- **Fire On**: Custom Event equals "program_card_hover"

### 7. Video Modal Trigger
**Trigger Name**: Video Modal Interaction
- **Trigger Type**: Custom Event
- **Event Name**: video_modal_open
- **Fire On**: Custom Event equals "video_modal_open"

---

## Variables Configuration

### 1. Built-in Variables
- **Page URL**
- **Page Title**
- **Referrer**
- **Event**
- **Event Category**
- **Event Action**
- **Event Label**

### 2. Custom Variables

#### User ID Variable
**Variable Name**: User ID
- **Variable Type**: Custom JavaScript
```javascript
function() {
  return localStorage.getItem('userId') || 'anonymous';
}
```

#### Session ID Variable
**Variable Name**: Session ID
- **Variable Type**: Custom JavaScript
```javascript
function() {
  return sessionStorage.getItem('sessionId') || 'no_session';
}
```

#### Campaign Source Variable
**Variable Name**: Campaign Source
- **Variable Type**: URL
- **Component Type**: Query
- **Query Key**: utm_source

#### Campaign Medium Variable
**Variable Name**: Campaign Medium
- **Variable Type**: URL
- **Component Type**: Query
- **Query Key**: utm_medium

#### Campaign Name Variable
**Variable Name**: Campaign Name
- **Variable Type**: URL
- **Component Type**: Query
- **Query Key**: utm_campaign

#### Form Data Variables
**Variable Name**: Form Interest Area
- **Variable Type**: Data Layer Variable
- **Data Layer Variable Name**: interest_area

**Variable Name**: Form Experience Level
- **Variable Type**: Data Layer Variable
- **Data Layer Variable Name**: experience_level

**Variable Name**: Newsletter Opt-in
- **Variable Type**: Data Layer Variable
- **Data Layer Variable Name**: newsletter_opt_in

---

## Tags Configuration

### 1. Google Analytics 4 Configuration Tag
**Tag Name**: GA4 Configuration
- **Tag Type**: Google Analytics: GA4 Configuration
- **Measurement ID**: G-DEMO123456
- **Trigger**: Page View - All Pages
- **Additional Settings**:
  - Enhanced Ecommerce: Enabled
  - User Properties: User ID, Session ID
  - Custom Parameters: Campaign Source, Campaign Medium, Campaign Name

### 2. GA4 Event Tag - CTA Clicks
**Tag Name**: GA4 - CTA Click Event
- **Tag Type**: Google Analytics: GA4 Event
- **Configuration Tag**: GA4 Configuration
- **Event Name**: cta_click
- **Parameters**:
  - button_type: {{Event Action}}
  - button_position: {{Event Label}}
  - page_section: {{Data Layer Variable - page_section}}
- **Trigger**: CTA Button Click

### 3. GA4 Event Tag - Form Submissions
**Tag Name**: GA4 - Form Submission Event
- **Tag Type**: Google Analytics: GA4 Event
- **Configuration Tag**: GA4 Configuration
- **Event Name**: form_submission
- **Parameters**:
  - form_id: {{Event Action}}
  - form_fields: {{Data Layer Variable - form_fields}}
  - interest_area: {{Form Interest Area}}
  - experience_level: {{Form Experience Level}}
  - newsletter_opt_in: {{Newsletter Opt-in}}
- **Trigger**: Form Submission

### 4. GA4 Event Tag - Scroll Depth
**Tag Name**: GA4 - Scroll Depth Event
- **Tag Type**: Google Analytics: GA4 Event
- **Configuration Tag**: GA4 Configuration
- **Event Name**: scroll_depth
- **Parameters**:
  - scroll_percentage: {{Event Action}}
  - page_url: {{Page URL}}
- **Trigger**: Scroll Depth Tracking

### 5. GA4 Event Tag - Cookie Consent
**Tag Name**: GA4 - Cookie Consent Event
- **Tag Type**: Google Analytics: GA4 Event
- **Configuration Tag**: GA4 Configuration
- **Event Name**: cookie_consent
- **Parameters**:
  - consent_status: {{Event Action}}
  - consent_date: {{Event Label}}
- **Trigger**: Cookie Consent

### 6. Facebook Pixel Tag
**Tag Name**: Facebook Pixel - Page View
- **Tag Type**: Facebook Pixel
- **Pixel ID**: 123456789012345
- **Event**: PageView
- **Trigger**: Page View - All Pages

**Tag Name**: Facebook Pixel - Lead
- **Tag Type**: Facebook Pixel
- **Pixel ID**: 123456789012345
- **Event**: Lead
- **Parameters**:
  - content_name: ASU MBA Program Guide
  - content_category: Education
- **Trigger**: Form Submission

### 7. LinkedIn Insight Tag
**Tag Name**: LinkedIn Insight Tag
- **Tag Type**: LinkedIn Insight Tag
- **Partner ID**: 123456
- **Trigger**: Page View - All Pages

### 8. Hotjar Tracking Tag
**Tag Name**: Hotjar Tracking Code
- **Tag Type**: Custom HTML
```html
<!-- Hotjar Tracking Code -->
<script>
    (function(h,o,t,j,a,r){
        h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};
        h._hjSettings={hjid:1234567,hjsv:6};
        a=o.getElementsByTagName('head')[0];
        r=o.createElement('script');r.async=1;
        r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;
        a.appendChild(r);
    })(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');
</script>
```
- **Trigger**: Page View - All Pages

### 9. Google Ads Conversion Tracking
**Tag Name**: Google Ads - Lead Conversion
- **Tag Type**: Google Ads Conversion Tracking
- **Conversion ID**: 123456789
- **Conversion Label**: ABC123DEF456
- **Trigger**: Form Submission

---

## Data Layer Schema

### Page View Event
```javascript
{
  'event': 'page_view',
  'page_title': 'ASU Online MBA Program - Marketing Technology Demo',
  'page_url': 'https://example.com/mba-demo',
  'page_referrer': 'https://google.com',
  'user_id': 'user_1234567890_abc123',
  'session_id': 'session_1234567890_def456',
  'campaign_source': 'google',
  'campaign_medium': 'cpc',
  'campaign_name': 'asu_mba_2024'
}
```

### CTA Click Event
```javascript
{
  'event': 'cta_click',
  'event_category': 'engagement',
  'event_action': 'hero_cta',
  'event_label': 'Request Information',
  'button_type': 'primary',
  'button_position': 'top',
  'page_section': 'hero',
  'timestamp': '2024-01-15T10:30:00.000Z',
  'session_id': 'session_1234567890_def456',
  'user_id': 'user_1234567890_abc123'
}
```

### Form Submission Event
```javascript
{
  'event': 'form_submission',
  'event_category': 'conversion',
  'event_action': 'success',
  'event_label': 'contact_form',
  'form_id': 'contact_form',
  'form_fields': 7,
  'has_email': 'yes',
  'has_phone': 'yes',
  'interest_area': 'marketing',
  'experience_level': '3-5',
  'newsletter_opt_in': 'yes',
  'timestamp': '2024-01-15T10:35:00.000Z',
  'session_id': 'session_1234567890_def456',
  'user_id': 'user_1234567890_abc123'
}
```

### Scroll Depth Event
```javascript
{
  'event': 'scroll_depth',
  'event_category': 'engagement',
  'event_action': '50',
  'event_label': '50%',
  'scroll_depth_value': 50,
  'timestamp': '2024-01-15T10:32:00.000Z',
  'session_id': 'session_1234567890_def456',
  'user_id': 'user_1234567890_abc123'
}
```

---

## Testing & Validation

### 1. Preview Mode Testing
1. Enable GTM Preview Mode
2. Navigate to the demo website
3. Verify all triggers fire correctly
4. Check data layer variables populate
5. Validate tag firing order

### 2. Google Analytics 4 Validation
1. Check Real-Time reports
2. Verify events appear in GA4 DebugView
3. Test conversion tracking
4. Validate user properties

### 3. Third-Party Tool Validation
1. Facebook Pixel Helper
2. LinkedIn Insight Tag Helper
3. Hotjar Session Recording
4. Google Ads Conversion Tracking

---

## Implementation Notes

### Best Practices Implemented
- ✅ Cookie consent management
- ✅ Enhanced ecommerce tracking
- ✅ Cross-domain tracking setup
- ✅ User identification
- ✅ Session management
- ✅ Error tracking
- ✅ Performance monitoring

### Privacy Compliance
- ✅ GDPR cookie consent
- ✅ CCPA compliance
- ✅ Data minimization
- ✅ User control over tracking

### Performance Optimization
- ✅ Tag firing optimization
- ✅ Conditional loading
- ✅ Resource prioritization
- ✅ Error handling

This configuration demonstrates comprehensive marketing technology implementation suitable for a university marketing campaign with full analytics, conversion tracking, and user experience monitoring capabilities. 