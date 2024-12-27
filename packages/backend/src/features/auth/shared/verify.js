import jwt from 'jsonwebtoken'
import {JWT_SECRET} from '../../../config/constant.js'

function access(hash) {
  return jwt.verify(hash, JWT_SECRET)
}

export default {access}