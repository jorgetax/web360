import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(product) {
  const records = await database.query('EXEC sp.sp_create_product :data', {
    type: QueryTypes.INSERT,
    replacements: {data: JSON.stringify(product)},
  })
  return records[0] ?? null
}

async function products() {
  const records = await database.query('SELECT * FROM vw.vw_products')
  return records ?? null
}

async function update(product) {
  const records = await database.query('EXEC sp.sp_update_product :data', {
    type: QueryTypes.UPDATE,
    replacements: {data: JSON.stringify(product)},
  })
  return records[0] ?? null
}

export default {create, products, update}