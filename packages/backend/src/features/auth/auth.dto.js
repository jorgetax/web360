import {CustomError} from '../../lib/custom-error.js'
import {allOf, includeKey, isEmail, isExists, isNotAdditionalKey, isNotEmpty} from '../../lib/check/index.js'
import validate from '../../lib/validate.js'

export default class AuthDto {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['email', 'password']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {email, password} = body
    validate([email, password], allOf(isNotEmpty), CustomError.BadRequest())
    validate([body.email], isEmail, CustomError.BadRequest())

    return new AuthDto(body)
  }
}