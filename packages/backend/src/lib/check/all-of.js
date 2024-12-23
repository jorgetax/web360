export default function allOf(...args) {
  return (value) => args.every((fn) => fn(value))
}