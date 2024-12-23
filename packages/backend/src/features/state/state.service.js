import StateModel from './state.model.js'
import {CustomError} from '../../lib/custom-error.js'

async function create(state) {
  const result = await StateModel.create(state)
  return result
}

async function states() {
  const result = await StateModel.states()

  if (!result) throw CustomError.NotFound()

  return result
}

async function update(state) {
  const result = await StateModel.update(state)
  return result
}

export default {create, states, update}