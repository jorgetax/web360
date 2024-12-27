export default function Button({children, ...props}) {
  return <button {...props} className="button">{children}</button>
}