'use server'
import fetched from '../../lib/fetched'
import {BACKEND_URL} from '../../config/constant'

export async function signin(form) {
  return fetched(new URL('/auth/signin', BACKEND_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}