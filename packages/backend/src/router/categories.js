import express from 'express'
import Category from '../features/category/index.js'

const router = express.Router()

router.post('/', Category.create)
router.get('/', Category.category)
router.patch('/:id', Category.update)

export default router