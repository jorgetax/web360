import {Sequelize} from 'sequelize'
import {MSSQL_DATABASE, MSSQL_PASSWORD, MSSQL_PORT, MSSQL_SERVER, MSSQL_USER} from './constant.js'

const database = new Sequelize({
  dialect: 'mssql',
  host: MSSQL_SERVER,
  database: MSSQL_DATABASE,
  username: MSSQL_USER,
  password: MSSQL_PASSWORD,
  port: MSSQL_PORT,
  logging: false,
})
export default database

