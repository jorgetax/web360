import AuthService from './auth.service.js'
import handleError from '../../lib/handle-error.js'
import AuthDto from './auth.dto.js'

async function signin(req, res) {
  try {
    const auth = AuthDto.build(req)
    const result = await AuthService.signin(auth)
    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {signin}