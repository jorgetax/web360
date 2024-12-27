import '../styles.css'
import {useLocation} from 'react-router-dom'
import Sidebar from './sidebar'
import {useAuthContext} from '../../context/auth-context-provider'

export default function Layout({children}) {
  const {isAuthenticated} = useAuthContext()
  const pathname = useLocation().pathname
  const publicPages = ['/signin', '/signup']

  if (publicPages.includes(pathname) || !isAuthenticated) {
    return <main>{children}</main>
  }

  return (
    <div className="layout">
      <Sidebar/>
      {children}
    </div>
  )
}