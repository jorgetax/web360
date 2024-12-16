import {pool} from '../../config/database.js'

async function create(category) {
  const database = await pool()
  const query = 'INSERT INTO products.categories (code, label, state_uuid) OUTPUT INSERTED.* VALUES (@code, @label, @state_uuid)'
  const {recordset} = await database.request()
    .input('code', category.code)
    .input('label', category.label)
    .input('state_uuid', category.state)
    .query(query)

  return recordset[0] ?? null
}

async function category() {
  const database = await pool()
  const query = 'SELECT * FROM products.vw_categories'
  const {recordset} = await database.request().query(query)

  return recordset ?? null
}

async function update(category) {
  const database = await pool()
  const query = 'UPDATE products.categories SET label = @label OUTPUT INSERTED.* WHERE category_uuid = @category_uuid'
  const {recordset} = await database.request()
    .input('category_uuid', category.id)
    .input('label', category.label)
    .input('state_uuid', category.state)
    .query(query)

  return recordset[0] ?? null
}

export default {create, category, update}