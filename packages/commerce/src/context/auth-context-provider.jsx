import React, {useCallback, useContext, useEffect, useMemo, useState} from 'react'
import fetched from "../lib/fetched";
import {BACKEND_URL} from "../config/constant";

const AuthContext = React.createContext()

export function useAuthContext() {
  return useContext(AuthContext)
}

export default function AuthContextProvider({children}) {
  const [tokens, setTokens] = useState(
    JSON.parse(localStorage.getItem('tokens'))
  )
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)

  const login = useCallback(function (tokens) {
    localStorage.setItem('tokens', JSON.stringify(tokens))
    setTokens(tokens)
    setLoading(true)
  }, [])

  const logout = useCallback(function () {
    localStorage.removeItem('tokens')
    setTokens(null)
    setProfile(null)
    setLoading(false)
  }, [])

  useEffect(() => {
    async function fetchProfile() {
      const {access_token} = tokens
      const res = await fetched(new URL('/users/me', BACKEND_URL), {
        headers: {Authorization: `Bearer ${access_token}`}
      })
      if (res.status === 200) {
        setProfile(res.data)
      }
      setLoading(false)
    }

    if (tokens && !profile && loading) fetchProfile()
  }, [tokens, profile, loading])

  const value = useMemo(
    () => ({
      tokens,
      login,
      profile,
      logout,
      isAuthenticated: !!tokens,
      loading
    }),
    [tokens, login, profile, logout, loading]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}