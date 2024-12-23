import express from 'express'
import Category from '../features/category/index.js'
import Authorization from '../features/auth/middleware/authorization.js'

const router = express.Router()

router.use(Authorization)

router.post('/', Category.create)
router.get('/', Category.category)
router.patch('/:id', Category.update)

export default router