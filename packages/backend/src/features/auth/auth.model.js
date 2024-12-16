import {pool} from '../../config/database.js'

async function signin(auth) {
  const database = await pool()
  const query = 'EXEC sp.signin @email=@email, @password=@password'
  const {recordset} = await database.request()
    .input('email', auth.email)
    .input('password', auth.password)
    .query(query)
  return recordset[0] ?? null
}

export default {signin}