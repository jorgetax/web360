import express from 'express'
import Product from '../features/product/index.js'

const router = express.Router()

router.post('/', Product.create)
router.get('/', Product.products)
router.patch('/:id', Product.update)

export default router