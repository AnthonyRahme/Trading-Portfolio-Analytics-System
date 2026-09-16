-- Trading Portfolio Analytics System
-- Advanced Queries
-- Complex multi-table queries for deep analysis

-- ==============================================================================
-- SETTLEMENT ANALYSIS
-- ==============================================================================

-- Settlement delay analysis
SELECT 
    s.settlement_id,
    c.name as client_name,
    t.trade_date,
    s.settlement_date,
    CAST((julianday(s.settlement_date) - julianday(t.trade_date)) AS INTEGER) as settlement_days,
    s.settlement_amount,
    s.status
FROM SETTLEMENTS s
JOIN TRADES t ON s.trade_id = t.trade_id
JOIN CLIENTS c ON t.client_id = c.client_id
ORDER BY settlement_days DESC;

-- Overdue settlements (>3 days)
SELECT 
    c.name as client_name,
    pr.name as product_name,
    t.trade_date,
    s.settlement_date,
    CAST((julianday('now') - julianday(s.settlement_date)) AS INTEGER) as days_overdue,
    s.settlement_amount
FROM SETTLEMENTS s
JOIN TRADES t ON s.trade_id = t.trade_id
JOIN CLIENTS c ON t.client_id = c.client_id
JOIN PRODUCTS pr ON t.product_id = pr.product_id
WHERE s.status = 'Pending'
    AND CAST((julianday('now') - julianday(s.settlement_date)) AS INTEGER) > 3
ORDER BY days_overdue DESC;


-- ==============================================================================
-- RISK CONCENTRATION ANALYSIS
-- ==============================================================================

-- Client concentration with percentages
WITH client_totals AS (
    SELECT 
        c.client_id,
        c.name,
        SUM(p.current_value) as client_value
    FROM POSITIONS p
    JOIN CLIENTS c ON p.client_id = c.client_id
    GROUP BY c.client_id, c.name
),
total_portfolio AS (
    SELECT SUM(client_value) as portfolio_value FROM client_totals
)
SELECT 
    ct.client_id,
    ct.name,
    ct.client_value,
    tp.portfolio_value,
    ROUND(ct.client_value / tp.portfolio_value * 100, 2) as concentration_percent,
    SUM(ROUND(ct.client_value / tp.portfolio_value * 100, 2)) OVER (
        ORDER BY ct.client_value DESC
    ) as cumulative_percent
FROM client_totals ct
CROSS JOIN total_portfolio tp
ORDER BY ct.client_value DESC;

-- Currency concentration analysis
WITH currency_exposure AS (
    SELECT 
        cur.currency_code,
        SUM(p.current_value) as exposure
    FROM POSITIONS p
    JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
    GROUP BY p.currency_code
),
total_exposure AS (
    SELECT SUM(exposure) as total FROM currency_exposure
)
SELECT 
    ce.currency_code,
    ce.exposure,
    te.total,
    ROUND(ce.exposure / te.total * 100, 2) as concentration_percent
FROM currency_exposure ce
CROSS JOIN total_exposure te
ORDER BY ce.exposure DESC;


-- ==============================================================================
-- P&L ANALYSIS
-- ==============================================================================

-- P&L by client and asset class
SELECT 
    c.name as client_name,
    pr.asset_class,
    COUNT(DISTINCT p.position_id) as num_positions,
    SUM(p.current_value) as total_value,
    SUM(p.unrealized_pnl) as total_pnl,
    ROUND(SUM(p.unrealized_pnl) / SUM(p.current_value) * 100, 2) as return_percent
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
GROUP BY p.client_id, c.name, pr.asset_class
ORDER BY c.name, total_pnl DESC;

-- P&L contribution by product
SELECT 
    pr.name as product_name,
    pr.asset_class,
    COUNT(DISTINCT p.position_id) as num_positions,
    SUM(p.current_value) as total_value,
    SUM(p.unrealized_pnl) as total_pnl,
    ROUND(SUM(p.unrealized_pnl) / 
        (SELECT SUM(unrealized_pnl) FROM POSITIONS WHERE unrealized_pnl > 0) * 100, 2) as pnl_contribution_percent
FROM POSITIONS p
JOIN PRODUCTS pr ON p.product_id = pr.product_id
WHERE p.unrealized_pnl > 0
GROUP BY p.product_id, pr.name, pr.asset_class
ORDER BY total_pnl DESC;


-- ==============================================================================
-- COUNTERPARTY RISK DASHBOARD
-- ==============================================================================

-- Comprehensive counterparty risk view
SELECT 
    c.client_id,
    c.name,
    c.counterparty_type,
    c.credit_rating,
    COUNT(DISTINCT t.trade_id) as num_trades,
    SUM(CASE WHEN t.status = 'Open' THEN 1 ELSE 0 END) as open_trades,
    SUM(CASE WHEN s.status = 'Pending' THEN 1 ELSE 0 END) as pending_settlements,
    SUM(p.current_value) as exposure,
    SUM(p.unrealized_pnl) as pnl,
    COUNT(DISTINCT p.currency_code) as num_currencies,
    COUNT(DISTINCT p.product_id) as num_products,
    MAX(t.trade_date) as last_trade_date
