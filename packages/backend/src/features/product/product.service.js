import ProductModel from './product.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function create(product) {
  return await ProductModel.create(product)
}

async function products() {
  const result = await ProductModel.products()

  if (!result) throw CustomError.NotFound()

  return {data: result}
}

async function update(product) {
  return await ProductModel.update(product)
}

export default {create, products, update}