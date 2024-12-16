export default function IsEmpty(value) {
  return value === undefined || value === null || value === '' || value.length === 0
}