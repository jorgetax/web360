/**
 * Validate values
 * @param values
 * @param check
 * @param error
 * @returns {void}
 * @throws {error}
 * @example
 * validate([1, 2, 3], (value) => value > 0, Error)
 */

export default function validate(values, check, error) {
  for (const value of values) {
    if (!check(value)) throw error
  }
}