import database from '../../config/database.js'
import {QueryTypes} from 'sequelize'

async function create(state) {
  const records = await database.query('EXEC sp.sp_create_state :data', {
    type: QueryTypes.INSERT,
    replacements: {data: JSON.stringify(state)},
  })
  return records[0] ?? null
}

async function states() {
  const records = await database.query('SELECT * FROM vw.vw_states')
  return records ?? null
}

async function update(state) {
  const records = await database.query('EXEC sp.sp_update_state :data', {
    type: QueryTypes.UPDATE,
    replacements: {data: JSON.stringify(state)},
  })
  return records[0] ?? null
}

export default {create, states, update}