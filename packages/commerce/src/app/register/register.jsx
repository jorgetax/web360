import {Outlet, useNavigate} from 'react-router-dom'
import RegisterContextProvider from '../../context/register-context-provider'
import {useEffect} from "react";

export default function Register({steps}) {
  const navigate = useNavigate()

  useEffect(() => {
    if (steps > 2) {
      navigate('/register/organization')
    } else {
      navigate('/signup/user')
    }
  }, [steps])

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