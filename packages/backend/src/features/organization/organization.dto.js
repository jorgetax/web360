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

export default class OrganizationDto {

  constructor(data) {
    this.data = data
  }

  static build(req) {
    const {body} = req
    const keys = ['name', 'description', 'first_name', 'last_name', 'email', 'password', 'birth_date']

    validate([body], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {name, description, first_name, last_name, email, password, birth_date} = body
    validate([name, description, first_name, last_name], allOf(isNotEmpty, isString), CustomError.BadRequest())
    validate([email], allOf(isNotEmpty, isEmail), CustomError.BadRequest())
    validate([password], allOf(isNotEmpty, isPassword), CustomError.BadRequest('Password must be at least 8 characters long'))
    validate([birth_date], allOf(isNotEmpty, isDate), CustomError.BadRequest('Birth date must be in the format YYYY-MM-DD'))

    return new OrganizationDto({
      name, description,
      user: {first_name, last_name, email, birth_date},
      password
    })
  }

  static organization(req) {
    const {params} = req
    const keys = ['id']

    validate([params], allOf(isExists, includeKey(keys), isNotAdditionalKey(keys)), CustomError.BadRequest())

    const {id} = params
    validate([id], allOf(isNotEmpty, isUUID), CustomError.BadRequest())

    return new OrganizationDto
  }
}