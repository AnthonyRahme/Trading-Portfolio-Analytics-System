"""
Trading Portfolio Analytics System
A financial data analysis platform for portfolio management and risk analysis
"""

__version__ = '1.0.0'
__author__ = 'Anthony Rahme'

from src.database import DatabaseConnection
from src.portfolio_analysis import PortfolioAnalyzer
from src.risk_analysis import RiskAnalyzer
from src.reports import ReportGenerator

__all__ = [
    'DatabaseConnection',
    'PortfolioAnalyzer',
    'RiskAnalyzer',
    'ReportGenerator'
]
