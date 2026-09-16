-- Sample Trading Data for Portfolio Analytics System
-- This data represents a realistic trading scenario with multiple clients, products, and currencies

-- Insert Currencies
INSERT INTO CURRENCIES (currency_code, name, country) VALUES
('USD', 'US Dollar', 'United States'),
('EUR', 'Euro', 'European Union'),
('GBP', 'British Pound', 'United Kingdom'),
('AED', 'UAE Dirham', 'United Arab Emirates'),
('JPY', 'Japanese Yen', 'Japan'),
('CHF', 'Swiss Franc', 'Switzerland'),
('CAD', 'Canadian Dollar', 'Canada'),
('SGD', 'Singapore Dollar', 'Singapore'),
('HKD', 'Hong Kong Dollar', 'Hong Kong'),
('AUD', 'Australian Dollar', 'Australia');

-- Insert Clients
INSERT INTO CLIENTS (name, counterparty_type, country, credit_rating, account_status) VALUES
('HSBC Bank Middle East', 'Bank', 'UAE', 'AA', 'Active'),
('Goldman Sachs International', 'Bank', 'UK', 'AA', 'Active'),
('Morgan Stanley', 'Bank', 'USA', 'A', 'Active'),
('Barclays Capital', 'Bank', 'UK', 'A', 'Active'),
('Dubai Investment Fund', 'Fund', 'UAE', 'A', 'Active'),
('Sovereign Wealth Partners', 'Fund', 'Saudi Arabia', 'AAA', 'Active'),
('Tech Innovations Corp', 'Corporate', 'USA', 'BBB', 'Active'),
('European Energy AG', 'Corporate', 'Germany', 'BB', 'Active'),
('Peninsula Trading Group', 'Broker', 'UAE', 'BBB', 'Active'),
('Asia Capital Markets', 'Broker', 'Singapore', 'A', 'Active');

-- Insert Products
INSERT INTO PRODUCTS (name, asset_class, maturity_type, underlying_asset) VALUES
('EUR/USD FX Spot', 'FX', 'Spot', 'Euro vs US Dollar'),
('Gold Futures', 'Commodity', 'Forward', 'Precious Metal'),
('Microsoft Stock', 'Equity', 'Perpetual', 'MSFT'),
('10Y EUR Bond', 'Bond', 'Forward', 'European Government Bond'),
('JPY/USD Forward', 'FX', 'Forward', 'Yen vs US Dollar'),
('S&P 500 Index', 'Equity', 'Perpetual', 'US Equity Index'),
('Crude Oil WTI', 'Commodity', 'Forward', 'Energy'),
('GBP/USD Currency Swap', 'Derivative', 'Swap', 'Sterling vs Dollar Swap'),
('Interest Rate Swap USD', 'Derivative', 'Swap', '5Y Fixed vs Floating'),
('DAX Index Call Option', 'Derivative', 'Option', 'German Equity Index');

-- Insert Trades
-- HSBC trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(1, 1, 'EUR', '2024-11-10', 'Buy', 1000000, 1.0850, 1085000, 'Settled', '2024-11-12'),
(1, 3, 'USD', '2024-11-09', 'Buy', 50000, 416.25, 20812500, 'Settled', '2024-11-11'),
(1, 6, 'USD', '2024-11-08', 'Sell', 75000, 5950.50, 446287500, 'Settled', '2024-11-10'),
(1, 9, 'USD', '2024-11-12', 'Buy', 25000000, 0.0245, 612500, 'Open', NULL);

-- Goldman Sachs trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(2, 4, 'EUR', '2024-11-11', 'Buy', 50000, 102.50, 5125000, 'Settled', '2024-11-13'),
(2, 5, 'JPY', '2024-11-09', 'Sell', 500000000, 0.00655, 3275000, 'Settled', '2024-11-11'),
(2, 8, 'GBP', '2024-11-10', 'Buy', 2000000, 1.2625, 2525000, 'Settled', '2024-11-12'),
(2, 10, 'EUR', '2024-11-12', 'Buy', 100000, 25.50, 2550000, 'Open', NULL);

-- Morgan Stanley trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(3, 2, 'USD', '2024-11-07', 'Buy', 500, 1950.00, 975000, 'Settled', '2024-11-09'),
(3, 3, 'USD', '2024-11-11', 'Buy', 75000, 416.80, 31260000, 'Settled', '2024-11-13'),
(3, 7, 'USD', '2024-11-10', 'Buy', 100000, 73.25, 7325000, 'Settled', '2024-11-12'),
(3, 9, 'USD', '2024-11-12', 'Sell', 10000000, 0.0248, 248000, 'Open', NULL);

