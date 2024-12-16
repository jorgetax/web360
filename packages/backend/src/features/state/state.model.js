import {pool} from '../../config/database.js'

async function create(state) {
  const database = await pool()
  const query = 'INSERT INTO system.states (code, label) OUTPUT INSERTED.* VALUES (@code, @label)'
  const {recordset} = await database.request()
    .input('code', state.code)
    .input('label', state.label)
    .query(query)
  return recordset[0] ?? null
}

async function states() {
  const database = await pool()
  const {recordset} = await database.request().query('SELECT * FROM system.states')

  return recordset ?? null
}

async function update(state) {
  const database = await pool()
  const query = 'UPDATE system.states SET label = COALESCE(@label, label) OUTPUT INSERTED.* WHERE state_uuid = @state_uuid'
  const {recordset} = await database.request()
    .input('label', state.label)
    .input('state_uuid', state.id)
    .query(query)
  return recordset[0] ?? null
}

export default {create, states, update}