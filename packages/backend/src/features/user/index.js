import handleError from '../../lib/handle-error.js'
import UserDto from './user.dto.js'
import UserService from './user.service.js'

async function create(req, res) {
  try {
    const user = UserDto.build(req)
    const result = await UserService.create(user.data)
    res.status(201).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function update(req, res) {
  try {
    const user = UserDto.user(req)
    const result = await UserService.update(user.data)
    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create, update}