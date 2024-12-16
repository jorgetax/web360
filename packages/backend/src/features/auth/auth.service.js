import AuthModel from './auth.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function signin(auth) {
  const result = await AuthModel.signin(auth)

  if (!result) {
    throw new CustomError('Invalid email or password', 400)
  }

  return result
}

export default {signin}