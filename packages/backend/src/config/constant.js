process.loadEnvFile()
export const {
  PORT = 4000,
  MSSQL_SERVER = 'localhost',
  MSSQL_PORT = 1433,
  MSSQL_DATABASE = 'commerce',
  MSSQL_USER = 'SA',
  MSSQL_PASSWORD = '',
  JWT_SECRET = 'secret'
} = process.env