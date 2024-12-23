import {pool} from '../../config/database.js'

async function create(user) {
  console.log('user', user)
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(user))
    .query('EXEC sp.sp_create_user @data = @data')

  return recordset[0] ?? null
}

async function update(user) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(user))
    .query('EXEC sp.sp_update_user @data = @data')

  return recordset[0] ?? null
}

export default {create, update}