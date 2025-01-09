import Sidebar from './sidebar'
import {Navigate, Outlet} from "react-router-dom"
import {useAuthContext} from "../../context/auth-context-provider";

export default function DashboardLayout() {
  const {profile, loading} = useAuthContext()
  const {roles, organization} = profile

  if (loading) return <div>Loading...</div>

  if (roles && roles.some(role => role.code === 'customer')) {
    return <Navigate to="/store"/>
  }

  if (!organization) {
    return <Navigate to="/"/>
  }

  return (
    <div className="layout">
      <Sidebar/>
      <Outlet/>
    </div>
  )
}