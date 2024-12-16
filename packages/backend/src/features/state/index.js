import StateService from './state.service.js'
import handleError from '../../lib/handle-error.js'
import StateDTO from "./state.dto.js";

async function create(req, res) {
  try {
    const state = StateDTO.build(req)
    const product = await StateService.create(state)
    res.status(201).json(product)
  } catch (e) {
    handleError(e, res)
  }
}

async function states(req, res) {
  try {
    const products = await StateService.states()
    res.json(products)
  } catch (e) {
    handleError(e, res)
  }
}

async function update(req, res) {
  try {
    const state = StateDTO.state(req)
    const product = await StateService.update(state)
    res.json(product)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create, states, update}