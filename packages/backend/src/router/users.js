import express from 'express'
import User from '../features/user/index.js'
import Authorization from '../features/auth/middleware/authorization.js'

const router = express.Router()

router.use(Authorization)

router.post('/', User.create)
router.patch('/:id', User.update)

export default router