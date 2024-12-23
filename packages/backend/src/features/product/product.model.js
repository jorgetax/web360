import {pool} from '../../config/database.js'

async function create(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(product))
    .query('EXEC sp.sp_create_product @data = @data')

  return recordset[0] ?? null
}

async function products() {
  const database = await pool()
  const {recordset} = await database.request().query('SELECT * FROM vw.vw_products')

  return recordset ?? null
}

async function update(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(product))
    .query('EXEC sp.sp_update_product @data = @data')

  return recordset[0] ?? null
}

export default {create, products, update}