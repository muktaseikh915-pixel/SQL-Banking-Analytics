USE banking_analytics;

-- ============================================================
-- BANKING ANALYTICS PROJECT
-- Author: Mukto Seikh
-- Objective:
-- Analyze customer, account, loan, and card data to generate
-- business insights for customer segmentation, risk assessment,
-- profitability analysis, and executive reporting.
-- ============================================================



-- ============================================================
-- 1. CUSTOMER SEGMENTATION
-- Classify customers based on account balance
-- ============================================================

SELECT
    customer_id,
    account_id,
    balance_usd,

    CASE
        WHEN balance_usd >= 150000 THEN 'VIP'
        WHEN balance_usd >= 100000 THEN 'Premium'
        WHEN balance_usd >= 50000 THEN 'Regular'
        ELSE 'Basic'
    END AS customer_segment

FROM accounts;

-- Business Insight:
-- VIP and Premium customers are ideal candidates
-- for wealth management and premium banking services.



-- ============================================================
-- 2. CUSTOMERS ABOVE AVERAGE BALANCE
-- Identify customers holding balances above bank average
-- ============================================================

SELECT
    customer_id,
    account_id,
    balance_usd

FROM accounts

WHERE balance_usd >
(
    SELECT AVG(balance_usd)
    FROM accounts
);

-- Business Insight:
-- Customers above average balance are strong upsell targets.



-- ============================================================
-- 3. TOTAL BALANCE BY CUSTOMER (CTE)
-- Calculate total deposits across all customer accounts
-- ============================================================

WITH customer_balance AS
(
    SELECT
        customer_id,
        SUM(balance_usd) AS total_balance

    FROM accounts

    GROUP BY customer_id
)

SELECT *
FROM customer_balance

ORDER BY total_balance DESC;

-- Business Insight:
-- Identifies high-value customers based on total holdings.



-- ============================================================
-- 4. ROW_NUMBER()
-- Assign unique ranking to each account by balance
-- ============================================================

SELECT
    customer_id,
    balance_usd,

    ROW_NUMBER() OVER
    (
        ORDER BY balance_usd DESC
    ) AS row_number_rank

FROM accounts;

-- Business Insight:
-- Provides unique ordering for customer prioritization.



-- ============================================================
-- 5. RANK()
-- Assign rank while allowing ties
-- ============================================================

SELECT
    customer_id,
    balance_usd,

    RANK() OVER
    (
        ORDER BY balance_usd DESC
    ) AS customer_rank

FROM accounts;

-- Business Insight:
-- Customers with equal balances receive the same rank.



-- ============================================================
-- 6. DENSE_RANK()
-- Ranking without gaps after ties
-- ============================================================

SELECT
    customer_id,
    balance_usd,

    DENSE_RANK() OVER
    (
        ORDER BY balance_usd DESC
    ) AS customerss_dense_rank

FROM accounts;

-- Business Insight:
-- Useful for customer tier allocation.



-- ============================================================
-- 7. CUSTOMER DECILE ANALYSIS
-- Divide customers into 10 groups by balance
-- ============================================================

SELECT
    customer_id,
    balance_usd,

    NTILE(10) OVER
    (
        ORDER BY balance_usd DESC
    ) AS customer_decile

FROM accounts;

-- Business Insight:
-- Decile 1 contains the most valuable customers.



-- ============================================================
-- 8. RUNNING TOTAL OF DEPOSITS
-- Track cumulative deposit growth over time
-- ============================================================

SELECT
    account_id,
    account_open_date,
    balance_usd,

    SUM(balance_usd) OVER
    (
        ORDER BY account_open_date
    ) AS running_total_deposits

FROM accounts;

-- Business Insight:
-- Measures deposit accumulation over time.



-- ============================================================
-- 9. CREDIT SCORE SEGMENTATION
-- Categorize customers by credit quality
-- ============================================================

SELECT

    CASE
        WHEN credit_score >= 750 THEN 'Excellent'
        WHEN credit_score >= 650 THEN 'Good'
        WHEN credit_score >= 550 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_segment,

    COUNT(*) AS total_customers

FROM customers

GROUP BY credit_segment

ORDER BY total_customers DESC;

-- Business Insight:
-- Evaluates overall credit health of customer base.



-- ============================================================
-- 10. CREDIT SCORE VS AVERAGE LOAN AMOUNT
-- Compare loan allocation across credit bands
-- ============================================================

SELECT

    CASE
        WHEN c.credit_score >= 750 THEN 'Excellent'
        WHEN c.credit_score >= 650 THEN 'Good'
        WHEN c.credit_score >= 550 THEN 'Fair'
        ELSE 'Poor'
    END AS credit_band,

    ROUND(AVG(l.loan_amount), 2) AS average_loan_amount

FROM customers c

JOIN loans l
ON c.customer_id = l.customer_id

GROUP BY credit_band

ORDER BY average_loan_amount DESC;

-- Business Insight:
-- Better credit profiles typically receive larger loans.



-- ============================================================
-- 11. LOAN RISK ANALYSIS
-- Assess loan portfolio risk using customer credit score
-- ============================================================

SELECT

    CASE
        WHEN c.credit_score < 550 THEN 'High Risk'
        WHEN c.credit_score < 700 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category,

    COUNT(*) AS total_loans,

    ROUND(AVG(l.loan_amount), 2) AS average_loan_amount

