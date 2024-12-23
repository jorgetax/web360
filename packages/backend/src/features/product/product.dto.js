import validate from '../../lib/validate.js'
import {allOf, includeKey, isExists, isNotAdditionalKey, isNotEmpty, isString, isUUID} from '../../lib/check/index.js'
import {CustomError} from '../../lib/custom-error.js'

export default class ProductDTO {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['category', 'title', 'description', 'price', 'stock', 'state']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {category, title, description, price, stock, state} = body
    validate([category, title, description, state], isNotEmpty, CustomError.BadRequest('All fields are required'))
    validate([title, description], isString, CustomError.BadRequest('Title and description must be a string'))
    validate([category, state], isUUID, CustomError.BadRequest('Category and state must be a string'))
    validate([price, stock], (value) => !isNaN(value), CustomError.BadRequest('Price and stock must be a number'))

    return new ProductDTO(body)
  }

  static product(req) {
    const {body, params} = req
    const keys = ['title', 'description', 'price', 'stock', 'state', 'category']
    const keysParams = ['id']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())
    validate([params], allOf(isExists, includeKey(keysParams), isNotAdditionalKey(keysParams)), CustomError.BadRequest())

    const {title, description, price, stock, state, category} = body
    validate([title, description, state, category], allOf(isExists, isString), CustomError.BadRequest('All fields are required'))
    validate([params.id], isString, CustomError.BadRequest())
    validate([price, stock], (value) => !isNaN(value), CustomError.BadRequest('Price and stock must be a number'))

    return new ProductDTO({...body, id: params.id})
  }
}