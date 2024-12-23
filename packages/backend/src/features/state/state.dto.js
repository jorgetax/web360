import {CustomError} from '../../lib/custom-error.js'
import {allOf, includeKey, isExists, isNotAdditionalKey, isNotEmpty, isString, isUUID} from '../../lib/check/index.js'
import validate from '../../lib/validate.js'

export default class StateDTO {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['code', 'label']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {code, label} = body
    validate([code, label], allOf(isNotEmpty, isString), CustomError.BadRequest())

    return new StateDTO(body)
  }

  static state(req) {
    const {body, params} = req
    const keys = ['label']
    const keysParams = ['id']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())
    validate([params], allOf(isExists, includeKey(keysParams), isNotAdditionalKey(keysParams)), CustomError.BadRequest())
    validate([params.id], isUUID, CustomError.BadRequest())
    validate([body.label], allOf(isNotEmpty, isString), CustomError.BadRequest())

    return new StateDTO({...body, id: params.id})
  }
}