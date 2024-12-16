import CategoryModel from './category.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function create(category) {
  return await CategoryModel.create(category)
}

async function category() {
  const result = await CategoryModel.category()

  if (!result) throw CustomError.NotFound()

  return {data: result}
}

async function update(category) {
  return await CategoryModel.update(category)
}

export default {create, category, update}