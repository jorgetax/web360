import '../styles.css'
import AuthContextProvider from '../../context/auth-context-provider'
import {Outlet} from "react-router-dom";

export default function RouteWithProvider() {
  return (
    <AuthContextProvider>
      <Outlet/>
    </AuthContextProvider>
  )
}