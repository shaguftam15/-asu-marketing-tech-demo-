# Online Learning Platform - MarTech Demo

> ⚠️ This project is a personal demo created for educational and job portfolio purposes only. It is not affiliated with or endorsed by any university.

---

## 🚀 Live Demo & Project Hub

*   **Live Website:** **[Click here to view the functional landing page](https://shaguftam15.github.io/asu-marketing-tech-demo/)**
*   **Project Goal:** To build and document a complete, end-to-end marketing technology stack, from user interaction to data warehouse analysis.

---

## 📂 Project Architecture & Documentation

The live website is only the front-end. The core of this project is the underlying architecture, data flow, and analytics. Please review the documentation below for proof of work.

*   **[📄 Google Tag Manager (GTM) Configuration](./gtm-configuration.md)**
    *   *Details the setup of all tags, triggers, and variables used to manage tracking scripts.*

*   **[📊 Customer Data Platform (CDP) Data Flow](./cdp-data-flow.md)**
    *   *Explains the architecture of how user data is collected, unified in Segment, and distributed to other tools and the data warehouse.*

*   **[📈 Looker Studio Dashboard Design](./looker-studio-dashboard.md)**
    *   *Includes a visual wireframe and layout for the final marketing performance dashboard.*

*   **[💻 SQL Analytics Queries](./analytics-queries.sql)**
    *   *Contains the SQL queries for BigQuery/Snowflake used to analyze campaign ROI, user funnels, and multi-touch attribution.*

*   **[📝 Sample Datasets](./sample-data.json)**
    *   *The sample data used to model the analytics queries.*

---

## 🛠️ Technology Stack Demonstrated

### Frontend & Tracking
- **HTML5**: Semantic, accessible landing page
- **CSS3**: Modern, responsive design with ASU branding
- **JavaScript**: Enhanced analytics and user interaction tracking
- **Google Tag Manager**: Container ID: `GTM-DEMO123`
- **Segment CDP**: Customer data platform integration
- **Cookie Consent**: GDPR/CCPA compliant consent management

### Analytics & Data
- **Google Analytics 4**: Enhanced ecommerce tracking
- **BigQuery/Snowflake**: Data warehousing and analytics
- **SQL**: Comprehensive analytics queries and attribution modeling
- **Looker Studio**: Marketing analytics dashboard

### Marketing Tools
- **Facebook Pixel**: Conversion tracking
- **LinkedIn Insight Tag**: B2B marketing analytics
- **Hotjar**: User behavior analysis
- **Google Ads**: Conversion tracking

---

## 📊 Key Features Demonstrated

### 1. Enhanced Landing Page
- **Modern Design**: Professional ASU-branded landing page
- **Responsive Layout**: Mobile-first design approach
- **Interactive Elements**: CTAs, forms, video modal, testimonials
- **Accessibility**: WCAG compliant design

### 2. Comprehensive Tracking
- **Page Views**: Automatic tracking with enhanced parameters
- **CTA Clicks**: Detailed button interaction tracking
- **Form Submissions**: Complete form analytics with field tracking
- **Scroll Depth**: User engagement measurement
- **Cookie Consent**: Privacy-compliant tracking control

### 3. Google Tag Manager Implementation
- **Container Setup**: Complete GTM configuration
- **Triggers**: Custom event triggers for all interactions
- **Variables**: Dynamic data layer variables
- **Tags**: GA4, Facebook Pixel, LinkedIn, Hotjar integration
- **Testing**: Preview mode and validation procedures

### 4. Customer Data Platform (Segment)
- **Data Collection**: Comprehensive event tracking
- **Data Processing**: Real-time and batch processing
- **Destinations**: Multiple marketing tool integrations
- **Privacy Compliance**: GDPR/CCPA compliant data handling
- **Data Enrichment**: User profile enhancement

### 5. SQL Analytics & Attribution
- **Campaign Performance**: ROI analysis and optimization
- **Form Analytics**: Conversion funnel analysis
- **Multi-Touch Attribution**: First-touch, last-touch, linear, time-decay models
- **User Journey Analysis**: Path analysis and optimization
- **Real-Time Dashboards**: Live performance monitoring

### 6. Looker Studio Dashboard
- **Executive Summary**: KPI overview and real-time metrics
- **Campaign Performance**: Detailed campaign analysis
- **Attribution Analysis**: Multi-touch attribution comparison
- **User Journey**: Conversion funnel and path analysis
- **Lead Quality**: Demographics and behavior analysis

---

## 📈 Analytics & Attribution Models

### Campaign Performance Analysis
```sql
-- Campaign ROI Analysis
SELECT
    campaign_name,
    campaign_source,
    campaign_medium,
    budget,
    conversions,
    revenue,
    profit,
    ROUND((revenue - budget) / budget * 100, 2) as roi_percentage
FROM campaign_metrics
ORDER BY roi_percentage DESC;
```

### Multi-Touch Attribution
- **First-Touch**: Credits first interaction for conversion
- **Last-Touch**: Credits final interaction for conversion
- **Linear**: Equal credit distribution across all touchpoints
- **Time-Decay**: Higher weight for recent interactions

### User Journey Analysis
- **Conversion Funnel**: Page Views → CTA Clicks → Form Submissions
- **Path Analysis**: Most common user journey patterns
- **Drop-off Analysis**: Identify optimization opportunities
- **Time to Conversion**: Conversion velocity analysis

---

## 🔧 Implementation Details

### GTM Configuration
- **Container ID**: `GTM-DEMO123`
- **Triggers**: 7 custom event triggers
- **Variables**: 15+ custom variables including user ID, session ID
- **Tags**: 9+ tags for comprehensive tracking
- **Data Layer**: Structured event schema

### Segment CDP Setup
- **Source**: JavaScript website integration
- **Destinations**: GA4, Facebook, LinkedIn, Hotjar, BigQuery
- **Event Schema**: Standardized event structure
- **User Identification**: Anonymous to identified user flow
- **Privacy Controls**: Consent-based tracking

### BigQuery Data Warehouse
- **Tables**: user_events, users, campaigns, conversions
- **Queries**: 19+ analytical queries
- **Attribution**: 4 attribution model implementations
- **Performance**: Optimized for real-time analytics

### Looker Studio Dashboard
- **Data Sources**: BigQuery, GA4, Segment
- **Charts**: 15+ interactive visualizations
- **Filters**: Global and chart-specific filters
- **Alerts**: Automated performance monitoring
- **Sharing**: Role-based access control

---

## 📋 Testing & Validation

### GTM Testing
1. **Preview Mode**: Test all triggers and tags
2. **Data Layer**: Validate event data structure
3. **Tag Firing**: Verify correct tag execution
4. **Error Handling**: Test error scenarios

### Analytics Validation
1. **GA4 DebugView**: Real-time event validation
2. **Facebook Pixel Helper**: Conversion tracking verification
3. **LinkedIn Insight Tag Helper**: B2B tracking validation
4. **Hotjar Session Recording**: User behavior verification

### Data Quality Checks
1. **Data Completeness**: Missing field detection
2. **Data Accuracy**: Validation against source systems
3. **Duplicate Detection**: Identify and resolve duplicates
4. **Performance Monitoring**: Query optimization

---

## 🚀 Deployment Options

### 1. GitHub Pages (Free)
- **Setup**: Enable GitHub Pages in repository settings
- **URL**: `https://yourusername.github.io/asu-marketing-tech-demo/`
- **Custom Domain**: Optional custom domain configuration
- **HTTPS**: Automatic SSL certificate

### 2. Netlify (Free Tier)
- **Setup**: Connect GitHub repository
- **URL**: `https://your-demo-name.netlify.app/`
- **Custom Domain**: Free custom domain support
- **HTTPS**: Automatic SSL certificate

### 3. Vercel (Free Tier)
- **Setup**: Import GitHub repository
- **URL**: `https://your-demo-name.vercel.app/`
- **Custom Domain**: Free custom domain support
- **HTTPS**: Automatic SSL certificate

---

## 📊 Performance Metrics

### Technical Performance
- **Page Load Time**: < 2 seconds
- **GTM Load Time**: < 1 second
- **Analytics Latency**: < 5 seconds
- **Dashboard Refresh**: 15-minute intervals

### Business Metrics
- **Conversion Rate**: 3-8% (industry benchmark)
- **Cost per Lead**: < $500
- **ROI**: > 200%
- **Lead Quality Score**: > 70

---

## 🔒 Privacy & Compliance

### GDPR Compliance
- ✅ Cookie consent management
- ✅ Data minimization
- ✅ User rights (access, deletion, portability)
- ✅ Data retention policies
- ✅ Privacy policy integration

### CCPA Compliance
- ✅ California resident identification
- ✅ Opt-out mechanisms
- ✅ Data disclosure requirements
- ✅ Service provider agreements

### Data Security
- ✅ HTTPS encryption
- ✅ Secure data transmission
- ✅ Access control
- ✅ Audit logging

---

## 📚 Learning Resources

### Documentation
- [GTM Configuration Guide](documentation/gtm-configuration.md)
- [CDP Data Flow Documentation](documentation/cdp-data-flow.md)
- [SQL Analytics Queries](documentation/analytics-queries.sql)
- [Looker Studio Dashboard Guide](documentation/dashboard-documentation.md)

### External Resources
- [Google Tag Manager Documentation](https://developers.google.com/tag-manager)
- [Segment Documentation](https://segment.com/docs/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Looker Studio Documentation](https://support.google.com/looker-studio/)

---

## 🤝 Contributing

This project is designed as a portfolio piece for the ASU Manager, Marketing Technology position. However, suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

This project is created for educational and portfolio purposes. Feel free to use and modify for your own marketing technology demonstrations.

---

## 👨‍💼 About the Author

This project was created as a comprehensive demonstration of marketing technology skills for the **ASU Manager, Marketing Technology** position. It showcases:

- **Technical Expertise**: GA4, GTM, CDPs, SQL, Analytics
- **Strategic Thinking**: Attribution modeling, ROI analysis
- **Implementation Skills**: End-to-end marketing technology setup
- **Business Acumen**: Data-driven decision making

### Key Skills Demonstrated
- ✅ **GA4**: Enhanced ecommerce, custom events, user properties
- ✅ **Google Tag Manager**: Triggers, variables, tags, data layer
- ✅ **CDPs (Segment)**: Data collection, processing, distribution
- ✅ **SQL (BigQuery/Snowflake)**: Analytics, attribution, data warehousing
- ✅ **Marketing Analytics Dashboards (Looker Studio)**: KPI tracking, attribution analysis
- ✅ **Privacy Compliance**: GDPR/CCPA implementation
- ✅ **Performance Optimization**: Fast loading, efficient queries
- ✅ **Documentation**: Comprehensive technical documentation

---

## 🎯 Next Steps

1. **Deploy the Demo**: Choose your preferred hosting platform
2. **Customize Content**: Update with your specific use cases
3. **Add Real Data**: Connect to actual marketing campaigns
4. **Present to Hiring Manager**: Use as portfolio piece
5. **Iterate**: Continue improving based on feedback

This comprehensive marketing technology demo demonstrates the full spectrum of skills required for the ASU Manager, Marketing Technology position, from technical implementation to strategic analytics and business impact measurement. 