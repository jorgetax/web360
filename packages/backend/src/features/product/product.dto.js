import {CustomError} from '../../lib/custom-error.js'
import {EveryObject, IsEmpty, TestUUID} from '../../lib/check/index.js'

export default class ProductDTO {

  constructor(id, category, title, description, price, stock, state) {
    this.id = id
    this.category = category
    this.title = title
    this.description = description
    this.price = price
    this.stock = stock
    this.state = state
  }

  static build(req) {
    const {body} = req
    const columns = ['category', 'title', 'description', 'price', 'stock', 'state']
    const {category, title, description, price, stock, state} = body

    if (!TestUUID(category)) throw CustomError.BadRequest()

    if (!EveryObject(body, columns) || IsEmpty(category) || IsEmpty(title) || IsEmpty(description) || IsEmpty(price) || IsEmpty(stock) || IsEmpty(state)) {
      throw CustomError.BadRequest()
    }

    if (!TestUUID(state)) throw CustomError.BadRequest('Category is not valid')

    return new ProductDTO(null, category, title, description, price, stock, state)
  }

  static product(req) {
    const {body, params} = req
    const {id} = params

    if (!TestUUID(id)) throw CustomError.BadRequest()

    const columns = ['category', 'title', 'description', 'price', 'stock', 'state']
    const {category, title, description, price, stock, state} = body

    if (!TestUUID(category)) throw CustomError.BadRequest('Category is not valid')
    if (!EveryObject(body, columns) || IsEmpty(category) || IsEmpty(title) || IsEmpty(description) || IsEmpty(price) || IsEmpty(stock) || IsEmpty(state)) {
      throw CustomError.BadRequest()
    }

    if (!TestUUID(state)) throw CustomError.BadRequest('Category is not valid')

    return new ProductDTO(id, category, title, description, price, stock, state)
  }
}