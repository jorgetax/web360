import jwt from 'jsonwebtoken'

const JWT_SECRET = 'secret'

function access(hash) {
  return jwt.verify(hash, JWT_SECRET)
}

export default {access}