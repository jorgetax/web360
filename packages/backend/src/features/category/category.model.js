import {pool} from '../../config/database.js'

async function create(category) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(category))
    .query('EXEC sp.sp_create_category @data = @data')

  return recordset[0] ?? null
}

async function category() {
  const database = await pool()
  const {recordset} = await database.request().query('SELECT * FROM vw.vw_categories')

  return recordset ?? null
}

async function update(category) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(category))
    .query('EXEC sp.sp_update_category @data = @data')

  return recordset[0] ?? null
}

export default {create, category, update}