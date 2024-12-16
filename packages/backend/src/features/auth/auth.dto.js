import {CustomError} from '../../lib/custom-error.js'
import {EveryObject, IsEmpty, TestUUID} from '../../lib/check/index.js'

export default class AuthDto {

  constructor(email, password) {
    this.email = email
    this.password = password
  }

  static build(req) {
    const {body} = req
    const columns = ['email', 'password']
    const {email, password} = body

    if (!EveryObject(body, columns) || IsEmpty(email) || IsEmpty(password)) {
      throw CustomError.BadRequest()
    }

    return new AuthDto(email, password)
  }
}