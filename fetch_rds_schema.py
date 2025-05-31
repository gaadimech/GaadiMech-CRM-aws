#!/usr/bin/env python3
"""
Fetch RDS Database Schema
========================
This script connects to the RDS database and displays the complete schema.
"""

import psycopg2
from migration_config import RDS_URL

def fetch_schema():
    """Fetch and display the RDS database schema."""
    conn = psycopg2.connect(RDS_URL)
    cursor = conn.cursor()

    print('📊 AWS RDS Database Schema')
    print('=' * 50)
    print(f'🔗 Database: {RDS_URL.split("@")[1].split("/")[1]}')
    print(f'🏠 Host: {RDS_URL.split("@")[1].split("/")[0]}')
    print()

    # Get all tables
    cursor.execute("""
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        ORDER BY tablename
    """)
    tables = cursor.fetchall()

    print(f'📋 Tables Found: {len(tables)}')
    for (table,) in tables:
        print(f'  - {table}')

    print()
    print('🔍 Detailed Schema Information:')
    print('-' * 50)

    for (table,) in tables:
        print(f'\n📝 Table: {table}')
        print('─' * (len(table) + 8))
        
        # Get column information
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default, character_maximum_length
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = %s
            ORDER BY ordinal_position
        """, (table,))
        
        columns = cursor.fetchall()
        
        for col_name, data_type, is_nullable, col_default, char_max_len in columns:
            nullable = '(NULL)' if is_nullable == 'YES' else '(NOT NULL)'
            max_len = f'({char_max_len})' if char_max_len else ''
            default = f' DEFAULT {col_default}' if col_default else ''
            print(f'  📌 {col_name}: {data_type}{max_len} {nullable}{default}')
        
        # Get record count
        try:
            cursor.execute(f'SELECT COUNT(*) FROM "{table}"')
            count = cursor.fetchone()[0]
            print(f'  📊 Records: {count:,}')
        except Exception as e:
            print(f'  📊 Records: Error counting - {e}')
            
        # Get constraints
        cursor.execute("""
            SELECT tc.constraint_type, tc.constraint_name, kcu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            WHERE tc.table_schema = 'public' AND tc.table_name = %s
            ORDER BY tc.constraint_type, kcu.column_name
        """, (table,))
        
        constraints = cursor.fetchall()
        if constraints:
            print(f'  🔐 Constraints:')
            for constraint_type, constraint_name, column_name in constraints:
                print(f'    - {constraint_type}: {column_name} ({constraint_name})')

    # Get indexes
    print(f'\n🏃 Database Indexes:')
    print('-' * 20)
    cursor.execute("""
        SELECT schemaname, tablename, indexname, indexdef
        FROM pg_indexes 
        WHERE schemaname = 'public'
        ORDER BY tablename, indexname
    """)
    
    indexes = cursor.fetchall()
    current_table = None
    for schema, table, index_name, index_def in indexes:
        if table != current_table:
            print(f'\n📝 Table: {table}')
            current_table = table
        print(f'  🔍 {index_name}')
        print(f'    {index_def}')

    # Get foreign key relationships
    print(f'\n🔗 Foreign Key Relationships:')
    print('-' * 30)
    cursor.execute("""
        SELECT tc.table_name, kcu.column_name, ccu.table_name AS referenced_table, ccu.column_name AS referenced_column
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
        ORDER BY tc.table_name, kcu.column_name
    """)
    
    fks = cursor.fetchall()
    for table, column, ref_table, ref_column in fks:
        print(f'  {table}.{column} → {ref_table}.{ref_column}')

    conn.close()
    print('\n✅ Schema fetch completed!')

if __name__ == "__main__":
    try:
        fetch_schema()
    except Exception as e:
        print(f"❌ Error fetching schema: {e}") 