FROM CLIENTS c
LEFT JOIN TRADES t ON c.client_id = t.client_id
LEFT JOIN POSITIONS p ON c.client_id = p.client_id
LEFT JOIN SETTLEMENTS s ON t.trade_id = s.trade_id
GROUP BY c.client_id, c.name, c.counterparty_type, c.credit_rating
HAVING exposure > 0
ORDER BY exposure DESC;


-- ==============================================================================
-- TRADE FLOW ANALYSIS
-- ==============================================================================

-- Net position by client and currency (buy vs sell)
SELECT 
    c.name as client_name,
    cur.currency_code,
    SUM(CASE WHEN t.side = 'Buy' THEN t.quantity ELSE 0 END) as buy_quantity,
    SUM(CASE WHEN t.side = 'Sell' THEN t.quantity ELSE 0 END) as sell_quantity,
    SUM(CASE WHEN t.side = 'Buy' THEN t.quantity ELSE -t.quantity END) as net_quantity,
    SUM(CASE WHEN t.side = 'Buy' THEN t.trade_value ELSE 0 END) as buy_value,
    SUM(CASE WHEN t.side = 'Sell' THEN t.trade_value ELSE 0 END) as sell_value,
    COUNT(DISTINCT t.trade_id) as num_trades
FROM TRADES t
JOIN CLIENTS c ON t.client_id = c.client_id
JOIN CURRENCIES cur ON t.currency_code = cur.currency_code
WHERE t.status != 'Cancelled'
GROUP BY t.client_id, c.name, t.currency_code, cur.currency_code
ORDER BY c.name, net_quantity DESC;

-- Trading activity trend
SELECT 
    DATE(t.trade_date) as trade_date,
    COUNT(DISTINCT t.trade_id) as num_trades,
    SUM(t.trade_value) as total_value,
    SUM(CASE WHEN t.side = 'Buy' THEN 1 ELSE 0 END) as buy_trades,
    SUM(CASE WHEN t.side = 'Sell' THEN 1 ELSE 0 END) as sell_trades,
    COUNT(DISTINCT t.client_id) as num_clients,
    COUNT(DISTINCT t.product_id) as num_products
FROM TRADES t
WHERE t.status != 'Cancelled'
GROUP BY DATE(t.trade_date)
ORDER BY trade_date DESC;


-- ==============================================================================
-- MARKET EXPOSURE ANALYSIS
-- ==============================================================================

-- Exposure by market and client segment
SELECT 
    pr.asset_class,
    c.counterparty_type,
    COUNT(DISTINCT p.position_id) as num_positions,
    SUM(p.current_value) as exposure,
    SUM(p.unrealized_pnl) as total_pnl,
    AVG(p.unrealized_pnl) as avg_pnl,
    MIN(p.mark_to_market_price) as min_price,
    MAX(p.mark_to_market_price) as max_price
FROM POSITIONS p
JOIN PRODUCTS pr ON p.product_id = pr.product_id
JOIN CLIENTS c ON p.client_id = c.client_id
GROUP BY pr.asset_class, c.counterparty_type
ORDER BY pr.asset_class, exposure DESC;


-- ==============================================================================
-- WATCHLIST: POSITIONS REQUIRING ATTENTION
-- ==============================================================================

-- Positions with high P&L drawdown
SELECT 
    c.name as client_name,
    pr.name as product_name,
    p.current_value,
    p.unrealized_pnl,
    ROUND(p.unrealized_pnl / p.current_value * 100, 2) as return_percent,
    CASE 
        WHEN p.unrealized_pnl < 0 THEN 'Loss'
        WHEN p.unrealized_pnl > p.current_value * 0.25 THEN 'High Gain'
        ELSE 'Moderate Gain'
    END as status
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
WHERE ABS(p.unrealized_pnl) > 50000
ORDER BY p.unrealized_pnl ASC;

-- Large positions that are illiquid
SELECT 
    c.name as client_name,
    pr.name as product_name,
    pr.asset_class,
    p.total_quantity,
    p.current_value,
    COUNT(DISTINCT t.trade_id) as recent_trades_30d
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
JOIN PRODUCTS pr ON p.product_id = pr.product_id
LEFT JOIN TRADES t ON p.product_id = t.product_id 
    AND t.trade_date >= date('now', '-30 days')
WHERE p.current_value > (SELECT SUM(current_value) * 0.05 FROM POSITIONS)
GROUP BY p.position_id, c.name, pr.name, pr.asset_class, p.total_quantity, p.current_value
HAVING recent_trades_30d < 5
ORDER BY p.current_value DESC;
