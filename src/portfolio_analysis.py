"""
Portfolio Analysis Module
Analyzes trading portfolios and generates key metrics
"""

import pandas as pd
from src.database import DatabaseConnection, QUERIES


class PortfolioAnalyzer:
    """Analyzes portfolio positions and performance"""
    
    def __init__(self, db_path: str = 'trading.db'):
        """Initialize portfolio analyzer with database connection"""
        self.db = DatabaseConnection(db_path)
        self.db.connect()
    
    def get_portfolio_overview(self) -> pd.DataFrame:
        """
        Get overall portfolio summary by client
        
        Returns:
            pd.DataFrame: Portfolio summary data
        """
        df = self.db.query_to_dataframe(QUERIES['portfolio_by_client'])
        return df
    
    def get_total_portfolio_value(self) -> float:
        """
        Calculate total portfolio value across all clients
        
        Returns:
            float: Total portfolio value
        """
        query = """
            SELECT SUM(current_value) as total_value
            FROM POSITIONS
            WHERE current_value > 0;
        """
        result = self.db.execute_query(query)
        return result[0][0] if result and result[0][0] else 0
    
    def get_total_pnl(self) -> float:
        """
        Calculate total unrealized P&L
        
        Returns:
            float: Total unrealized P&L
        """
        query = """
            SELECT SUM(unrealized_pnl) as total_pnl
            FROM POSITIONS;
        """
        result = self.db.execute_query(query)
        return result[0][0] if result and result[0][0] else 0
    
    def get_currency_exposure(self) -> pd.DataFrame:
        """
        Get exposure by currency
        
        Returns:
            pd.DataFrame: Currency exposure breakdown
        """
        df = self.db.query_to_dataframe(QUERIES['currency_exposure'])
        return df
    
    def get_top_clients_by_exposure(self, limit: int = 10) -> pd.DataFrame:
        """
        Get top clients by total exposure
        
        Args:
            limit: Number of top clients to return
        
        Returns:
            pd.DataFrame: Top clients by exposure
        """
        query = f"""
            {QUERIES['portfolio_by_client']}
            LIMIT {limit};
        """
        df = self.db.query_to_dataframe(query)
        return df
    
    def get_client_portfolio_detail(self, client_id: int) -> pd.DataFrame:
        """
        Get detailed portfolio positions for a specific client
        
        Args:
            client_id: Client ID to analyze
        
        Returns:
            pd.DataFrame: Client portfolio details
        """
        query = """
            SELECT 
                c.name as client_name,
                pr.name as product_name,
                pr.asset_class,
                cur.currency_code,
                p.total_quantity,
                p.average_cost,
                p.mark_to_market_price,
                p.current_value,
                p.unrealized_pnl,
                ROUND((p.unrealized_pnl / p.current_value * 100), 2) as pnl_percent
            FROM POSITIONS p
            JOIN CLIENTS c ON p.client_id = c.client_id
            JOIN PRODUCTS pr ON p.product_id = pr.product_id
            JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
            WHERE p.client_id = ?
            ORDER BY p.current_value DESC;
        """
        df = self.db.query_to_dataframe(query)
        return df
    
    def get_asset_class_breakdown(self) -> pd.DataFrame:
        """
        Get portfolio breakdown by asset class
        
        Returns:
            pd.DataFrame: Asset class breakdown
        """
        query = """
            SELECT 
                pr.asset_class,
                COUNT(DISTINCT p.position_id) as num_positions,
                COUNT(DISTINCT p.client_id) as num_clients,
                SUM(p.current_value) as total_value,
                SUM(p.unrealized_pnl) as total_pnl,
                ROUND(SUM(p.current_value) / (SELECT SUM(current_value) FROM POSITIONS) * 100, 2) as portfolio_percent
            FROM POSITIONS p
            JOIN PRODUCTS pr ON p.product_id = pr.product_id
            GROUP BY pr.asset_class
            ORDER BY total_value DESC;
        """
        df = self.db.query_to_dataframe(query)
        return df
    
    def print_portfolio_summary(self) -> None:
        """Print formatted portfolio summary to console"""
        print("\n" + "="*80)
        print(" PORTFOLIO SUMMARY".center(80))
        print("="*80)
        
        # Overall metrics
        total_value = self.get_total_portfolio_value()
        total_pnl = self.get_total_pnl()
        
        print(f"\nTotal Portfolio Value:    ${total_value:,.2f}")
        print(f"Total Unrealized P&L:     ${total_pnl:,.2f}")
        print(f"Return:                   {(total_pnl / (total_value - total_pnl) * 100):,.2f}%" if (total_value - total_pnl) > 0 else "N/A")
        
        # Top clients
        print("\n" + "-"*80)
        print(" TOP 5 CLIENTS BY EXPOSURE".center(80))
        print("-"*80)
        top_clients = self.get_top_clients_by_exposure(5)
        for idx, row in top_clients.iterrows():
            print(f"\n{idx + 1}. {row['client_name']} ({row['counterparty_type']})")
            print(f"   Credit Rating: {row['credit_rating']}")
            print(f"   Exposure:      ${row['portfolio_value']:>15,.2f}")
            print(f"   P&L:           ${row['total_pnl']:>15,.2f}")
            print(f"   Products:      {int(row['num_products']):>15} | Currencies: {int(row['num_currencies'])}")
        
        # Asset class breakdown
        print("\n" + "-"*80)
        print(" PORTFOLIO BREAKDOWN BY ASSET CLASS".center(80))
        print("-"*80)
        asset_breakdown = self.get_asset_class_breakdown()
        for idx, row in asset_breakdown.iterrows():
            print(f"\n{row['asset_class']}")
            print(f"  Value:           ${row['total_value']:>15,.2f} ({row['portfolio_percent']:>5.1f}%)")
            print(f"  P&L:             ${row['total_pnl']:>15,.2f}")
            print(f"  Positions:       {int(row['num_positions']):>15} | Clients: {int(row['num_clients'])}")
        
        # Currency exposure
        print("\n" + "-"*80)
        print(" TOP CURRENCY EXPOSURES".center(80))
        print("-"*80)
        currencies = self.get_currency_exposure().head(5)
        for idx, row in currencies.iterrows():
            print(f"\n{row['currency_code']} ({row['currency_name']})")
            print(f"  Exposure:        ${row['total_exposure']:>15,.2f}")
            print(f"  P&L:             ${row['total_pnl']:>15,.2f}")
            print(f"  Clients:         {int(row['num_clients']):>15} | Products: {int(row['num_products'])}")
        
        print("\n" + "="*80 + "\n")


def main():
    """Main entry point for portfolio analysis"""
    print("\n🔍 Initializing Portfolio Analysis...")
    
    analyzer = PortfolioAnalyzer()
    analyzer.print_portfolio_summary()
    
    analyzer.db.disconnect()


if __name__ == '__main__':
    main()
