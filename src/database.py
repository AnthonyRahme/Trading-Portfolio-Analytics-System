"""
Database Connection and Utilities
Handles SQLite database connections and query execution
"""

import sqlite3
import pandas as pd
from pathlib import Path
from typing import List, Dict, Any, Optional

class DatabaseConnection:
    """Manages SQLite database connections and queries"""
    
    def __init__(self, db_path: str = 'trading.db'):
        """
        Initialize database connection
        
        Args:
            db_path: Path to SQLite database file
        """
        self.db_path = db_path
        self.connection = None
        self.cursor = None
    
    def connect(self) -> bool:
        """
        Establish database connection
        
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            self.connection = sqlite3.connect(self.db_path)
            self.cursor = self.connection.cursor()
            print(f"✓ Connected to database: {self.db_path}")
            return True
        except sqlite3.Error as e:
            print(f"✗ Database connection error: {e}")
            return False
    
    def disconnect(self) -> None:
        """Close database connection"""
        if self.connection:
            self.connection.close()
            print("✓ Database connection closed")
    
    def execute_query(self, query: str, params: tuple = ()) -> Optional[List[tuple]]:
        """
        Execute SELECT query
        
        Args:
            query: SQL query string
            params: Query parameters (for parameterized queries)
        
        Returns:
            List of tuples containing query results, or None if error
        """
        try:
            self.cursor.execute(query, params)
            return self.cursor.fetchall()
        except sqlite3.Error as e:
            print(f"✗ Query execution error: {e}")
            return None
    
    def execute_update(self, query: str, params: tuple = ()) -> bool:
        """
        Execute INSERT/UPDATE/DELETE query
        
        Args:
            query: SQL query string
            params: Query parameters
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            self.cursor.execute(query, params)
            self.connection.commit()
            print(f"✓ Query executed successfully ({self.cursor.rowcount} rows affected)")
            return True
        except sqlite3.Error as e:
            print(f"✗ Update error: {e}")
            self.connection.rollback()
            return False
    
    def query_to_dataframe(self, query: str) -> pd.DataFrame:
        """
        Execute query and return results as Pandas DataFrame
        
        Args:
            query: SQL query string
        
        Returns:
            pd.DataFrame: Query results
        """
        try:
            df = pd.read_sql_query(query, self.connection)
            return df
        except Exception as e:
            print(f"✗ Error converting query to DataFrame: {e}")
            return pd.DataFrame()
    
    def get_column_names(self, query: str) -> List[str]:
        """
        Get column names from query result
        
        Args:
            query: SQL query string
        
        Returns:
            List of column names
        """
        self.cursor.execute(query)
        return [description[0] for description in self.cursor.description]


# Common reusable queries
QUERIES = {
    'portfolio_by_client': """
        SELECT 
            c.client_id,
            c.name as client_name,
            c.counterparty_type,
            c.credit_rating,
            SUM(p.current_value) as portfolio_value,
            SUM(p.unrealized_pnl) as total_pnl,
            COUNT(DISTINCT p.product_id) as num_products,
            COUNT(DISTINCT p.currency_code) as num_currencies
        FROM POSITIONS p
        JOIN CLIENTS c ON p.client_id = c.client_id
        GROUP BY c.client_id, c.name, c.counterparty_type, c.credit_rating
        ORDER BY portfolio_value DESC;
    """,
    
    'currency_exposure': """
        SELECT 
            cur.currency_code,
            cur.name as currency_name,
            SUM(p.current_value) as total_exposure,
            SUM(p.total_quantity) as total_quantity,
            SUM(p.unrealized_pnl) as total_pnl,
            COUNT(DISTINCT p.client_id) as num_clients,
            COUNT(DISTINCT p.product_id) as num_products
        FROM POSITIONS p
        JOIN CURRENCIES cur ON p.currency_code = cur.currency_code
        GROUP BY p.currency_code, cur.name
        ORDER BY total_exposure DESC;
    """,
    
    'settlement_status': """
        SELECT 
            status,
            COUNT(*) as count,
            SUM(settlement_amount) as total_amount,
            AVG(settlement_amount) as average_amount
        FROM SETTLEMENTS
        GROUP BY status;
    """,
    
    'high_risk_clients': """
        SELECT 
            c.client_id,
            c.name,
            c.credit_rating,
            SUM(p.current_value) as exposure,
            SUM(p.unrealized_pnl) as unrealized_pnl,
            COUNT(DISTINCT t.trade_id) as num_trades
        FROM POSITIONS p
        JOIN CLIENTS c ON p.client_id = c.client_id
        LEFT JOIN TRADES t ON p.client_id = t.client_id
        WHERE c.credit_rating IN ('BB', 'B', 'CCC', 'CC', 'C', 'D')
        GROUP BY c.client_id, c.name, c.credit_rating
        HAVING exposure > 0
        ORDER BY exposure DESC;
    """,
    
    'pending_settlements': """
        SELECT 
            t.trade_id,
            c.name as client_name,
            pr.name as product_name,
            cur.currency_code,
            t.trade_date,
            s.settlement_date,
            s.settlement_amount,
            CAST((julianday('now') - julianday(s.settlement_date)) AS INTEGER) as days_pending
        FROM SETTLEMENTS s
        JOIN TRADES t ON s.trade_id = t.trade_id
        JOIN CLIENTS c ON t.client_id = c.client_id
        JOIN PRODUCTS pr ON t.product_id = pr.product_id
        JOIN CURRENCIES cur ON t.currency_code = cur.currency_code
        WHERE s.status = 'Pending'
        ORDER BY s.settlement_date ASC;
    """,
    
    'product_performance': """
        SELECT 
            pr.product_id,
            pr.name as product_name,
            pr.asset_class,
            COUNT(t.trade_id) as num_trades,
            SUM(CASE WHEN t.side = 'Buy' THEN t.quantity ELSE -t.quantity END) as net_quantity,
            SUM(p.current_value) as total_position_value,
            SUM(p.unrealized_pnl) as total_pnl,
            AVG(p.unrealized_pnl) as avg_pnl,
            COUNT(DISTINCT t.client_id) as num_clients
        FROM PRODUCTS pr
        LEFT JOIN TRADES t ON pr.product_id = t.product_id
        LEFT JOIN POSITIONS p ON pr.product_id = p.product_id
        GROUP BY pr.product_id, pr.name, pr.asset_class
        ORDER BY total_pnl DESC;
    """
}


def create_sample_database(db_path: str = 'trading.db') -> bool:
    """
    Create sample database from schema and data files
    
    Args:
        db_path: Path to create database
    
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        db = DatabaseConnection(db_path)
        
        if not db.connect():
            return False
        
        # Load schema
        schema_path = Path(__file__).parent.parent / 'data' / 'schema.sql'
        with open(schema_path, 'r') as f:
            schema = f.read()
        
        # Execute schema
        db.cursor.executescript(schema)
        
        # Load sample data
        data_path = Path(__file__).parent.parent / 'data' / 'sample_data.sql'
        with open(data_path, 'r') as f:
            data = f.read()
        
        # Execute data insertion
        db.cursor.executescript(data)
        db.connection.commit()
        
        db.disconnect()
        print(f"✓ Sample database created successfully: {db_path}")
        return True
    
    except Exception as e:
        print(f"✗ Error creating sample database: {e}")
        return False
