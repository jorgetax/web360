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
    <>
      <Navbar/>
      <main>
        {children}
      </main>
    </>
  )
}