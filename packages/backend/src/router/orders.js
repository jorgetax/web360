import express from 'express'
import Authorization from '../features/auth/middleware/authorization.js'
import Order from '../features/order/index.js'

const router = express.Router()

router.use(Authorization)

router.post('/', Order.create)
router.get('/', Order.orders)
router.patch('/:id', Order.update)

export default router