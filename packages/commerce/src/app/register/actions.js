import fetched from '../../lib/fetched'
import {BACKEND_URL} from "../../config/constant";

export async function signup(form) {
  return fetched(new URL('/auth/signup', BACKEND_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}

export async function organization(form) {
  return fetched(new URL('/api/organization', BACKEND_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}