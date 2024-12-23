import validate from '../../lib/validate.js'
import {allOf, includeKey, isExists, isNotAdditionalKey, isNotEmpty, isString, isUUID} from '../../lib/check/index.js'
import {CustomError} from '../../lib/custom-error.js'

export default class OrderDto {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['user', 'state', 'items']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {user, state} = body
    validate([user, state], isNotEmpty, CustomError.BadRequest('All fields are required'))
    validate([user, state], isUUID, CustomError.BadRequest('User must be a string'))

    return new OrderDto(body)
  }

  static order(req) {
    const {body, params} = req
    const keys = ['state', 'items']
    const keysParams = ['id']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())
    validate([params], allOf(isExists, includeKey(keysParams), isNotAdditionalKey(keysParams)), CustomError.BadRequest())

    const {state} = body
    const {id} = params
    validate([state], isNotEmpty, CustomError.BadRequest('All fields are required'))
    validate([id], isString, CustomError.BadRequest())

    return new OrderDto({...body, id})
  }
}