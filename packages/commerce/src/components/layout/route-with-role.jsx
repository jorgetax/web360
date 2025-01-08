import {Navigate, Outlet} from "react-router-dom"
import {useAuthContext} from "../../context/auth-context-provider"

export default function RouteWithRole() {
  const {isAuthenticated, profile} = useAuthContext()

  if (!isAuthenticated) {
    return <Navigate to="/signin"/>
  }

  return <Outlet/>
}