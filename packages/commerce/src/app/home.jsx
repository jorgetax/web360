import {useAuthContext} from '../context/auth-context-provider'

export default function Home() {
  const {isAuthenticated} = useAuthContext()
  return (
    <div>
      <h1>Home</h1>
      {isAuthenticated ? (<p>Welcome to the home page</p>) : (<p>Please login to access the home page</p>)}
    </div>
  )
}