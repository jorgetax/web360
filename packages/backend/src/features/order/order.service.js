import OrderModel from './order.model.js'

async function create(order) {
  return await OrderModel.create(order)
}

async function orders() {
  return await OrderModel.orders()
}

async function update(product) {
  return await OrderModel.update(product)
}

export default {create, orders, update}