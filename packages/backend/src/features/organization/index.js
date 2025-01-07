import handleError from '../../lib/handle-error.js'
import OrganizationDto from './organization.dto.js'
import OrganizationService from './organization.service.js'

async function create(req, res) {
  try {
    const user = OrganizationDto.build(req)
    const result = await OrganizationService.create(user.data)
    res.status(201).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

async function find(req, res) {
  try {
    const organization = OrganizationDto.build(req)
    const result = await OrganizationService.find(organization)
    res.status(200).json(result)
  } catch (e) {
    handleError(e, res)
  }
}

export default {create}