import AuthService from './auth.service.js'
import handleError from '../../lib/handle-error.js'
import AuthDto from './auth.dto.js'

async function signin(req, res) {
  try {
    const auth = AuthDto.build(req)
    const result = await AuthService.signin(auth.data)
    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function signup(req, res) {
  try {
    const auth = AuthDto.user(req)
    const result = await AuthService.signup(auth.data)
    res.status(201).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {signin, signup}