import handleError from '../../../lib/handle-error.js'
import {CustomError} from '../../../lib/custom-error.js'
import Verify from '../shared/verify.js'
import validate from '../../../lib/validate.js'
import {allOf, isNotEmpty, isExists} from '../../../lib/check/index.js'

export default function Authorization(req, res, next) {
  const {authorization} = req.headers

  try {
    validate([authorization], allOf(isExists, isNotEmpty), CustomError.BadRequest('Authorization header is required'))

    const token = authorization.replace('Bearer ', '')
    const decoded = Verify.access(token)

    req.user = decoded.id

    next()
  } catch (e) {
    handleError(e, res)
  }
}