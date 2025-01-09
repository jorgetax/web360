import handleError from '../../../lib/handle-error.js'
import {CustomError} from '../../../lib/custom-error.js'
import Verify from '../shared/verify.js'
import validate from '../../../lib/validate.js'
import {allOf, isNotEmpty, isExists} from '../../../lib/check/index.js'

export default function Role(req, res, next) {
  const {user} = req

  try {
    validate([user], allOf(isExists, isNotEmpty), CustomError.Unauthorized)

    req.user = {id: decoded.id}

    next()
  } catch (e) {
    handleError(e, res)
  }
}