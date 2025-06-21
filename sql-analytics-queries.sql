-- ASU Marketing Technology Demo - SQL Analytics Queries
-- BigQuery/Snowflake Implementation
-- Author: Marketing Technology Manager Candidate

-- ============================================================================
-- DATABASE SCHEMA SETUP
-- ============================================================================

-- Create tables for the marketing technology demo
CREATE TABLE IF NOT EXISTS `asu-marketing-demo.marketing_events.user_events` (
    event_id STRING,
    user_id STRING,
    anonymous_id STRING,
    event_name STRING,
    event_properties JSON,
    user_properties JSON,
    timestamp TIMESTAMP,
    session_id STRING,
    page_url STRING,
    referrer STRING,
    user_agent STRING,
    campaign_source STRING,
    campaign_medium STRING,
    campaign_name STRING,
    utm_source STRING,
    utm_medium STRING,
    utm_campaign STRING,
    utm_term STRING,
    utm_content STRING
);

CREATE TABLE IF NOT EXISTS `asu-marketing-demo.marketing_events.users` (
    user_id STRING,
    email STRING,
    first_name STRING,
    last_name STRING,
    phone STRING,
    company STRING,
    experience_level STRING,
    interest_area STRING,
    newsletter_opt_in BOOLEAN,
    lead_source STRING,
    lead_score INT64,
    first_visit_date TIMESTAMP,
    last_visit_date TIMESTAMP,
    total_page_views INT64,
    total_sessions INT64,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `asu-marketing-demo.marketing_events.campaigns` (
    campaign_id STRING,
    campaign_name STRING,
    campaign_source STRING,
    campaign_medium STRING,
    campaign_type STRING,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    status STRING,
    target_audience STRING,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `asu-marketing-demo.marketing_events.conversions` (
    conversion_id STRING,
    user_id STRING,
    event_id STRING,
    conversion_type STRING,
    conversion_value DECIMAL(10,2),
    conversion_date TIMESTAMP,
    attribution_model STRING,
    touchpoints JSON,
    created_at TIMESTAMP
);

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================

-- Insert sample user events
INSERT INTO `asu-marketing-demo.marketing_events.user_events` VALUES
('evt_001', 'user_001', 'anon_001', 'page_view', 
 '{"page_title": "ASU MBA Landing Page", "page_url": "https://asu.edu/mba-demo"}',
 '{"first_visit": "2024-01-15T10:00:00Z"}',
 TIMESTAMP '2024-01-15 10:00:00', 'sess_001', 'https://asu.edu/mba-demo', 
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner'),

('evt_002', 'user_001', 'anon_001', 'cta_click',
 '{"button_type": "primary", "button_position": "top", "page_section": "hero"}',
 '{"first_visit": "2024-01-15T10:00:00Z"}',
 TIMESTAMP '2024-01-15 10:05:00', 'sess_001', 'https://asu.edu/mba-demo',
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner'),

('evt_003', 'user_001', 'anon_001', 'form_submission',
 '{"form_id": "contact_form", "form_fields": 7, "interest_area": "marketing"}',
 '{"email": "john.doe@example.com", "first_name": "John", "last_name": "Doe"}',
 TIMESTAMP '2024-01-15 10:15:00', 'sess_001', 'https://asu.edu/mba-demo',
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner');

-- Insert sample users
INSERT INTO `asu-marketing-demo.marketing_events.users` VALUES
('user_001', 'john.doe@example.com', 'John', 'Doe', '+1-555-123-4567',
 'TechCorp', '3-5', 'marketing', TRUE, 'asu_mba_landing_page', 85,
 TIMESTAMP '2024-01-15 10:00:00', TIMESTAMP '2024-01-15 10:15:00', 5, 1,
 TIMESTAMP '2024-01-15 10:15:00', TIMESTAMP '2024-01-15 10:15:00');

-- Insert sample campaigns
INSERT INTO `asu-marketing-demo.marketing_events.campaigns` VALUES
('camp_001', 'ASU MBA 2024', 'google', 'cpc', 'paid_search',
 DATE '2024-01-01', DATE '2024-12-31', 50000.00, 'active', 'working_professionals',
 TIMESTAMP '2024-01-01 00:00:00');

-- ============================================================================
-- CAMPAIGN PERFORMANCE ANALYSIS
-- ============================================================================

-- 1. Campaign Performance Overview
WITH campaign_metrics AS (
    SELECT
        c.campaign_name,
        c.campaign_source,
        c.campaign_medium,
        c.campaign_type,
        COUNT(DISTINCT ue.user_id) as unique_users,
        COUNT(ue.event_id) as total_events,
        COUNT(CASE WHEN ue.event_name = 'page_view' THEN 1 END) as page_views,
        COUNT(CASE WHEN ue.event_name = 'cta_click' THEN 1 END) as cta_clicks,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) as form_submissions,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) / 
            NULLIF(COUNT(CASE WHEN ue.event_name = 'page_view' THEN 1 END), 0) * 100 as conversion_rate
    FROM `asu-marketing-demo.marketing_events.campaigns` c
    LEFT JOIN `asu-marketing-demo.marketing_events.user_events` ue
        ON c.campaign_source = ue.campaign_source
        AND c.campaign_medium = ue.campaign_medium
        AND c.campaign_name = ue.campaign_name
    WHERE c.status = 'active'
    GROUP BY 1, 2, 3, 4
)
SELECT
    campaign_name,
    campaign_source,
    campaign_medium,
    campaign_type,
    unique_users,
    total_events,
    page_views,
    cta_clicks,
    form_submissions,
    ROUND(conversion_rate, 2) as conversion_rate_pct,
    ROUND(cta_clicks * 100.0 / NULLIF(page_views, 0), 2) as cta_click_rate_pct,
    ROUND(form_submissions * 100.0 / NULLIF(cta_clicks, 0), 2) as form_completion_rate_pct
FROM campaign_metrics
ORDER BY form_submissions DESC;

-- 2. Campaign Performance by Time Period
SELECT
    DATE(timestamp) as event_date,
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as daily_unique_users,
    COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as daily_page_views,
    COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as daily_cta_clicks,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as daily_conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_name = 'page_view' THEN 1 END), 0), 2) as daily_conversion_rate
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC, 5 DESC;

