/**
 * Check if the data has additional keys
 * @param keys
 * @returns {function(*): boolean} - Returns true if the data has no additional keys
 * @example
 * const keys = ['email', 'password']
 * const data = {email: 'local@example.com', password: 'password'}
 * const isNotAdditionalKey = isNotAdditionalKey(keys)(data)
 */
export default function isNotAdditionalKey(keys) {
  return function (data) {
    const labels = Object.keys(data)
    const additional = labels.filter(key => !keys.includes(key))
    return additional.length === 0
  }
}