import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(organization) {
  const records = await database.query('EXEC sp.sp_create_organization :data', {
    type: QueryTypes.INSERT,
    replacements: {data: JSON.stringify([organization])}
  })
  return records[0] ?? null
}

export default {create}