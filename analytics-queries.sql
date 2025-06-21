-- ASU Marketing Technology Demo - SQL Analytics Queries
-- BigQuery/Snowflake Implementation
-- Author: Marketing Technology Manager Candidate

-- ============================================================================
-- CAMPAIGN PERFORMANCE ANALYSIS
-- ============================================================================

-- 1. Campaign Performance Overview
WITH campaign_metrics AS (
    SELECT
        campaign_source,
        campaign_medium,
        campaign_name,
        COUNT(DISTINCT user_id) as unique_users,
        COUNT(*) as total_events,
        COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
        COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as form_submissions
    FROM user_events
    WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY 1, 2, 3
)
SELECT
    campaign_name,
    campaign_source,
    campaign_medium,
    unique_users,
    total_events,
    page_views,
    cta_clicks,
    form_submissions,
    ROUND(form_submissions * 100.0 / NULLIF(page_views, 0), 2) as conversion_rate_pct,
    ROUND(cta_clicks * 100.0 / NULLIF(page_views, 0), 2) as cta_click_rate_pct,
    ROUND(form_submissions * 100.0 / NULLIF(cta_clicks, 0), 2) as form_completion_rate_pct
FROM campaign_metrics
ORDER BY form_submissions DESC;

-- 2. Daily Campaign Performance
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
FROM user_events
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC, 5 DESC;

-- ============================================================================
-- FORM SUBMISSION ANALYSIS
-- ============================================================================

-- 3. Form Submission Funnel Analysis
WITH form_funnel AS (
    SELECT
        DATE(timestamp) as event_date,
        COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
        COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as form_submissions,
        COUNT(DISTINCT CASE WHEN event_name = 'page_view' THEN user_id END) as unique_page_viewers,
        COUNT(DISTINCT CASE WHEN event_name = 'cta_click' THEN user_id END) as unique_cta_clickers,
        COUNT(DISTINCT CASE WHEN event_name = 'form_submission' THEN user_id END) as unique_form_submitters
    FROM user_events
    WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
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

-- 4. Form Field Analysis
SELECT
    JSON_EXTRACT_SCALAR(event_properties, '$.interest_area') as interest_area,
    JSON_EXTRACT_SCALAR(event_properties, '$.experience_level') as experience_level,
    JSON_EXTRACT_SCALAR(event_properties, '$.newsletter_opt_in') as newsletter_opt_in,
    COUNT(*) as form_submissions,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage_of_total
FROM user_events
WHERE event_name = 'form_submission'
    AND timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3
ORDER BY form_submissions DESC;

-- 5. Form Abandonment Analysis
WITH form_sessions AS (
    SELECT
        session_id,
        user_id,
        MAX(CASE WHEN event_name = 'cta_click' THEN timestamp END) as cta_click_time,
        MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END) as form_submission_time,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as has_submission
    FROM user_events
    WHERE event_name IN ('cta_click', 'form_submission')
    GROUP BY 1, 2
)
SELECT
    COUNT(*) as total_cta_clicks,
    SUM(has_submission) as completed_forms,
    COUNT(*) - SUM(has_submission) as abandoned_forms,
    ROUND(SUM(has_submission) * 100.0 / COUNT(*), 2) as completion_rate,
    ROUND((COUNT(*) - SUM(has_submission)) * 100.0 / COUNT(*), 2) as abandonment_rate,
    AVG(TIMESTAMPDIFF(SECOND, cta_click_time, form_submission_time)) as avg_time_to_complete_seconds
FROM form_sessions
WHERE cta_click_time IS NOT NULL;

-- ============================================================================
-- MULTI-TOUCH ATTRIBUTION ANALYSIS
-- ============================================================================

-- 6. First-Touch Attribution Model
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
    FROM user_events
    WHERE event_name = 'page_view'
    GROUP BY user_id
),
conversions AS (
    SELECT DISTINCT user_id
    FROM user_events
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

-- 7. Last-Touch Attribution Model
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
    FROM user_events
    WHERE event_name = 'page_view'
    GROUP BY user_id
),
conversions AS (
    SELECT DISTINCT user_id
    FROM user_events
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

-- 8. Linear Attribution Model (Equal Credit)
WITH user_journey AS (
    SELECT
        user_id,
        campaign_source,
        campaign_medium,
        campaign_name,
        COUNT(*) as touch_count,
        COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions
    FROM user_events
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

-- 9. Time-Decay Attribution Model
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
    FROM user_events
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

-- 10. User Journey Path Analysis
WITH user_paths AS (
    SELECT
        user_id,
        session_id,
        GROUP_CONCAT(event_name ORDER BY timestamp) as event_sequence,
        COUNT(*) as path_length,
        MAX(CASE WHEN event_name = 'form_submission' THEN 1 ELSE 0 END) as converted
    FROM user_events
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

-- 11. Time to Conversion Analysis
WITH conversion_times AS (
    SELECT
        user_id,
        MIN(timestamp) as first_visit,
        MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END) as conversion_time,
        TIMESTAMPDIFF(HOUR, MIN(timestamp), MAX(CASE WHEN event_name = 'form_submission' THEN timestamp END)) as hours_to_conversion
    FROM user_events
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

-- 12. Real-Time Performance Dashboard
SELECT
    'Today' as period,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'page_view' THEN 1 END) as page_views,
    COUNT(CASE WHEN event_name = 'cta_click' THEN 1 END) as cta_clicks,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_name = 'page_view' THEN 1 END), 0), 2) as conversion_rate