-- 3. Campaign ROI Analysis (assuming conversion value)
WITH campaign_roi AS (
    SELECT
        c.campaign_name,
        c.campaign_source,
        c.campaign_medium,
        c.budget,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) as conversions,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) * 5000 as revenue, -- $5000 per lead
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) * 5000 - c.budget as profit,
        ROUND((COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) * 5000 - c.budget) / 
              NULLIF(c.budget, 0) * 100, 2) as roi_percentage
    FROM `asu-marketing-demo.marketing_events.campaigns` c
    LEFT JOIN `asu-marketing-demo.marketing_events.user_events` ue
        ON c.campaign_source = ue.campaign_source
        AND c.campaign_medium = ue.campaign_medium
        AND c.campaign_name = ue.campaign_name
    WHERE c.status = 'active'
    GROUP BY 1, 2, 3, 4
)
SELECT
    campaign_name,
    campaign_source,
    campaign_medium,
    budget,
    conversions,
    revenue,
    profit,
    roi_percentage,
    CASE 
        WHEN roi_percentage > 100 THEN 'Excellent'
        WHEN roi_percentage > 50 THEN 'Good'
        WHEN roi_percentage > 0 THEN 'Positive'
        ELSE 'Negative'
    END as roi_category
FROM campaign_roi
ORDER BY roi_percentage DESC;

-- ============================================================================
-- FORM SUBMISSION ANALYSIS
-- ============================================================================

-- 4. Form Submission Funnel Analysis
WITH form_funnel AS (
    SELECT
        DATE(timestamp) as event_date,
        COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
        COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as form_submissions,
        COUNT(DISTINCT CASE WHEN event_name = 'page_view' THEN user_id END) as unique_page_viewers,
        COUNT(DISTINCT CASE WHEN event_name = 'cta_click' THEN user_id END) as unique_cta_clickers,
        COUNT(DISTINCT CASE WHEN event_name = 'form_submission' THEN user_id END) as unique_form_submitters
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
    GROUP BY 1
)
SELECT
    event_date,
    page_views,
    cta_clicks,
    form_submissions,
    unique_page_viewers,
    unique_cta_clickers,
    unique_form_submitters,
    ROUND(cta_clicks * 100.0 / NULLIF(page_views, 0), 2) as page_view_to_cta_rate,
    ROUND(form_submissions * 100.0 / NULLIF(cta_clicks, 0), 2) as cta_to_form_rate,
    ROUND(form_submissions * 100.0 / NULLIF(page_views, 0), 2) as overall_conversion_rate
FROM form_funnel
ORDER BY event_date DESC;

-- 5. Form Field Analysis
SELECT
    JSON_EXTRACT_SCALAR(event_properties, '$.interest_area') as interest_area,
    JSON_EXTRACT_SCALAR(event_properties, '$.experience_level') as experience_level,
    JSON_EXTRACT_SCALAR(event_properties, '$.newsletter_opt_in') as newsletter_opt_in,
    COUNT(*) as form_submissions,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage_of_total
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE event_name = 'form_submission'
    AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3
