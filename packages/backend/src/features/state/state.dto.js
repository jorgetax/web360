import {CustomError} from '../../lib/custom-error.js'
import {EveryObject, IsEmpty, TestUUID} from '../../lib/check/index.js'

export default class StateDTO {

  constructor(id, code, label) {
    this.id = id
    this.code = code
    this.label = label
  }

  static build(req) {
    const {body} = req
    const columns = ['code', 'label']
    const {code, label} = body

    if (!EveryObject(body, columns) || IsEmpty(code) || IsEmpty(label)) throw CustomError.BadRequest()

    return new StateDTO(null, code, label)
  }

  static state(req) {
    const {body, params} = req
    const {id} = params

    if (!TestUUID(id)) throw CustomError.BadRequest()

    const columns = ['label']
    const {code, label} = body

    console.log(!IsEmpty(label))
    if (!EveryObject(body, columns) || IsEmpty(label)) throw CustomError.BadRequest()

    return new StateDTO(id, code, label)
  }
}