# Trading Portfolio Analytics System

A financial data analysis system built with Python and SQL to analyze trading portfolios, calculate risk metrics, and generate actionable insights for portfolio managers and traders.

## Project Overview

This system demonstrates proficiency in:
- **SQL**: Data retrieval, aggregation, and complex queries on financial datasets
- **Python**: Data analysis using Pandas, structured problem-solving
- **Financial Concepts**: Portfolio analysis, trade lifecycle, risk management, settlement processes
- **Data-Driven Decision Making**: Extracting insights from structured financial data

## Features

### Core Analytics
- **Portfolio Valuation**: Aggregate portfolio value by client, currency, and product type
- **Risk Analysis**: Calculate exposure by client, currency, and asset class
- **Settlement Tracking**: Monitor pending and completed settlements
- **Trade Performance**: Analyze profit/loss, execution prices, and trade flow
- **Client Exposure**: Risk assessment by counterparty
- **Currency Analysis**: Exposure analysis across multiple currency pairs

### Outputs
- CSV reports for further analysis
- Terminal-based summaries for quick insights
- SQL query templates for custom analysis

## Project Structure

```
trading_portfolio_analytics/
├── README.md
├── requirements.txt
├── data/
│   ├── schema.sql              # Database schema and table definitions
│   └── sample_data.sql         # Sample trading data (populated via INSERT statements)
├── src/
│   ├── database.py             # Database connection and utilities
│   ├── portfolio_analysis.py   # Main portfolio analysis module
│   ├── risk_analysis.py        # Risk calculations and exposure metrics
│   └── reports.py              # Report generation
├── queries/
│   ├── portfolio_queries.sql   # Reusable SQL queries for common tasks
│   └── advanced_queries.sql    # Complex multi-table queries
├── output/
│   └── reports/                # Generated CSV reports
└── .gitignore
```

## Quick Start

### 1. Prerequisites
```bash
pip install -r requirements.txt
```

### 2. Set Up Database
```bash
sqlite3 trading.db < data/schema.sql
sqlite3 trading.db < data/sample_data.sql
```

### 3. Run Analysis
```bash
# Portfolio overview
python -m src.portfolio_analysis

# Risk analysis
python -m src.risk_analysis

# Generate reports
python -m src.reports
```

## Database Schema

### Core Tables

**CLIENTS**
- `client_id` (PK)
- `name`
- `counterparty_type` (Bank, Fund, Corporate)
- `country`
- `credit_rating`

**PRODUCTS**
- `product_id` (PK)
- `name`
- `asset_class` (Equity, FX, Bond, Derivative)
- `maturity_type` (Spot, Forward, Swap)

**CURRENCIES**
- `currency_code` (PK, e.g., USD, EUR, AED)
- `name`

**TRADES**
- `trade_id` (PK)
- `client_id` (FK)
- `product_id` (FK)
- `currency_code` (FK)
- `trade_date`
- `execution_price`
- `quantity`
- `trade_value` (calculated)
- `status` (Open, Settled, Cancelled)

**POSITIONS**
- `position_id` (PK)
- `client_id` (FK)
- `product_id` (FK)
- `currency_code` (FK)
- `total_quantity`
- `mark_to_market_price`
- `current_value`
- `unrealized_pnl`

**SETTLEMENTS**
- `settlement_id` (PK)
- `trade_id` (FK)
- `settlement_date`
- `status` (Pending, Settled, Failed)
- `settlement_amount`

## Example Queries

### Portfolio Value by Client
```sql
SELECT 
    c.name,
    SUM(p.current_value) as portfolio_value,
    COUNT(DISTINCT p.product_id) as num_products
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
GROUP BY c.client_id, c.name
ORDER BY portfolio_value DESC;
```

### Currency Exposure
```sql
SELECT 
    cur.currency_code,
    cur.name,
    SUM(p.current_value) as total_exposure,
    COUNT(DISTINCT p.client_id) as num_clients
FROM POSITIONS p
JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
GROUP BY p.currency_code
ORDER BY total_exposure DESC;
```

### Settlement Status
```sql
SELECT 
    status,
    COUNT(*) as count,
    SUM(settlement_amount) as total_amount
FROM SETTLEMENTS
GROUP BY status;
```

### High-Risk Clients
```sql
SELECT 
    c.name,
    c.credit_rating,
    SUM(p.current_value) as exposure,
    SUM(p.unrealized_pnl) as potential_loss
FROM POSITIONS p
JOIN CLIENTS c ON p.client_id = c.client_id
WHERE c.credit_rating IN ('BB', 'B', 'CCC')
GROUP BY c.client_id, c.name, c.credit_rating
HAVING exposure > 100000
ORDER BY exposure DESC;
```

## Key Analytical Insights

The system answers critical financial questions:

1. **Portfolio Health**: What is our total exposure and P&L?
2. **Client Risk**: Which clients represent the highest counterparty risk?
3. **Currency Management**: What is our net position in each currency?
4. **Settlement Efficiency**: How many trades are pending settlement?
5. **Product Performance**: Which asset classes are performing well?
6. **Exposure Limits**: Are we within risk limits by client/currency?

## Technologies Used

- **Python 3.8+**: Data analysis and scripting
- **SQLite**: Lightweight SQL database
- **Pandas**: Data manipulation and analysis
- **SQL**: Complex queries and aggregations

## Learning Objectives

This project demonstrates:
- ✅ SQL fundamentals (SELECT, JOIN, GROUP BY, aggregation functions)
- ✅ Database design for financial systems
- ✅ Python data analysis workflows
- ✅ Understanding of trading and settlement processes
- ✅ Risk management concepts
- ✅ Professional code structure and documentation

## Future Enhancements

- Real-time data integration (market feeds)
- Advanced risk models (VaR, stress testing)
- Dashboard visualization (Plotly, Tableau)
- Machine learning for trade recommendation
- API for real-time portfolio queries

## Contact

Anthony Rahme  
LinkedIn: [Your LinkedIn]  
Email: anthonyrahme448@gmail.com
