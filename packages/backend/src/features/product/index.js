import ProductService from './product.service.js'
import handleError from '../../lib/handle-error.js'
import ProductDTO from './product.dto.js'

async function create(req, res) {
  try {
    const product = ProductDTO.build(req)
    const result = await ProductService.create(product)

    res.status(201).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function products(req, res) {
  try {
    const products = await ProductService.products()

    res.status(200).json(products)
  } catch (e) {
    handleError(e, res)
  }
}

async function update(req, res) {
  try {
    const product = ProductDTO.product(req)
    const result = await ProductService.update(product)

    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create, products, update}