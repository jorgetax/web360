import fetched from '../../lib/fetched'

const BASE_URL = 'http://localhost:5000'

export async function signin(form) {
  return fetched(new URL('/auth/signin', BASE_URL), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(form),
  })
}