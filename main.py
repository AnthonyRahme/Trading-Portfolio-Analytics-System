#!/usr/bin/env python
"""
Trading Portfolio Analytics System
Main Entry Point
"""

import sys
import os
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from src.database import DatabaseConnection, create_sample_database
from src.portfolio_analysis import PortfolioAnalyzer
from src.risk_analysis import RiskAnalyzer
from src.reports import ReportGenerator


def print_menu():
    """Print main menu"""
    print("\n" + "="*60)
    print(" TRADING PORTFOLIO ANALYTICS SYSTEM".center(60))
    print("="*60)
    print("\n1. Portfolio Analysis")
    print("2. Risk Analysis")
    print("3. Generate Reports")
    print("4. Run Setup (Initialize Database)")
    print("5. Exit")
    print("\n" + "-"*60)


def run_portfolio_analysis():
    """Run portfolio analysis"""
    print("\n📊 PORTFOLIO ANALYSIS")
    analyzer = PortfolioAnalyzer()
    analyzer.print_portfolio_summary()
    analyzer.db.disconnect()


def run_risk_analysis():
    """Run risk analysis"""
    print("\n⚠️  RISK ANALYSIS")
    analyzer = RiskAnalyzer()
    analyzer.print_risk_summary()
    analyzer.db.disconnect()


def run_report_generation():
    """Generate all reports"""
    print("\n📄 REPORT GENERATION")
    generator = ReportGenerator()
    generator.generate_all_reports()


def run_setup():
    """Initialize system"""
    print("\n🔧 SYSTEM SETUP")
    if create_sample_database('trading.db'):
        print("\n✓ Database initialized with sample data")
        print("✓ System is ready to use")
    else:
        print("\n✗ Failed to initialize database")


def main():
    """Main application loop"""
    # Check if database exists
    if not os.path.exists('trading.db'):
        print("\n⚠️  Database not found. Running setup...")
        run_setup()
    
    while True:
        print_menu()
        choice = input("Select option (1-5): ").strip()
        
        if choice == '1':
            run_portfolio_analysis()
        elif choice == '2':
            run_risk_analysis()
        elif choice == '3':
            run_report_generation()
        elif choice == '4':
            run_setup()
        elif choice == '5':
            print("\n👋 Goodbye!\n")
            break
        else:
            print("❌ Invalid option. Please try again.")


if __name__ == '__main__':
    main()
