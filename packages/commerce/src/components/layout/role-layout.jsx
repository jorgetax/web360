import {Navigate, Outlet} from "react-router-dom"
import {useAuthContext} from "../../context/auth-context-provider"

export default function RoleLayout() {
  const {isAuthenticated, profile, loading} = useAuthContext()

  console.log(JSON.stringify(profile, null, 2))

  if (loading) return <div>Loading...</div>
  if (!isAuthenticated) return <Navigate to="/signin"/>

  return <Outlet/>
}