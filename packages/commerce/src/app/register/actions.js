import fetched from '../../lib/fetched'

const BASE_URL = 'http://localhost:5000'

export async function signup(form) {
  return fetched(new URL('/auth/signup', BASE_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}

export async function organization(form) {
  return fetched(new URL('/organization', BASE_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}