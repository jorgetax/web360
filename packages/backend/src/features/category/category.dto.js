import {CustomError} from '../../lib/custom-error.js'
import {allOf, includeKey, isExists, isNotAdditionalKey, isNotEmpty, isString, isUUID} from '../../lib/check/index.js'
import validate from '../../lib/validate.js'

export default class CategoryDto {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['code', 'label', 'state']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {code, label, state} = body
    validate([code, label, state], allOf(isNotEmpty, isString), CustomError.BadRequest())
    validate([state], isUUID, CustomError.BadRequest())

    return new CategoryDto(body)
  }

  static category(req) {
    const {body, params} = req
    const keys = ['label', 'state']
    const keysParams = ['id']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest)
    validate([params], allOf(isExists, includeKey(keysParams)), CustomError.BadRequest)

    const {label} = body
    const {id} = params
    validate([label, id], allOf(isNotEmpty, isString), CustomError.BadRequest)
    validate([id], isUUID, CustomError.BadRequest)

    return new CategoryDto({...body, id: params.id})
  }
}