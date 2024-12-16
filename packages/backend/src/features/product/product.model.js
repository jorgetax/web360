import {pool} from '../../config/database.js'

async function create(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('category_uuid', product.category)
    .input('title', product.title)
    .input('description', product.description)
    .input('price', product.price)
    .input('stock', product.stock)
    .input('state_uuid', product.state)
    .query('EXEC products.sp_create_product @category_uuid = @category_uuid, @title = @title, @description = @description, @price = @price, @stock = @stock , @state_uuid = @state_uuid')

  return recordset[0] ?? null
}

async function products() {
  const database = await pool()
  const {recordset} = await database.request().query('SELECT * FROM products.vw_products')

  return recordset ?? null
}

async function update(product) {
  const database = await pool()
  const {recordset} = await database.request()
    .input('product_uuid', product.id)
    .input('title', product.title)
    .input('description', product.description)
    .input('price', product.price)
    .input('stock', product.stock)
    .input('state_uuid', product.state)
    .input('category_uuid', product.category)
    .query('EXEC products.sp_update_product @product_uuid = @product_uuid, @title = @title, @description = @description, @price = @price, @stock = @stock , @state_uuid = @state_uuid, @category_uuid = @category_uuid')

  return recordset[0] ?? null
}

export default {create, products, update}