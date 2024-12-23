import {pool} from '../../config/database.js'

async function signin(data) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('data', JSON.stringify(data))
    .query('EXEC sp.sp_sign_in @data=@data')
  return recordset[0] ?? null
}

export default {signin}