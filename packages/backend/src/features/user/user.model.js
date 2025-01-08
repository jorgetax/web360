import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(user) {
  const records = await database.query('EXEC sp.sp_create_user :data', {
    type: QueryTypes.INSERT,
    replacements: {data: JSON.stringify(user)}
  })
  return records[0] ?? null
}

async function find(user) {
  const records = await database.query('EXEC sp.sp_find_user :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(user)}
  })
  return records[0] ?? null
}

async function update(user) {
  const records = await database.query('EXEC sp.sp_update_user :data', {
    type: QueryTypes.UPDATE,
    replacements: {data: JSON.stringify(user)}
  })
  return records[0] ?? null
}

export default {create, find, update}