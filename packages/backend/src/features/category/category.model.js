import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(category) {
  const records = await database.query('EXEC sp.sp_create_category :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(category)}
  })

  return records[0] ?? null
}

async function category() {
  const records = await database.query('SELECT * FROM vw.vw_categories')
  return records ?? null
}

async function update(category) {
  const records = await database.query('EXEC sp.sp_update_category :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(category)}
  })
  return records[0] ?? null
}

export default {create, category, update}