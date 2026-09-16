#!/usr/bin/env python
"""
Setup script for Trading Portfolio Analytics System
Initializes the database and runs initial analysis
"""

import os
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from src.database import create_sample_database
from src.portfolio_analysis import PortfolioAnalyzer
from src.risk_analysis import RiskAnalyzer
from src.reports import ReportGenerator


def main():
    """Main setup and initialization"""
    print("\n" + "="*80)
    print(" TRADING PORTFOLIO ANALYTICS SYSTEM - SETUP".center(80))
    print("="*80)
    
    # Step 1: Create database
    print("\n📦 Step 1: Creating sample database...")
    if create_sample_database('trading.db'):
        print("✓ Database created successfully\n")
    else:
        print("✗ Failed to create database\n")
        return
    
    # Step 2: Run portfolio analysis
    print("📊 Step 2: Running portfolio analysis...")
    analyzer = PortfolioAnalyzer()
    analyzer.print_portfolio_summary()
    analyzer.db.disconnect()
    
    # Step 3: Run risk analysis
    print("⚠️  Step 3: Running risk analysis...")
    risk = RiskAnalyzer()
    risk.print_risk_summary()
    risk.db.disconnect()
    
    # Step 4: Generate reports
    print("📄 Step 4: Generating reports...")
    generator = ReportGenerator()
    generator.generate_all_reports()
    
    # Success message
    print("\n" + "="*80)
    print(" SETUP COMPLETE".center(80))
    print("="*80)
    print("\n✓ System is ready to use!")
    print("\nNext steps:")
    print("  1. Review generated reports in output/reports/")
    print("  2. Query the database: sqlite3 trading.db")
    print("  3. Run analysis modules: python -m src.portfolio_analysis")
    print("  4. Check queries/ directory for SQL examples")
    print("\n" + "="*80 + "\n")


if __name__ == '__main__':
    main()
