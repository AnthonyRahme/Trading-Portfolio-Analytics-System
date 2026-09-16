-- Trading Portfolio Analytics System
-- Common Portfolio Queries
-- Reference queries for typical portfolio analysis tasks

-- ==============================================================================
-- PORTFOLIO VALUE QUERIES
-- ==============================================================================

-- Total portfolio value
SELECT 
    SUM(current_value) as total_portfolio_value,
    SUM(unrealized_pnl) as total_pnl,
    COUNT(DISTINCT client_id) as num_clients,
    COUNT(DISTINCT product_id) as num_products
FROM POSITIONS
WHERE current_value > 0;

-- Portfolio value by client
SELECT 
    c.name as client_name,
    c.counterparty_type,
    SUM(p.current_value) as portfolio_value,
    SUM(p.unrealized_pnl) as total_pnl,
    COUNT(DISTINCT p.product_id) as num_products
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
GROUP BY p.client_id, c.name, c.counterparty_type
ORDER BY portfolio_value DESC;

-- Portfolio value by asset class
SELECT 
    pr.asset_class,
    COUNT(DISTINCT p.position_id) as num_positions,
    SUM(p.current_value) as total_value,
    SUM(p.unrealized_pnl) as total_pnl,
    ROUND(SUM(p.current_value) / (SELECT SUM(current_value) FROM POSITIONS) * 100, 2) as percentage
FROM POSITIONS p
JOIN PRODUCTS pr ON p.product_id = pr.product_id
GROUP BY pr.asset_class
ORDER BY total_value DESC;

-- Portfolio value by currency
SELECT 
    cur.currency_code,
    cur.name as currency_name,
    SUM(p.current_value) as total_exposure,
    COUNT(DISTINCT p.client_id) as num_clients,
    COUNT(DISTINCT p.product_id) as num_products
FROM POSITIONS p
JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
GROUP BY p.currency_code, cur.name
ORDER BY total_exposure DESC;


-- ==============================================================================
-- CLIENT ANALYSIS QUERIES
-- ==============================================================================

-- Client detailed holdings
SELECT 
    c.name as client_name,
    c.counterparty_type,
    c.credit_rating,
    pr.name as product_name,
    pr.asset_class,
    cur.currency_code,
    p.total_quantity,
    p.average_cost,
    p.mark_to_market_price,
    p.current_value,
    p.unrealized_pnl
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
WHERE c.client_id = 1  -- Replace with target client ID
ORDER BY p.current_value DESC;

-- Clients by counterparty type
SELECT 
    c.counterparty_type,
    COUNT(DISTINCT c.client_id) as num_clients,
    SUM(p.current_value) as total_exposure,
    AVG(p.current_value) as avg_exposure,
    SUM(p.unrealized_pnl) as total_pnl
FROM CLIENTS c
LEFT JOIN POSITIONS p ON c.client_id = p.client_id
GROUP BY c.counterparty_type
ORDER BY total_exposure DESC;

-- Clients by credit rating
SELECT 
    c.credit_rating,
    COUNT(DISTINCT c.client_id) as num_clients,
    SUM(p.current_value) as total_exposure,
    SUM(p.unrealized_pnl) as total_pnl,
    AVG(p.unrealized_pnl) as avg_pnl
FROM CLIENTS c
LEFT JOIN POSITIONS p ON c.client_id = p.client_id
WHERE c.credit_rating IS NOT NULL
GROUP BY c.credit_rating
ORDER BY c.credit_rating;


-- ==============================================================================
-- PERFORMANCE ANALYSIS QUERIES
-- ==============================================================================

-- Top performing positions
SELECT 
    c.name as client_name,
    pr.name as product_name,
    cur.currency_code,
    p.current_value,
    p.unrealized_pnl,
    ROUND(p.unrealized_pnl / p.current_value * 100, 2) as return_percent
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
WHERE p.unrealized_pnl > 0
ORDER BY p.unrealized_pnl DESC
LIMIT 20;

-- Worst performing positions
SELECT 
    c.name as client_name,
    pr.name as product_name,
    cur.currency_code,
    p.current_value,
    p.unrealized_pnl,
    ROUND(p.unrealized_pnl / p.current_value * 100, 2) as return_percent
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
WHERE p.unrealized_pnl < 0
ORDER BY p.unrealized_pnl ASC
LIMIT 20;


-- ==============================================================================
-- TRADE ACTIVITY QUERIES
-- ==============================================================================

-- Recent trades
SELECT 
    t.trade_id,
    c.name as client_name,
    pr.name as product_name,
    cur.currency_code,
    t.trade_date,
    t.side,
    t.quantity,
    t.execution_price,
    t.trade_value,
    t.status
FROM TRADES t
JOIN CLIENTS c ON t.client_id = c.client_id
JOIN PRODUCTS pr ON t.product_id = pr.product_id
JOIN CURRENCIES cur ON t.currency_code = cur.currency_code
ORDER BY t.trade_date DESC, t.trade_id DESC
LIMIT 50;

-- Trade activity by client
SELECT 
    c.name as client_name,
    COUNT(DISTINCT t.trade_id) as num_trades,
    SUM(CASE WHEN t.side = 'Buy' THEN t.trade_value ELSE 0 END) as buy_value,
    SUM(CASE WHEN t.side = 'Sell' THEN t.trade_value ELSE 0 END) as sell_value,
    MAX(t.trade_date) as last_trade_date
FROM TRADES t
JOIN CLIENTS c ON t.client_id = c.client_id
GROUP BY t.client_id, c.name
HAVING num_trades > 0
ORDER BY num_trades DESC;

-- Trade volume by product
SELECT 
    pr.name as product_name,
    pr.asset_class,
    COUNT(DISTINCT t.trade_id) as num_trades,
    SUM(t.quantity) as total_quantity,
    SUM(t.trade_value) as total_volume,
    AVG(t.execution_price) as avg_price
FROM TRADES t
JOIN PRODUCTS pr ON t.product_id = pr.product_id
WHERE t.status != 'Cancelled'
GROUP BY t.product_id, pr.name, pr.asset_class
ORDER BY total_volume DESC;
