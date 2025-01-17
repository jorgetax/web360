import express from 'express'
import Product from '../features/product/index.js'
import Authorization from '../features/auth/middleware/authorization.js'

const router = express.Router()

router.use(Authorization)

router.post('/', Product.create)
router.get('/', Product.products)
router.patch('/:id', Product.update)

export default router