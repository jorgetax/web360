import express from 'express'
import Sate from '../features/state/index.js'

const router = express.Router()

router.post('/', Sate.create)
router.get('/', Sate.states)
router.patch('/:id', Sate.update)

export default router