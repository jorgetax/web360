import {RequestError} from 'mssql/lib/base/index.js'
import {CustomError} from './custom-error.js'

const mssqlErrorCodes = {
  8114: 'Error converting data type',
  2627: 'Conflict',
  547: 'Foreign key constraint violation',
  515: 'Empty field',
  50000: 'Malformed request',
}

export default function handleError(e, res, next) {
  const {code, message, number} = e

  if (next) {
    return next()
  }

  if (e instanceof CustomError) {
    console.log('×   CustomError: %s - %s', e.status, e.message)
    return res.status(e.status).json({status: e.status, message: e.message})
  }

  if (e instanceof RequestError) {
    console.log('×   RequestError: %s - %s - %s', code, number || 'N/A', message)
    return res.status(400).json({status: 400, message: mssqlErrorCodes[number] || message})
  }

  console.log('×   Error: %s - %s - %s', code, number, message)
  res.status(500).json({status: 500, message: 'Internal server error'})
}