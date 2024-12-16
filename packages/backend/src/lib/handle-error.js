import {RequestError} from 'mssql/lib/base/index.js'
import {CustomError} from './custom-error.js'

const mssqlErrorCodes = {
  8114: 'Error converting data type',
  2627: 'Conflict',
  547: 'Foreign key constraint violation',
  515: 'Empty field',
  50000: 'Malformed request',
}

export default function handleError(e, res) {
  const {code, message, number} = e
  console.log('×   Error: %s - %s - %s', code, number, message)

  if (e instanceof RequestError) {
    return res.status(400).json({status: 400, message: mssqlErrorCodes[number] || message})
  }

  if (e instanceof CustomError) {
    return res.status(e.status).json({status: e.status, message: e.message})
  }

  res.status(500).json({status: 500, message: 'Internal server error'})
}