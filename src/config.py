import os


class Config:
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    PATH_RAW_DATABASE = os.path.join(BASE_DIR, 'data', 'db', 'raw.db')
    PATH_FIXED_DATABASE = os.path.join(BASE_DIR, 'data', 'db', 'fixed.db')
    PATH_OLAP_DATABASE = os.path.join(BASE_DIR, 'data', 'db', 'olap.db')

    PATH_FIX_DB_SQL = os.path.join(BASE_DIR, 'data', 'sql', 'fix-db.sql')
    PATH_UPDATE_OLAP_SQL = os.path.join(BASE_DIR, 'data', 'sql', 'update-olap.sql')
