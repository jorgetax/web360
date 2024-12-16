import StateModel from './state.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function create(product) {
  return await StateModel.create(product)
}

async function states() {
  const result = await StateModel.states()

  if (!result) throw CustomError.NotFound()

  return {data: result}
}

async function update(product) {
  return await StateModel.update(product)
}

export default {create, states, update}