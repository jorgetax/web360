import database from '../../config/database.js'
import {QueryTypes} from "sequelize"

async function signin(data) {
  const records = await database.query('EXEC sp.sp_sign_in :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(data)}
  })
  return records[0] ?? null
}

async function signup(data) {
  const records = await database.query('EXEC sp.sp_create_user :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify({...data, role: 'customer'})}
  })
  return records[0] ?? null
}

export default {signin, signup}