ORDER BY form_submissions DESC;

-- 6. Form Abandonment Analysis
WITH form_sessions AS (
    SELECT
        session_id,
        user_id,
        MAX(CASE WHEN event_name = 'cta_click' THEN timestamp END) as cta_click_time,
        MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END) as form_submission_time,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as has_submission
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name IN ('cta_click', 'form_submission')
    GROUP BY 1, 2
)
SELECT
    COUNT(*) as total_cta_clicks,
    SUM(has_submission) as completed_forms,
    COUNT(*) - SUM(has_submission) as abandoned_forms,
    ROUND(SUM(has_submission) * 100.0 / COUNT(*), 2) as completion_rate,
    ROUND((COUNT(*) - SUM(has_submission)) * 100.0 / COUNT(*), 2) as abandonment_rate,
    AVG(TIMESTAMP_DIFF(form_submission_time, cta_click_time, SECOND)) as avg_time_to_complete_seconds
FROM form_sessions
WHERE cta_click_time IS NOT NULL;

-- ============================================================================
-- MULTI-TOUCH ATTRIBUTION ANALYSIS
-- ============================================================================

-- 7. First-Touch Attribution Model
WITH first_touch AS (
    SELECT
        user_id,
        MIN(timestamp) as first_touch_time,
        FIRST_VALUE(campaign_source) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED PRECEDING
        ) as first_touch_source,
        FIRST_VALUE(campaign_medium) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED PRECEDING
        ) as first_touch_medium,
        FIRST_VALUE(campaign_name) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED PRECEDING
        ) as first_touch_campaign
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'page_view'
    GROUP BY user_id
),
conversions AS (
    SELECT DISTINCT user_id
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'form_submission'
)
SELECT
    ft.first_touch_source,
    ft.first_touch_medium,
    ft.first_touch_campaign,
    COUNT(ft.user_id) as total_users,
    COUNT(c.user_id) as converted_users,
    ROUND(COUNT(c.user_id) * 100.0 / COUNT(ft.user_id), 2) as conversion_rate,
    COUNT(c.user_id) * 5000 as attributed_revenue -- $5000 per conversion
FROM first_touch ft
LEFT JOIN conversions c ON ft.user_id = c.user_id
GROUP BY 1, 2, 3
ORDER BY attributed_revenue DESC;

-- 8. Last-Touch Attribution Model
WITH last_touch AS (
    SELECT
        user_id,
        MAX(timestamp) as last_touch_time,
        LAST_VALUE(campaign_source) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as last_touch_source,
        LAST_VALUE(campaign_medium) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as last_touch_medium,
        LAST_VALUE(campaign_name) OVER (
            PARTITION BY user_id 
            ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) as last_touch_campaign
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'page_view'
    GROUP BY user_id
),
conversions AS (
    SELECT DISTINCT user_id
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'form_submission'
)
SELECT
    lt.last_touch_source,
    lt.last_touch_medium,
    lt.last_touch_campaign,
    COUNT(lt.user_id) as total_users,
    COUNT(c.user_id) as converted_users,
    ROUND(COUNT(c.user_id) * 100.0 / COUNT(lt.user_id), 2) as conversion_rate,
    COUNT(c.user_id) * 5000 as attributed_revenue
FROM last_touch lt
LEFT JOIN conversions c ON lt.user_id = c.user_id
GROUP BY 1, 2, 3
ORDER BY attributed_revenue DESC;

-- 9. Linear Attribution Model (Equal Credit)
WITH user_journey AS (
    SELECT
        user_id,
        campaign_source,
        campaign_medium,
        campaign_name,
        COUNT(*) as touch_count,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name IN ('page_view', 'cta_click', 'form_submission')
    GROUP BY 1, 2, 3, 4
),
conversion_journeys AS (
    SELECT *
    FROM user_journey
    WHERE conversions > 0
)
SELECT
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as unique_users,
    SUM(conversions) as total_conversions,
    SUM(conversions * 5000.0 / touch_count) as attributed_revenue,
    ROUND(SUM(conversions * 5000.0 / touch_count), 2) as rounded_revenue
FROM conversion_journeys
GROUP BY 1, 2, 3
ORDER BY attributed_revenue DESC;

