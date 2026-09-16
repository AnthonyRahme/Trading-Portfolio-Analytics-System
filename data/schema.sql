-- Trading Portfolio Analytics System
-- Database Schema
-- SQLite 3.0+

-- CLIENTS Table
-- Stores information about counterparties (banks, funds, corporations)
CREATE TABLE IF NOT EXISTS CLIENTS (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    counterparty_type TEXT NOT NULL CHECK(counterparty_type IN ('Bank', 'Fund', 'Corporate', 'Broker')),
    country TEXT NOT NULL,
    credit_rating TEXT CHECK(credit_rating IN ('AAA', 'AA', 'A', 'BBB', 'BB', 'B', 'CCC', 'CC', 'C', 'D')),
    account_status TEXT DEFAULT 'Active' CHECK(account_status IN ('Active', 'Inactive', 'Suspended')),
    created_date DATE DEFAULT CURRENT_DATE
);

-- CURRENCIES Table
-- Standard forex currency codes
CREATE TABLE IF NOT EXISTS CURRENCIES (
    currency_code TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    country TEXT
);

-- PRODUCTS Table
-- Financial instruments traded
CREATE TABLE IF NOT EXISTS PRODUCTS (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    asset_class TEXT NOT NULL CHECK(asset_class IN ('Equity', 'FX', 'Bond', 'Derivative', 'Commodity')),
    maturity_type TEXT CHECK(maturity_type IN ('Spot', 'Forward', 'Swap', 'Option', 'Perpetual')),
    underlying_asset TEXT,
    created_date DATE DEFAULT CURRENT_DATE
);

-- TRADES Table
-- Individual trade transactions
CREATE TABLE IF NOT EXISTS TRADES (
    trade_id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    currency_code TEXT NOT NULL,
    trade_date DATE NOT NULL,
    trade_time TIME,
    side TEXT NOT NULL CHECK(side IN ('Buy', 'Sell')),
    quantity REAL NOT NULL,
    execution_price REAL NOT NULL,
    trade_value REAL NOT NULL,
    status TEXT DEFAULT 'Open' CHECK(status IN ('Open', 'Settled', 'Cancelled', 'Failed')),
    settlement_date DATE,
    notes TEXT,
    created_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id),
    FOREIGN KEY (currency_code) REFERENCES CURRENCIES(currency_code),
    CHECK(quantity > 0),
    CHECK(execution_price > 0),
    CHECK(trade_value > 0)
);

-- POSITIONS Table
-- Current portfolio positions (aggregated by client/product/currency)
CREATE TABLE IF NOT EXISTS POSITIONS (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    currency_code TEXT NOT NULL,
    total_quantity REAL NOT NULL,
    average_cost REAL NOT NULL,
    mark_to_market_price REAL NOT NULL,
    current_value REAL NOT NULL,
    unrealized_pnl REAL NOT NULL,
    last_update DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (client_id) REFERENCES CLIENTS(client_id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id),
    FOREIGN KEY (currency_code) REFERENCES CURRENCIES(currency_code),
    UNIQUE(client_id, product_id, currency_code)
);

-- SETTLEMENTS Table
-- Trade settlement status tracking
CREATE TABLE IF NOT EXISTS SETTLEMENTS (
    settlement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trade_id INTEGER NOT NULL UNIQUE,
    settlement_date DATE NOT NULL,
    value_date DATE,
    status TEXT DEFAULT 'Pending' CHECK(status IN ('Pending', 'Settled', 'Failed', 'Cancelled')),
    settlement_amount REAL NOT NULL,
    settlement_currency TEXT,
    counterparty_bank TEXT,
    notes TEXT,
    created_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trade_id) REFERENCES TRADES(trade_id),
    FOREIGN KEY (settlement_currency) REFERENCES CURRENCIES(currency_code)
);

-- MARKET_RATES Table
-- Historical market price data for mark-to-market calculations
CREATE TABLE IF NOT EXISTS MARKET_RATES (
    rate_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    currency_code TEXT NOT NULL,
    rate_date DATE NOT NULL,
    rate_price REAL NOT NULL,
    source TEXT,
    created_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id),
    FOREIGN KEY (currency_code) REFERENCES CURRENCIES(currency_code),
    UNIQUE(product_id, currency_code, rate_date)
);

-- Create Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_trades_client ON TRADES(client_id);
CREATE INDEX IF NOT EXISTS idx_trades_product ON TRADES(product_id);
CREATE INDEX IF NOT EXISTS idx_trades_currency ON TRADES(currency_code);
CREATE INDEX IF NOT EXISTS idx_trades_status ON TRADES(status);
CREATE INDEX IF NOT EXISTS idx_trades_date ON TRADES(trade_date);

CREATE INDEX IF NOT EXISTS idx_positions_client ON POSITIONS(client_id);
CREATE INDEX IF NOT EXISTS idx_positions_product ON POSITIONS(product_id);
CREATE INDEX IF NOT EXISTS idx_positions_currency ON POSITIONS(currency_code);

CREATE INDEX IF NOT EXISTS idx_settlements_trade ON SETTLEMENTS(trade_id);
CREATE INDEX IF NOT EXISTS idx_settlements_status ON SETTLEMENTS(status);
CREATE INDEX IF NOT EXISTS idx_settlements_date ON SETTLEMENTS(settlement_date);

CREATE INDEX IF NOT EXISTS idx_market_rates_product ON MARKET_RATES(product_id);
CREATE INDEX IF NOT EXISTS idx_market_rates_date ON MARKET_RATES(rate_date);
