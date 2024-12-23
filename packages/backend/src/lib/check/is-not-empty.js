export default function isNotEmpty(value) {
  return value !== null && value !== undefined && value !== '' && value.length > 0
}