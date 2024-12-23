import CategoryModel from './category.service.js'
import handleError from '../../lib/handle-error.js'
import CategoryDto from './category.dto.js'

async function create(req, res) {
  try {
    const category = CategoryDto.build(req)
    const product = await CategoryModel.create(category.data)

    res.status(201).json(product)
  } catch (e) {
    handleError(e, res)
  }
}

async function category(req, res) {
  try {
    const products = await CategoryModel.category()

    res.json(products)
  } catch (e) {
    handleError(e, res)
  }
}

async function update(req, res) {
  try {
    const category = CategoryDto.category(req)
    const product = await CategoryModel.update(category.data)

    res.status(200).json(product)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create, category, update}