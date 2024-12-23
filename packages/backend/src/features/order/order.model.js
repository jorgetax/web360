import {pool} from '../../config/database.js'

async function create(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(product))
    .query('EXEC sp.sp_create_order @data = @data')

  return recordset[0] ?? null
}

async function orders() {
  const database = await pool()
  const {recordset} = await database.request()
    .query('SELECT * FROM vw.vw_orders')

  return recordset
}

async function update(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(product))
    .query('EXEC sp.sp_update_order @data = @data')

  return recordset[0] ?? null
}

export default {create, orders, update}