import '../styles.css'
import Navbar from './navbar'
import {useLocation} from 'react-router-dom'

export default function Layout({children}) {
  const pathname = useLocation().pathname

  const publicPages = ['/signin', '/signup']

  if (publicPages.includes(pathname)) {
    return <main>{children}</main>
  }

  return (
    <div className="layout">
      <div>
        <span>🚀</span>
      </div>
      <div>
        {children}
      </div>
    </div>
  )
}