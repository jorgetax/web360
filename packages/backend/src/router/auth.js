import express from 'express'
import Auth from '../features/auth/index.js'

const router = express.Router()

router.post('/signin', Auth.signin)

export default router