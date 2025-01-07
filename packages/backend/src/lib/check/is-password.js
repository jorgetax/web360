/**
 * Check if the value is a valid password
 * @param value
 * @returns {boolean}
 * @example
 * isPassword('password123') // true
 */
export default function isPassword(value) {
  if (value.length < 8 || value.length > 128) return false
  const regex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$/ // example: Password123
  return regex.test(value)
}