FROM user_events
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
FROM user_events
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY);

-- 13. Campaign Performance Comparison
SELECT
    campaign_source,
    campaign_medium,
    campaign_name,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(DISTINCT user_id), 0), 2) as conversion_rate,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 5000 as revenue
FROM user_events
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY 1, 2, 3
ORDER BY revenue DESC;

-- ============================================================================
-- ADVANCED ANALYTICS
-- ============================================================================

-- 14. Cohort Analysis
WITH user_cohorts AS (
    SELECT
        user_id,
        DATE(MIN(timestamp)) as cohort_date,
        DATE(timestamp) as event_date,
        DATEDIFF(DATE(timestamp), DATE(MIN(timestamp))) as days_since_cohort
    FROM user_events
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

-- 15. Customer Lifetime Value (CLV) Analysis
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
        DATEDIFF(MAX(ue.timestamp), MIN(ue.timestamp)) as customer_lifespan_days,
        CASE 
            WHEN COUNT(CASE WHEN ue.event_name = 'form_submission' THEN 1 END) > 0 THEN 'Converted'
            WHEN COUNT(ue.event_id) > 10 THEN 'Engaged'
            WHEN COUNT(ue.event_id) > 5 THEN 'Active'
            ELSE 'Inactive'
        END as customer_segment
    FROM users u
    LEFT JOIN user_events ue ON u.user_id = ue.user_id
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

-- 16. Data Quality Check
SELECT
    'Missing Campaign Data' as check_type,
    COUNT(*) as issue_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_events), 2) as percentage
FROM user_events
WHERE campaign_source IS NULL OR campaign_medium IS NULL

UNION ALL

SELECT
    'Duplicate Events' as check_type,
    COUNT(*) - COUNT(DISTINCT event_id) as issue_count,
    ROUND((COUNT(*) - COUNT(DISTINCT event_id)) * 100.0 / COUNT(*), 2) as percentage
FROM user_events

UNION ALL

SELECT
    'Invalid Timestamps' as check_type,
    COUNT(*) as issue_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_events), 2) as percentage
FROM user_events
WHERE timestamp > CURRENT_TIMESTAMP() OR timestamp < DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR);

-- 17. Performance Monitoring
SELECT
    DATE(timestamp) as event_date,
    HOUR(timestamp) as event_hour,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) as conversions,
    ROUND(COUNT(CASE WHEN event_name = 'form_submission' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(*), 0), 2) as conversion_rate
FROM user_events
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY 1, 2
ORDER BY 1 DESC, 2 DESC;

-- ============================================================================
-- EXPORT QUERIES FOR DASHBOARDS
-- ============================================================================

-- 18. Export for Looker Studio Dashboard
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
FROM user_events
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC, 5 DESC;

-- 19. Attribution Summary for Executive Dashboard
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
    FROM user_events
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
    FROM user_events
    WHERE event_name = 'form_submission'
)
GROUP BY 1, 2, 3
ORDER BY attribution_model, attributed_revenue DESC;

-- ============================================================================
-- SAMPLE DATA FOR TESTING
-- ============================================================================

-- Sample user_events table structure and data
/*
CREATE TABLE user_events (
    event_id VARCHAR(50),
    user_id VARCHAR(50),
    anonymous_id VARCHAR(50),
    event_name VARCHAR(50),
    event_properties JSON,
    user_properties JSON,
    timestamp TIMESTAMP,
    session_id VARCHAR(50),
    page_url VARCHAR(255),
    referrer VARCHAR(255),
    user_agent TEXT,
    campaign_source VARCHAR(100),
    campaign_medium VARCHAR(100),
    campaign_name VARCHAR(100),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_term VARCHAR(100),
    utm_content VARCHAR(100)
);

-- Sample data insertion
INSERT INTO user_events VALUES
('evt_001', 'user_001', 'anon_001', 'page_view', 
 '{"page_title": "ASU MBA Landing Page", "page_url": "https://asu.edu/mba-demo"}',
 '{"first_visit": "2024-01-15T10:00:00Z"}',
 '2024-01-15 10:00:00', 'sess_001', 'https://asu.edu/mba-demo', 
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner'),

('evt_002', 'user_001', 'anon_001', 'cta_click',
 '{"button_type": "primary", "button_position": "top", "page_section": "hero"}',
 '{"first_visit": "2024-01-15T10:00:00Z"}',
 '2024-01-15 10:05:00', 'sess_001', 'https://asu.edu/mba-demo',
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner'),

('evt_003', 'user_001', 'anon_001', 'form_submission',
 '{"form_id": "contact_form", "form_fields": 7, "interest_area": "marketing"}',
 '{"email": "john.doe@example.com", "first_name": "John", "last_name": "Doe"}',
 '2024-01-15 10:15:00', 'sess_001', 'https://asu.edu/mba-demo',
 'https://google.com', 'Mozilla/5.0...', 'google', 'cpc', 'asu_mba_2024',
 'google', 'cpc', 'asu_mba_2024', 'online mba programs', 'hero_banner');
*/ 