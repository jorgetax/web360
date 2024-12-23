/**
 * Check if object has all keys
 * @param { string[] } args - keys that should be
 * @returns {function} - function that check if object has all keys
 * @example includeKey('email', 'password')({email: 'test', password: 'test'}) // true
 */

export default function includeKey(args) {
  return function (obj) {
    for (const arg of args) {
      if (!obj.hasOwnProperty(arg)) return false
    }
    return true
  }
}