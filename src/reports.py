"""
Reports Module
Generates CSV reports and summaries
"""

import os
from datetime import datetime
import pandas as pd
from src.portfolio_analysis import PortfolioAnalyzer
from src.risk_analysis import RiskAnalyzer
from src.database import DatabaseConnection, QUERIES


class ReportGenerator:
    """Generates portfolio and risk analysis reports"""
    
    def __init__(self, db_path: str = 'trading.db', output_dir: str = 'output/reports'):
        """
        Initialize report generator
        
        Args:
            db_path: Path to database
            output_dir: Directory to save reports
        """
        self.db_path = db_path
        self.output_dir = output_dir
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # Create output directory if not exists
        os.makedirs(output_dir, exist_ok=True)
    
    def generate_all_reports(self) -> None:
        """Generate all available reports"""
        print("\n📊 Generating Reports...")
        print(f"Output Directory: {self.output_dir}\n")
        
        self.generate_portfolio_report()
        self.generate_risk_report()
        self.generate_client_exposure_report()
        self.generate_settlement_report()
        self.generate_currency_analysis_report()
        self.generate_product_analysis_report()
        
        print(f"\n✓ All reports generated successfully at {self.output_dir}/")
    
    def generate_portfolio_report(self) -> str:
        """Generate portfolio overview report"""
        analyzer = PortfolioAnalyzer(self.db_path)
        
        # Get all data
        portfolio = analyzer.get_portfolio_overview()
        asset_breakdown = analyzer.get_asset_class_breakdown()
        
        # Save main portfolio report
        filename = f'{self.output_dir}/01_Portfolio_Overview_{self.timestamp}.csv'
        portfolio.to_csv(filename, index=False)
        print(f"✓ Portfolio Overview Report: {filename}")
        
        # Save asset breakdown
        filename_assets = f'{self.output_dir}/01b_Asset_Breakdown_{self.timestamp}.csv'
        asset_breakdown.to_csv(filename_assets, index=False)
        print(f"✓ Asset Class Breakdown: {filename_assets}")
        
        analyzer.db.disconnect()
        return filename
    
    def generate_risk_report(self) -> str:
        """Generate risk analysis report"""
        analyzer = RiskAnalyzer(self.db_path)
        
        # Get risk data
        counterparty_risk = analyzer.get_counterparty_risk()
        high_risk = analyzer.get_high_risk_clients()
        
        # Save counterparty risk
        filename = f'{self.output_dir}/02_Counterparty_Risk_{self.timestamp}.csv'
        counterparty_risk.to_csv(filename, index=False)
        print(f"✓ Counterparty Risk Report: {filename}")
        
        # Save high-risk clients
        if not high_risk.empty:
            filename_high = f'{self.output_dir}/02b_High_Risk_Clients_{self.timestamp}.csv'
            high_risk.to_csv(filename_high, index=False)
            print(f"✓ High-Risk Clients Report: {filename_high}")
        
        analyzer.db.disconnect()
        return filename
    
    def generate_client_exposure_report(self) -> str:
        """Generate detailed client exposure report"""
        db = DatabaseConnection(self.db_path)
        db.connect()
        
        query = """
            SELECT 
                c.client_id,
                c.name,
                c.counterparty_type,
                c.credit_rating,
                pr.name as product_name,
                pr.asset_class,
                cur.currency_code,
                p.total_quantity,
                p.mark_to_market_price,
                p.current_value,
                p.unrealized_pnl
            FROM POSITIONS p
            JOIN CLIENTS c ON p.client_id = c.client_id
            JOIN PRODUCTS pr ON p.product_id = pr.product_id
            JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
            ORDER BY c.name, p.current_value DESC;
        """
        
        df = db.query_to_dataframe(query)
        filename = f'{self.output_dir}/03_Client_Exposure_Detail_{self.timestamp}.csv'
        df.to_csv(filename, index=False)
        print(f"✓ Client Exposure Detail Report: {filename}")
        
        db.disconnect()
        return filename
    
    def generate_settlement_report(self) -> str:
        """Generate settlement status report"""
        db = DatabaseConnection(self.db_path)
        db.connect()
        
        # Pending settlements
        query_pending = QUERIES['pending_settlements']
        df_pending = db.query_to_dataframe(query_pending)
        
        filename = f'{self.output_dir}/04_Pending_Settlements_{self.timestamp}.csv'
        df_pending.to_csv(filename, index=False)
        print(f"✓ Pending Settlements Report: {filename}")
        
        # Settlement summary
        query_summary = """
            SELECT 
                s.status,
                COUNT(*) as count,
                SUM(s.settlement_amount) as total_amount,
                AVG(s.settlement_amount) as avg_amount,
                MIN(s.settlement_date) as earliest_date,
                MAX(s.settlement_date) as latest_date
            FROM SETTLEMENTS s
            GROUP BY s.status;
        """
        df_summary = db.query_to_dataframe(query_summary)
        
        filename_summary = f'{self.output_dir}/04b_Settlement_Summary_{self.timestamp}.csv'
        df_summary.to_csv(filename_summary, index=False)
        print(f"✓ Settlement Summary Report: {filename_summary}")
        
        db.disconnect()
        return filename
    
    def generate_currency_analysis_report(self) -> str:
        """Generate currency exposure analysis"""
        db = DatabaseConnection(self.db_path)
        db.connect()
        
        df = db.query_to_dataframe(QUERIES['currency_exposure'])
        filename = f'{self.output_dir}/05_Currency_Analysis_{self.timestamp}.csv'
        df.to_csv(filename, index=False)
        print(f"✓ Currency Analysis Report: {filename}")
        
        db.disconnect()
        return filename
    
    def generate_product_analysis_report(self) -> str:
        """Generate product performance analysis"""
        db = DatabaseConnection(self.db_path)
        db.connect()
        
        df = db.query_to_dataframe(QUERIES['product_performance'])
        filename = f'{self.output_dir}/06_Product_Analysis_{self.timestamp}.csv'
        df.to_csv(filename, index=False)
        print(f"✓ Product Analysis Report: {filename}")
        
        db.disconnect()
        return filename


def main():
    """Main entry point for report generation"""
    generator = ReportGenerator()
    generator.generate_all_reports()


if __name__ == '__main__':
    main()
