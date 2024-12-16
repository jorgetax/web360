import {CustomError} from '../../lib/custom-error.js'
import {EveryObject, IsEmpty, TestUUID} from '../../lib/check/index.js'

export default class CategoryDto {

  constructor(id, code, label, state) {
    this.id = id
    this.code = code
    this.label = label
    this.state = state
  }

  static build(req) {
    const {body} = req
    const columns = ['code', 'label', 'state']
    const {code, label, state} = body

    if (!EveryObject(body, columns) || IsEmpty(code) || IsEmpty(label) || IsEmpty(state)) {
      throw CustomError.BadRequest('Missing required fields')
    }

    if (!TestUUID(state)) throw CustomError.BadRequest('Invalid state')

    return new CategoryDto(null, code, label, state)
  }

  static category(req) {
    const {body, params} = req
    const {id} = params

    if (!TestUUID(id)) throw CustomError.BadRequest()

    const columns = ['label', 'state']
    const {code, label, state} = body

    if (!EveryObject(body, columns) || IsEmpty(label) || IsEmpty(state)) {
      throw CustomError.BadRequest('Missing required fields')
    }

    if (!TestUUID(state)) throw CustomError.BadRequest('Invalid state')

    return new CategoryDto(id, code, label)
  }
}