-- 10. Time-Decay Attribution Model
WITH user_touchpoints AS (
    SELECT
        user_id,
        campaign_source,
        campaign_medium,
        campaign_name,
        timestamp,
        event_name,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp) as touch_order,
        COUNT(*) OVER (PARTITION BY user_id) as total_touches,
        MAX(CASE WHEN event_name = 'form_submission' THEN 1 ELSE 0 END) OVER (PARTITION BY user_id) as has_conversion
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name IN ('page_view', 'cta_click', 'form_submission')
),
time_decay_weights AS (
    SELECT
        user_id,
        campaign_source,
        campaign_medium,
        campaign_name,
        touch_order,
        total_touches,
        has_conversion,
        -- Time-decay weight: more recent touches get higher weight
        POWER(0.5, total_touches - touch_order) as touch_weight
    FROM user_touchpoints
    WHERE has_conversion = 1
)
SELECT
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as unique_users,
    SUM(has_conversion) as total_conversions,
    SUM(has_conversion * touch_weight * 5000) as attributed_revenue,
    ROUND(SUM(has_conversion * touch_weight * 5000), 2) as rounded_revenue
FROM time_decay_weights
GROUP BY 1, 2, 3
ORDER BY attributed_revenue DESC;

-- ============================================================================
-- USER JOURNEY ANALYSIS
-- ============================================================================

-- 11. User Journey Path Analysis
WITH user_paths AS (
    SELECT
        user_id,
        session_id,
        STRING_AGG(event_name ORDER BY timestamp) as event_sequence,
        COUNT(*) as path_length,
        MAX(CASE WHEN event_name = 'form_submission' THEN 1 ELSE 0 END) as converted
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name IN ('page_view', 'cta_click', 'form_submission')
    GROUP BY 1, 2
)
SELECT
    event_sequence,
    path_length,
    COUNT(*) as path_frequency,
    SUM(converted) as conversions,
    ROUND(SUM(converted) * 100.0 / COUNT(*), 2) as conversion_rate
FROM user_paths
GROUP BY 1, 2
ORDER BY path_frequency DESC
LIMIT 20;

-- 12. Time to Conversion Analysis
WITH conversion_times AS (
    SELECT
        user_id,
        MIN(timestamp) as first_visit,
        MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END) as conversion_time,
        TIMESTAMP_DIFF(
            MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END),
            MIN(timestamp),
            HOUR
        ) as hours_to_conversion
    FROM `asu-marketing-demo.marketing_events.user_events`
    GROUP BY user_id
    HAVING MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END) IS NOT NULL
)
SELECT
    CASE 
        WHEN hours_to_conversion < 1 THEN '0-1 hour'
        WHEN hours_to_conversion < 24 THEN '1-24 hours'
        WHEN hours_to_conversion < 168 THEN '1-7 days'
        WHEN hours_to_conversion < 720 THEN '1-30 days'
        ELSE '30+ days'
    END as conversion_time_bucket,
    COUNT(*) as conversions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
    ROUND(AVG(hours_to_conversion), 2) as avg_hours_to_conversion
FROM conversion_times
GROUP BY 1
ORDER BY 
    CASE 
        WHEN conversion_time_bucket = '0-1 hour' THEN 1
        WHEN conversion_time_bucket = '1-24 hours' THEN 2
        WHEN conversion_time_bucket = '1-7 days' THEN 3
        WHEN conversion_time_bucket = '1-30 days' THEN 4
        ELSE 5
    END;

-- ============================================================================
-- REAL-TIME DASHBOARD QUERIES
-- ============================================================================

-- 13. Real-Time Performance Dashboard
SELECT
    'Today' as period,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
    COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_name = 'page_view' THEN 1 END), 0), 2) as conversion_rate
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE DATE(timestamp) = CURRENT_DATE()

UNION ALL

SELECT
    'Last 7 Days' as period,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
    COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_name = 'page_view' THEN 1 END), 0), 2) as conversion_rate
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY);

-- 14. Campaign Performance Comparison
SELECT
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(DISTINCT user_id), 0), 2) as conversion_rate,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 5000 as revenue
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3
ORDER BY revenue DESC;

-- ============================================================================
-- ADVANCED ANALYTICS
-- ============================================================================

-- 15. Cohort Analysis
WITH user_cohorts AS (
    SELECT
        user_id,
        DATE(MIN(timestamp)) as cohort_date,
        DATE(timestamp) as event_date,
        DATE_DIFF(DATE(timestamp), DATE(MIN(timestamp)), DAY) as days_since_cohort
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'page_view'
    GROUP BY user_id, DATE(timestamp)
),
cohort_retention AS (
    SELECT
        cohort_date,
        days_since_cohort,
        COUNT(DISTINCT user_id) as active_users,
        COUNT(DISTINCT CASE WHEN days_since_cohort = 0 THEN user_id END) as cohort_size
    FROM user_cohorts
    GROUP BY 1, 2
)
SELECT
    cohort_date,
    days_since_cohort,
    cohort_size,
    active_users,
    ROUND(active_users * 100.0 / cohort_size, 2) as retention_rate