FROM customers c

JOIN loans l
ON c.customer_id = l.customer_id

GROUP BY risk_category

ORDER BY total_loans DESC;

-- Business Insight:
-- High-risk borrowers require enhanced monitoring.



-- ============================================================
-- 12. TOP CITIES BY TOTAL DEPOSITS
-- Identify strongest geographic markets
-- ============================================================

SELECT
    c.city,

    ROUND
    (
        SUM(a.balance_usd),
        2
    ) AS total_deposits

FROM customers c

JOIN accounts a
ON c.customer_id = a.customer_id

GROUP BY c.city

ORDER BY total_deposits DESC

LIMIT 10;

-- Business Insight:
-- Highlights top-performing deposit markets.



-- ============================================================
-- 13. TOP 20 RICHEST CUSTOMERS
-- Rank customers by total account balance
-- ============================================================

SELECT

    c.customer_id,

    CONCAT
    (
        c.first_name,
        ' ',
        c.last_name
    ) AS customer_name,

    c.city,

    ROUND
    (
        SUM(a.balance_usd),
        2
    ) AS total_balance

FROM customers c

JOIN accounts a
ON c.customer_id = a.customer_id

GROUP BY
    c.customer_id,
    customer_name,
    c.city

ORDER BY total_balance DESC

LIMIT 20;

-- Business Insight:
-- Prime candidates for investment and wealth products.



-- ============================================================
-- 14. CARD TYPE DISTRIBUTION
-- Analyze adoption of card products
-- ============================================================

SELECT
    card_type,
    COUNT(*) AS total_cards

FROM cards

GROUP BY card_type

ORDER BY total_cards DESC;

-- Business Insight:
-- Measures popularity of card offerings.



-- ============================================================
-- 15. EXECUTIVE KPI DASHBOARD
-- Portfolio-level banking performance indicators
-- ============================================================

SELECT

    (SELECT COUNT(*) FROM customers)
    AS total_customers,

    (SELECT COUNT(*) FROM accounts)
    AS total_accounts,

    (SELECT COUNT(*) FROM loans)
    AS total_loans,

    (SELECT ROUND(SUM(balance_usd), 2)
     FROM accounts)
    AS total_deposits,

    (SELECT ROUND(AVG(credit_score), 2)
     FROM customers)
    AS average_credit_score;

-- Business Insight:
-- Provides a high-level executive summary.



-- ============================================================
-- 16. CUSTOMER PERCENTILE RANK
-- Determine customer position relative to peers
-- ============================================================

SELECT

    customer_id,
    balance_usd,

    ROUND
    (
        PERCENT_RANK() OVER
        (
            ORDER BY balance_usd
        ),
        4
    ) AS percentile_rank

FROM accounts;

-- Business Insight:
-- Supports advanced customer segmentation.



-- ============================================================
-- 17. DEPOSIT TO LOAN RATIO
-- Measure liquidity and lending exposure
-- ============================================================

SELECT

    ROUND
    (
        (SELECT SUM(balance_usd) FROM accounts)
        /
        (SELECT SUM(loan_amount) FROM loans),
        2
    ) AS deposit_loan_ratio;

-- Business Insight:
-- Indicates overall banking liquidity position.



-- ============================================================
-- 18. CITY-WISE CREDIT SCORE ANALYSIS
-- Compare borrower quality across cities
-- ============================================================

SELECT

    city,

    ROUND
    (
        AVG(credit_score),
        2
    ) AS average_credit_score,

    COUNT(*) AS total_customers

FROM customers

GROUP BY city

ORDER BY average_credit_score DESC;

-- Business Insight:
-- Identifies regions with stronger credit quality.



-- ============================================================
-- 19. TOP 5 CUSTOMERS WITHIN EACH CITY
-- Use window function for regional ranking
-- ============================================================

WITH ranked_customers AS
(
    SELECT

        c.city,

        c.customer_id,

        CONCAT
        (
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,

        SUM(a.balance_usd) AS total_balance,

        DENSE_RANK() OVER
        (
            PARTITION BY c.city
            ORDER BY SUM(a.balance_usd) DESC
        ) AS city_rank

    FROM customers c

    JOIN accounts a
    ON c.customer_id = a.customer_id

    GROUP BY
        c.city,
        c.customer_id,
        customer_name
)

SELECT *
FROM ranked_customers

WHERE city_rank <= 5;

-- Business Insight:
-- Identifies local high-value customers.



-- ============================================================
-- 20. CUSTOMER VALUE SEGMENTATION
-- Classify customers by total relationship value
-- ============================================================

WITH customer_value AS
(
    SELECT

        c.customer_id,

        CONCAT
        (
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,

        SUM(a.balance_usd) AS total_balance

    FROM customers c

    JOIN accounts a
    ON c.customer_id = a.customer_id

    GROUP BY
        c.customer_id,
        customer_name
)

SELECT

    customer_id,
    customer_name,
    total_balance,

    CASE
        WHEN total_balance >= 300000 THEN 'Elite'
        WHEN total_balance >= 150000 THEN 'High Value'
        WHEN total_balance >= 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment

FROM customer_value

ORDER BY total_balance DESC;

-- Business Insight:
-- Enables personalized marketing and customer retention strategies