/**
 * Check if value is a Date
 * @param value
 * @returns {boolean}
 * @example
 * isDate('dd/mm/yyyy' OR 'dd-mm-yyyy') // true
 */
export default function isDate(value) {
  if (typeof value !== 'string') return false
  // yyyy-mm-dd
  const format = /^\d{4}-\d{2}-\d{2}$/
  return format.test(value)
}