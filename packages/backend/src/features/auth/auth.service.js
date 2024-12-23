import AuthModel from './auth.model.js'
import {CustomError} from '../../lib/custom-error.js'
import bcrypt from 'bcrypt'
import Sign from './shared/sign.js'

async function signin(auth) {
  const result = await AuthModel.signin({email: auth.email})
  if (!result) throw CustomError.BadRequest()

  const compare = await bcrypt.compare(auth.password, result.hash)
  if (!compare) throw CustomError.BadRequest()

  const access_token = Sign.access({id: result.id})
  return {access_token}
}

export default {signin}