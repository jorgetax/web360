import {pool} from '../../config/database.js'

async function create(state) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(state))
    .query('EXEC sp.sp_create_state @data = @data')
  return recordset[0] ?? null
}

async function states() {
  const database = await pool()
  const {recordset} = await database.request().query('SELECT * FROM vw.vw_states')
  return recordset ?? null
}

async function update(state) {
  console.log(state)
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(state))
    .query('EXEC sp.sp_update_state @data = @data')
  return recordset[0] ?? null
}

export default {create, states, update}