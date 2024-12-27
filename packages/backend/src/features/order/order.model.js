import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(product) {
  const records = await database.query('EXEC sp.sp_create_order :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(product)}
  })
  return records[0] ?? null
}

async function orders() {
  const records = await database.query('SELECT * FROM vw.vw_orders')
  return records ?? null
}

async function update(product) {
  const records = await database.query('EXEC sp.sp_update_order :data', {
    type: QueryTypes.SELECT,
    replacements: {data: JSON.stringify(product)}
  })
  return records[0] ?? null
}

export default {create, orders, update}