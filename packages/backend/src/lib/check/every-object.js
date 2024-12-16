export default function everyObject(body, columns) {
  return Object.keys(body).every(key => columns.includes(key))
}