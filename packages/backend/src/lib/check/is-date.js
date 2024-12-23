/**
 * Check if value is a Date
 * @param value
 * @returns {boolean}
 * @example
 * isDate('dd/mm/yyyy' OR 'dd-mm-yyyy') // true
 */
export default function isDate(value) {
  if (typeof value !== 'string') return false
  const format = /^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]\d{4}$/g
  return format.test(value)
}