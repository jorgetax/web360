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

async function signup(auth) {
  const salt = 10
  const hash = await bcrypt.hash(auth.password, salt)
  const result = await AuthModel.signup({...auth, password: {hash, salt}})

  if (!result) throw CustomError.BadRequest()

  return result
}

export default {signin, signup}