-- Barclays trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(4, 1, 'EUR', '2024-11-11', 'Sell', 500000, 1.0830, 541500, 'Settled', '2024-11-13'),
(4, 4, 'EUR', '2024-11-12', 'Buy', 75000, 102.80, 7710000, 'Open', NULL),
(4, 6, 'USD', '2024-11-08', 'Buy', 50000, 5945.75, 297287500, 'Settled', '2024-11-10');

-- Dubai Investment Fund trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(5, 3, 'USD', '2024-11-09', 'Buy', 100000, 416.50, 41650000, 'Settled', '2024-11-11'),
(5, 6, 'USD', '2024-11-10', 'Buy', 100000, 5948.00, 594800000, 'Settled', '2024-11-12'),
(5, 2, 'USD', '2024-11-12', 'Buy', 250, 1945.00, 486250, 'Open', NULL);

-- Sovereign Wealth Partners trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(6, 4, 'EUR', '2024-11-11', 'Buy', 200000, 102.75, 20550000, 'Settled', '2024-11-13'),
(6, 6, 'USD', '2024-11-09', 'Buy', 250000, 5945.00, 1486250000, 'Settled', '2024-11-11'),
(6, 9, 'USD', '2024-11-12', 'Buy', 50000000, 0.02460, 1230000, 'Open', NULL);

-- Tech Innovations Corp trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(7, 3, 'USD', '2024-11-10', 'Buy', 25000, 416.75, 10418750, 'Settled', '2024-11-12'),
(7, 6, 'USD', '2024-11-11', 'Buy', 10000, 5950.25, 59502500, 'Settled', '2024-11-13');

-- European Energy AG trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(8, 7, 'USD', '2024-11-10', 'Buy', 50000, 74.50, 3725000, 'Settled', '2024-11-12'),
(8, 5, 'JPY', '2024-11-12', 'Sell', 1000000000, 0.00650, 6500000, 'Open', NULL);

-- Peninsula Trading Group trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(9, 1, 'EUR', '2024-11-11', 'Buy', 250000, 1.0840, 271000, 'Settled', '2024-11-13'),
(9, 2, 'USD', '2024-11-10', 'Buy', 100, 1950.50, 195050, 'Settled', '2024-11-12');

-- Asia Capital Markets trades
INSERT INTO TRADES (client_id, product_id, currency_code, trade_date, side, quantity, execution_price, trade_value, status, settlement_date) VALUES
(10, 1, 'EUR', '2024-11-12', 'Buy', 500000, 1.0845, 542250, 'Open', NULL),
(10, 3, 'USD', '2024-11-11', 'Buy', 50000, 416.60, 20830000, 'Settled', '2024-11-13');

-- Insert Positions
INSERT INTO POSITIONS (client_id, product_id, currency_code, total_quantity, average_cost, mark_to_market_price, current_value, unrealized_pnl) VALUES
(1, 1, 'EUR', 1000000, 1.0850, 1.0865, 1086500, 1500),
(1, 3, 'USD', 50000, 416.25, 417.50, 20875000, 62500),
(1, 6, 'USD', -75000, 5950.50, 5955.00, -446625000, -343750),
(2, 4, 'EUR', 50000, 102.50, 102.75, 5137500, 12500),
(2, 5, 'JPY', -500000000, 0.00655, 0.00658, -3290000, 150000),
(2, 8, 'GBP', 2000000, 1.2625, 1.2650, 2530000, 50000),
(3, 2, 'USD', 500, 1950.00, 1955.00, 977500, 2500),
(3, 3, 'USD', 75000, 416.80, 417.50, 31312500, 52500),
(3, 7, 'USD', 100000, 73.25, 73.50, 7350000, 25000),
(4, 1, 'EUR', -500000, 1.0830, 1.0865, -541625, -17500),
(4, 6, 'USD', 50000, 5945.75, 5955.00, 297750000, 461250),
(5, 2, 'USD', 250, 1945.00, 1955.00, 488750, 2500),
(5, 3, 'USD', 100000, 416.50, 417.50, 41750000, 100000),
(5, 6, 'USD', 100000, 5948.00, 5955.00, 595500000, 700000),
(6, 4, 'EUR', 200000, 102.75, 102.75, 20550000, 0),
(6, 6, 'USD', 250000, 5945.00, 5955.00, 1488750000, 2500000),
(7, 3, 'USD', 25000, 416.75, 417.50, 10437500, 18750),
(7, 6, 'USD', 10000, 5950.25, 5955.00, 59550000, 47500),
(8, 7, 'USD', 50000, 74.50, 73.50, 3675000, -50000),
(9, 1, 'EUR', 250000, 1.0840, 1.0865, 271625, 6250),
(9, 2, 'USD', 100, 1950.50, 1955.00, 195500, 450),
(10, 3, 'USD', 50000, 416.60, 417.50, 20875000, 45000);

