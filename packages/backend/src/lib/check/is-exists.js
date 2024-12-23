/**
 * Check if value exists
 * @param value
 * @returns {boolean}
 * @example
 * isExists('') // true
 */
export default function isExists(value) {
  return value !== undefined && value !== null
}