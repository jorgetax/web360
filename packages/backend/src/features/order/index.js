import OrderService from './order.service.js'
import handleError from '../../lib/handle-error.js'
import OrderDto from './order.dto.js'

async function create(req, res) {
  try {
    const order = OrderDto.build(req)
    const result = await OrderService.create(order.data)

    res.status(201).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function orders(req, res) {
  try {
    const result = await OrderService.orders()

    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function update(req, res) {
  try {
    const order = OrderDto.order(req)
    const result = await OrderService.update(order.data)

    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create, orders, update}