-- Insert Settlements
INSERT INTO SETTLEMENTS (trade_id, settlement_date, value_date, status, settlement_amount, settlement_currency, counterparty_bank) VALUES
(1, '2024-11-12', '2024-11-12', 'Settled', 1085000, 'EUR', 'Euroclear'),
(2, '2024-11-11', '2024-11-11', 'Settled', 20812500, 'USD', 'DTCC'),
(3, '2024-11-10', '2024-11-10', 'Settled', 446287500, 'USD', 'DTCC'),
(4, '2024-11-13', '2024-11-13', 'Pending', 612500, 'USD', 'DTCC'),
(5, '2024-11-13', '2024-11-13', 'Settled', 5125000, 'EUR', 'Euroclear'),
(6, '2024-11-11', '2024-11-11', 'Settled', 3275000, 'JPY', 'JSCC'),
(7, '2024-11-12', '2024-11-12', 'Settled', 2525000, 'GBP', 'LCH'),
(8, '2024-11-13', '2024-11-13', 'Pending', 2550000, 'EUR', 'Euroclear'),
(9, '2024-11-09', '2024-11-09', 'Settled', 975000, 'USD', 'DTCC'),
(10, '2024-11-13', '2024-11-13', 'Settled', 31260000, 'USD', 'DTCC'),
(11, '2024-11-12', '2024-11-12', 'Settled', 7325000, 'USD', 'DTCC'),
(12, '2024-11-13', '2024-11-13', 'Pending', 248000, 'USD', 'DTCC'),
(13, '2024-11-13', '2024-11-13', 'Settled', 541500, 'EUR', 'Euroclear'),
(14, '2024-11-14', '2024-11-14', 'Pending', 7710000, 'EUR', 'Euroclear'),
(15, '2024-11-10', '2024-11-10', 'Settled', 297287500, 'USD', 'DTCC'),
(16, '2024-11-11', '2024-11-11', 'Settled', 41650000, 'USD', 'DTCC'),
(17, '2024-11-12', '2024-11-12', 'Settled', 594800000, 'USD', 'DTCC'),
(18, '2024-11-13', '2024-11-13', 'Pending', 486250, 'USD', 'DTCC'),
(19, '2024-11-13', '2024-11-13', 'Settled', 20550000, 'EUR', 'Euroclear'),
(20, '2024-11-11', '2024-11-11', 'Settled', 1486250000, 'USD', 'DTCC'),
(21, '2024-11-13', '2024-11-13', 'Pending', 1230000, 'USD', 'DTCC'),
(22, '2024-11-12', '2024-11-12', 'Settled', 10418750, 'USD', 'DTCC'),
(23, '2024-11-13', '2024-11-13', 'Settled', 59502500, 'USD', 'DTCC'),
(24, '2024-11-12', '2024-11-12', 'Settled', 3725000, 'USD', 'DTCC'),
(25, '2024-11-13', '2024-11-13', 'Pending', 6500000, 'JPY', 'JSCC'),
(26, '2024-11-13', '2024-11-13', 'Settled', 271000, 'EUR', 'Euroclear'),
(27, '2024-11-12', '2024-11-12', 'Settled', 195050, 'USD', 'DTCC'),
(28, '2024-11-13', '2024-11-13', 'Pending', 542250, 'EUR', 'Euroclear'),
(29, '2024-11-13', '2024-11-13', 'Settled', 20830000, 'USD', 'DTCC');

-- Insert Market Rates (for mark-to-market calculations)
INSERT INTO MARKET_RATES (product_id, currency_code, rate_date, rate_price, source) VALUES
(1, 'EUR', '2024-11-12', 1.0865, 'Bloomberg'),
(2, 'USD', '2024-11-12', 1955.00, 'Bloomberg'),
(3, 'USD', '2024-11-12', 417.50, 'Reuters'),
(4, 'EUR', '2024-11-12', 102.75, 'Bloomberg'),
(5, 'JPY', '2024-11-12', 0.00658, 'Reuters'),
(6, 'USD', '2024-11-12', 5955.00, 'Bloomberg'),
(7, 'USD', '2024-11-12', 73.50, 'Bloomberg'),
(8, 'GBP', '2024-11-12', 1.2650, 'Reuters'),
(9, 'USD', '2024-11-12', 0.02460, 'Bloomberg'),
(10, 'EUR', '2024-11-12', 25.50, 'Bloomberg');
