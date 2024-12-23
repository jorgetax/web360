import {
  allOf,
  includeKey,
  isDate,
  isEmail,
  isExists,
  isNotAdditionalKey,
  isNotEmpty,
  isPassword,
  isString,
  isUUID
} from '../../lib/check/index.js'
import validate from '../../lib/validate.js'
import {CustomError} from '../../lib/custom-error.js'

export default class UserDto {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['first_name', 'last_name', 'email', 'password', 'birth_date', 'state']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {first_name, last_name, email, password, birth_date, state} = body
    validate([first_name, last_name, email, password, birth_date, state], allOf(isNotEmpty, isString), CustomError.BadRequest())
    validate([email], isEmail, CustomError.BadRequest())
    validate([password], isPassword, CustomError.BadRequest())
    validate([birth_date], isDate, CustomError.BadRequest())
    validate([state], isUUID, CustomError.BadRequest())

    return new UserDto(body)
  }

  static user(req) {
    const {body, params} = req
    const keys = ['first_name', 'last_name', 'birth_date']
    const keysParams = ['id']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())
    validate([params], allOf(isExists, includeKey(keysParams), isNotAdditionalKey(keysParams)), CustomError.BadRequest())

    const {first_name, last_name, birth_date} = body
    const {id} = params
    validate([id, first_name, last_name, birth_date], allOf(isNotEmpty, isString), CustomError.BadRequest())
    validate([id], isUUID, CustomError.BadRequest())
    validate([birth_date], isDate, CustomError.BadRequest())

    return new UserDto({...body, id})
  }
}