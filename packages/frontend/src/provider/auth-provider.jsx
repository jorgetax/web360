import React, {useState, useContext, useReducer} from 'react'

const authContext = React.createContext()

export function useAuthContext() {
  return useContext(authContext)
}

export default function AuthProvider({children}) {
  const [user, setUser] = useState(null)

  return (
    <authContext.Provider value={{user, setUser}}>
      {children}
    </authContext.Provider>
  )
}