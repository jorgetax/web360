import {useAuthContext} from '../context/auth-context-provider'
import {Navigate} from "react-router-dom";

export default function Logout() {
  const {logout, isAuthenticated} = useAuthContext()

  if (isAuthenticated) {
    logout()
    return <Navigate to={'/dashboard'}/>
  }
}