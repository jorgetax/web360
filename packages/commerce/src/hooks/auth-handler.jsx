import {Navigate, Outlet} from 'react-router-dom'
import {useAuthContext} from '../context/auth-context-provider'

export default function AuthHandler() {
  const {isAuthenticated} = useAuthContext()

  if (!isAuthenticated) return <Navigate to="/"/>

  return <Outlet/>
}