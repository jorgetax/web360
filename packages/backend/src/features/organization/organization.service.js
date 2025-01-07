import OrganizationModel from './organization.model.js'
import bcrypt from 'bcrypt'
import {CustomError} from '../../lib/custom-error.js'

async function create(organization) {
  const salt = 10
  const hash = await bcrypt.hash(organization.password, salt)
  const result = await OrganizationModel.create({...organization, password: {hash, salt}})

  if (!result) throw CustomError.BadRequest()

  return result
}

export default {create}