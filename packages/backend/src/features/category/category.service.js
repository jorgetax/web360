import CategoryModel from './category.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function create(category) {
  const result = await CategoryModel.create(category)

  if (!result) throw CustomError.BadRequest()

  return result
}

async function category() {
  const result = await CategoryModel.category()

  if (!result) throw CustomError.NotFound()

  return {data: result}
}

async function update(category) {
  const result = await CategoryModel.update(category)

  if (!result) throw CustomError.BadRequest()

  return result
}

export default {create, category, update}