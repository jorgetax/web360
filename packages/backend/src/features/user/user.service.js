import UserModel from './user.model.js'
import bcrypt from 'bcrypt'
import {CustomError} from '../../lib/custom-error.js'

async function create(user) {
  const salt = 10
  const hash = await bcrypt.hash(user.password, salt)
  const result = await UserModel.create({...user, password: {hash, salt}})

  if (!result) throw CustomError.BadRequest()

  return result
}

async function find(user) {
  const result = await UserModel.find(user)

  if (!result) throw CustomError.NotFound()

  return result
}

async function update(user) {
  const result = await UserModel.update(user)

  if (!result) throw CustomError.BadRequest()

  return result
}

export default {create, find, update}