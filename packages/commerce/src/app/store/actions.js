import fetched from "../../lib/fetched";
import {BACKEND_URL} from "../../config/constant";

export async function allProducts(token) {
  return fetched(new URL('/products', BACKEND_URL), {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  })
}