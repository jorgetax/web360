import express from 'express'
import Auth from '../features/auth/index.js'

const router = express.Router()

router.post('/signin', Auth.signin)
router.post('/signup', Auth.signup)

export default router