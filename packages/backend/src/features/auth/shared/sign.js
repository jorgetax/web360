import jwt from 'jsonwebtoken'

const JWT_SECRET = 'secret'

function access(payload) {
  const expiresIn = 60 * 60 * 24 // 24 hours
  return jwt.sign(payload, JWT_SECRET, {expiresIn})
}

export default {access}