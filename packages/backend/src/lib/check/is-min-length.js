export default function isMinLength(min) {
  return function (value) {
    return value.length >= min
  }
}