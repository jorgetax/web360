import {useAuthContext} from '../../context/auth-context-provider'
import Sidebar from '../../components/layout/sidebar'
import {Navigate, Outlet} from "react-router-dom";

export default function Dashboard() {
  const {loading, isAuthenticated} = useAuthContext()

  if (!isAuthenticated) {
    return <Navigate to={'/signin'}/>
  } else if (loading) {
    return <p>Loading...</p>
  }

  return (
    <div>
      <Sidebar/>
      <div>
        <Outlet/>
      </div>
    </div>
  )
}