FROM cohort_retention
WHERE cohort_size > 0
ORDER BY cohort_date DESC, days_since_cohort;

-- 16. Customer Lifetime Value (CLV) Analysis
WITH user_clv AS (
    SELECT
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.lead_score,
        COUNT(ue.event_id) as total_events,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) as conversions,
        COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) * 5000 as total_revenue,
        DATE_DIFF(MAX(ue.timestamp), MIN(ue.timestamp), DAY) as customer_lifespan_days,
        CASE 
            WHEN COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) > 0 THEN 'Converted'
            WHEN COUNT(ue.event_id) > 10 THEN 'Engaged'
            WHEN COUNT(ue.event_id) > 5 THEN 'Active'
            ELSE 'Inactive'
        END as customer_segment
    FROM `asu-marketing-demo.marketing_events.users` u
    LEFT JOIN `asu-marketing-demo.marketing_events.user_events` ue ON u.user_id = ue.user_id
    GROUP BY 1, 2, 3, 4, 5
)
SELECT
    customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(total_events), 2) as avg_events,
    ROUND(AVG(conversions), 2) as avg_conversions,
    ROUND(AVG(total_revenue), 2) as avg_revenue,
    ROUND(AVG(customer_lifespan_days), 2) as avg_lifespan_days,
    ROUND(AVG(lead_score), 2) as avg_lead_score
FROM user_clv
GROUP BY 1
ORDER BY avg_revenue DESC;

-- ============================================================================
-- DATA QUALITY & MONITORING
-- ============================================================================

-- 17. Data Quality Check
SELECT
    'Missing Campaign Data' as check_type,
    COUNT(*) as issue_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `asu-marketing-demo.marketing_events.user_events`), 2) as percentage
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE campaign_source IS NULL OR campaign_medium IS NULL

UNION ALL

SELECT
    'Duplicate Events' as check_type,
    COUNT(*) - COUNT(DISTINCT event_id) as issue_count,
    ROUND((COUNT(*) - COUNT(DISTINCT event_id)) * 100.0 / COUNT(*), 2) as percentage
FROM `asu-marketing-demo.marketing_events.user_events`

UNION ALL

SELECT
    'Invalid Timestamps' as check_type,
    COUNT(*) as issue_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM `asu-marketing-demo.marketing_events.user_events`), 2) as percentage
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp > CURRENT_TIMESTAMP() OR timestamp < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 YEAR);

-- 18. Performance Monitoring
SELECT
    DATE(timestamp) as event_date,
    HOUR(timestamp) as event_hour,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(*), 0), 2) as conversion_rate
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY 1, 2
ORDER BY 1 DESC, 2 DESC;

-- ============================================================================
-- EXPORT QUERIES FOR DASHBOARDS
-- ============================================================================

-- 19. Export for Looker Studio Dashboard
SELECT
    DATE(timestamp) as date,
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
    COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_name = 'page_view' THEN 1 END), 0), 2) as conversion_rate,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 5000 as revenue
FROM `asu-marketing-demo.marketing_events.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC, 5 DESC;

-- 20. Attribution Summary for Executive Dashboard
SELECT
    'First-Touch' as attribution_model,
    campaign_source,
    campaign_medium,
    COUNT(DISTINCT user_id) as attributed_conversions,
    COUNT(DISTINCT user_id) * 5000 as attributed_revenue
FROM (
    SELECT
        user_id,
        FIRST_VALUE(campaign_source) OVER (PARTITION BY user_id ORDER BY timestamp) as campaign_source,
        FIRST_VALUE(campaign_medium) OVER (PARTITION BY user_id ORDER BY timestamp) as campaign_medium
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'form_submission'
)
GROUP BY 1, 2, 3

UNION ALL

SELECT
    'Last-Touch' as attribution_model,
    campaign_source,
    campaign_medium,
    COUNT(DISTINCT user_id) as attributed_conversions,
    COUNT(DISTINCT user_id) * 5000 as attributed_revenue
FROM (
    SELECT
        user_id,
        LAST_VALUE(campaign_source) OVER (PARTITION BY user_id ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as campaign_source,
        LAST_VALUE(campaign_medium) OVER (PARTITION BY user_id ORDER BY timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as campaign_medium
    FROM `asu-marketing-demo.marketing_events.user_events`
    WHERE event_name = 'form_submission'
)
GROUP BY 1, 2, 3
ORDER BY attribution_model, attributed_revenue DESC; 