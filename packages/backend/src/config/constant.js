process.loadEnvFile()
export const {
  PORT = 4000,
  MSSQL_SERVER = 'localhost',
  MSSQL_PORT = 1433,
  MSSQL_DATABASE = 'master',
  MSSQL_USER = 'sa',
  MSSQL_PASSWORD = '',
  JWT_SECRET = 'secret'
} = process.env