import mssql from 'mssql'

const config = {
  user: 'SA',
  password: 'Password123',
  server: 'localhost',
  port: 1433,
  database: 'web360',
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
}

export async function pool() {
  try {
    return await mssql.connect(config)
  } catch (e) {
    console.log(e.message)
  }
}