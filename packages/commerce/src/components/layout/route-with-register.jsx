import {Navigate, Outlet} from "react-router-dom";
import RegisterContextProvider from "../../context/register-context-provider";
import {useAuthContext} from "../../context/auth-context-provider";

export default function RouteWithRegister() {

  const {isAuthenticated} = useAuthContext()

  if (isAuthenticated) return <Navigate to={'/dashboard'}/>

  return (
    <RegisterContextProvider>
      <div className="page">
        <main className="main">
          <Outlet/>
        </main>
      </div>
    </RegisterContextProvider>
  )
}