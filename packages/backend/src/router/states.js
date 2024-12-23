import express from 'express'
import Sate from '../features/state/index.js'
import Authorization from '../features/auth/middleware/authorization.js'

const router = express.Router()

router.use(Authorization)

router.post('/', Sate.create)
router.get('/', Sate.states)
router.patch('/:id', Sate.update)

export default router