import React, {useState, useContext, useCallback, useMemo} from 'react'

const AuthContext = React.createContext({
  login: (tokens) => {
  },
  logout: () => {
  },
  isAuthenticated: false,
  tokens: null,
})

export function useAuthContext() {
  return useContext(AuthContext)
}

export default function AuthContextProvider({children}) {
  const [tokens, setTokens] = useState(null)

  const login = useCallback(function (tokens) {
    setTokens(tokens)
  }, [])

  const logout = useCallback(function () {
    setTokens(null)
  }, [])

  const value = useMemo(
    () => ({
      login,
      logout,
      isAuthenticated: !!tokens,
      tokens,
    }),
    [login, logout, tokens]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}