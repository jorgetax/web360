import '../styles.css'
import {Outlet} from 'react-router-dom'
import AuthContextProvider from '../../context/auth-context-provider'

export default function Layout() {
  return (
    <AuthContextProvider>
      <Outlet/>
    </AuthContextProvider>
  )
}