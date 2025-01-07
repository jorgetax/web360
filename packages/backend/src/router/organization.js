import express from 'express'
import Organization from '../features/organization/index.js'


const router = express.Router()

router.post('/', Organization.create)

export default router