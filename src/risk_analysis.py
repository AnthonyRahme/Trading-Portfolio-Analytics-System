"""
Risk Analysis Module
Analyzes counterparty risk, concentration risk, and settlement risk
"""

import pandas as pd
from src.database import DatabaseConnection, QUERIES


class RiskAnalyzer:
    """Analyzes portfolio and counterparty risks"""
    
    def __init__(self, db_path: str = 'trading.db'):
        """Initialize risk analyzer with database connection"""
        self.db = DatabaseConnection(db_path)
        self.db.connect()
    
    def get_high_risk_clients(self) -> pd.DataFrame:
        """
        Identify high-risk clients (lower credit ratings with high exposure)
        
        Returns:
            pd.DataFrame: High-risk clients
        """
        df = self.db.query_to_dataframe(QUERIES['high_risk_clients'])
        return df
    
    def get_counterparty_risk(self) -> pd.DataFrame:
        """
        Calculate counterparty risk concentration
        
        Returns:
            pd.DataFrame: Counterparty risk metrics
        """
        query = """
            SELECT 
                c.client_id,
                c.name,
                c.counterparty_type,
                c.credit_rating,
                SUM(p.current_value) as exposure,
                SUM(p.unrealized_pnl) as pnl,
                COUNT(DISTINCT t.trade_id) as num_trades,
                COUNT(DISTINCT p.currency_code) as currency_concentration,
                COUNT(DISTINCT p.product_id) as product_concentration
            FROM CLIENTS c
            LEFT JOIN POSITIONS p ON c.client_id = p.client_id
            LEFT JOIN TRADES t ON c.client_id = t.client_id
            GROUP BY c.client_id, c.name, c.counterparty_type, c.credit_rating
            HAVING exposure > 0
            ORDER BY exposure DESC;
        """
        df = self.db.query_to_dataframe(query)
        return df
    
    def get_settlement_risk(self) -> pd.DataFrame:
        """
        Analyze settlement risk (pending settlements)
        
        Returns:
            pd.DataFrame: Settlement risk details
        """
        df = self.db.query_to_dataframe(QUERIES['pending_settlements'])
        return df
    
    def get_concentration_risk(self) -> dict:
        """
        Calculate concentration risk metrics
        
        Returns:
            dict: Concentration risk statistics
        """
        # Get exposure by client
        query = """
            SELECT 
                SUM(current_value) as total_portfolio,
                COUNT(DISTINCT client_id) as num_clients,
                MAX(current_value) as max_exposure
            FROM POSITIONS;
        """
        result = self.db.execute_query(query)
        
        if result and result[0][0]:
            total = result[0][0]
            num_clients = result[0][1]
            max_exposure = result[0][2]
            
            concentration = {
                'total_portfolio': total,
                'num_clients': num_clients,
                'max_exposure': max_exposure,
                'max_exposure_percent': (max_exposure / total * 100) if total > 0 else 0,
                'avg_client_exposure': total / num_clients if num_clients > 0 else 0,
                'herfindahl_index': self._calculate_herfindahl_index()
            }
            return concentration
        return {}
    
    def _calculate_herfindahl_index(self) -> float:
        """
        Calculate Herfindahl-Hirschman Index (HHI) for concentration
        Values > 2500 indicate high concentration
        
        Returns:
            float: HHI value
        """
        query = """
            SELECT 
                SUM(current_value) as total,
                current_value
            FROM POSITIONS
            GROUP BY client_id;
        """
        result = self.db.execute_query(query)
        
        if result:
            total = sum([r[0] for r in result]) if result[0][0] else 1
            hhi = sum([(r[1] / total * 100) ** 2 for r in result if r[1] > 0])
            return hhi
        return 0
    
    def get_currency_concentration(self) -> pd.DataFrame:
        """
        Get currency concentration risk
        
        Returns:
            pd.DataFrame: Currency concentration metrics
        """
        query = """
            SELECT 
                cur.currency_code,
                SUM(p.current_value) as exposure,
                (SELECT SUM(current_value) FROM POSITIONS) as total_portfolio,
                ROUND(SUM(p.current_value) / (SELECT SUM(current_value) FROM POSITIONS) * 100, 2) as concentration_percent,
                COUNT(DISTINCT p.client_id) as num_clients,
                COUNT(DISTINCT p.product_id) as num_products
            FROM POSITIONS p
            JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
            GROUP BY p.currency_code, cur.currency_code
            ORDER BY exposure DESC;
        """
        df = self.db.query_to_dataframe(query)
        return df
    
    def print_risk_summary(self) -> None:
        """Print formatted risk summary to console"""
        print("\n" + "="*80)
        print(" RISK ANALYSIS SUMMARY".center(80))
        print("="*80)
        
        # Concentration risk
        print("\n" + "-"*80)
        print(" CONCENTRATION RISK".center(80))
        print("-"*80)
        
        conc = self.get_concentration_risk()
        if conc:
            print(f"\nTotal Portfolio Value:     ${conc['total_portfolio']:>15,.2f}")
            print(f"Number of Clients:         {conc['num_clients']:>15}")
            print(f"Average Exposure per Client: ${conc['avg_client_exposure']:>10,.2f}")
            print(f"Largest Single Exposure:   ${conc['max_exposure']:>15,.2f} ({conc['max_exposure_percent']:.2f}%)")
            
            hhi = conc['herfindahl_index']
            print(f"\nHerfindahl-Hirschman Index: {hhi:>12.2f}")
            if hhi > 2500:
                print("  ⚠️  HIGH CONCENTRATION RISK - Consider diversification")
            elif hhi > 1500:
                print("  ⚠️  MODERATE CONCENTRATION RISK")
            else:
                print("  ✓  Acceptable concentration levels")
        
        # High-risk clients
        print("\n" + "-"*80)
        print(" HIGH-RISK CLIENTS".center(80))
        print("-"*80)
        
        high_risk = self.get_high_risk_clients()
        if not high_risk.empty:
            print(f"\nFound {len(high_risk)} high-risk clients:\n")
            for idx, row in high_risk.head(5).iterrows():
                print(f"{idx + 1}. {row['name']} - {row['credit_rating']} rated")
                print(f"   Exposure: ${row['exposure']:,.2f}")
                print(f"   P&L:      ${row['unrealized_pnl']:,.2f}")
                print(f"   Trades:   {int(row['num_trades'])}")
        else:
            print("\n✓ No high-risk clients identified")
        
        # Currency concentration
        print("\n" + "-"*80)
        print(" CURRENCY CONCENTRATION RISK".center(80))
        print("-"*80)
        
        curr_conc = self.get_currency_concentration()
        if not curr_conc.empty:
            print("\n")
            for idx, row in curr_conc.iterrows():
                status = "⚠️ " if row['concentration_percent'] > 30 else "✓ "
                print(f"{status} {row['currency_code']}: {row['concentration_percent']:>6.1f}% exposure")
        
        # Settlement risk
        print("\n" + "-"*80)
        print(" SETTLEMENT RISK".center(80))
        print("-"*80)
        
        settlements = self.get_settlement_risk()
        if not settlements.empty:
            print(f"\n⚠️  {len(settlements)} pending settlements\n")
            total_pending = settlements['settlement_amount'].sum()
            print(f"Total Amount Pending: ${total_pending:,.2f}\n")
            
            for idx, row in settlements.head(5).iterrows():
                print(f"Trade #{row['trade_id']}: {row['client_name']}")
                print(f"  Product:    {row['product_name']}")
                print(f"  Amount:     ${row['settlement_amount']:,.2f}")
                print(f"  Days Pending: {row['days_pending']} days\n")
        else:
            print("\n✓ No pending settlements")
        
        print("\n" + "="*80 + "\n")


def main():
    """Main entry point for risk analysis"""
    print("\n⚠️  Initializing Risk Analysis...")
    
    analyzer = RiskAnalyzer()
    analyzer.print_risk_summary()
    
    analyzer.db.disconnect()


if __name__ == '__main__':
    main()
