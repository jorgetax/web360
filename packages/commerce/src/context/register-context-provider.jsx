import React, {useContext, useReducer} from 'react'

const RegisterContext = React.createContext()

export function useRegisterContext() {
  return useContext(RegisterContext)
}

function reducer(state, action) {
  switch (action.type) {
    case 'SET_COMPANY':
      return {...state, company: action.data}
    case 'SET_USER':
      return {...state, user: action.data}
    case 'SET_CREDENTIAL':
      return {...state, credential: action.data}
    case 'SET_STEP':
      return {...state, step: action.data}
    default:
      return state
  }
}

export default function RegisterContextProvider({children}) {
  const [state, dispatch] = useReducer(reducer, {step: 0})
  return <RegisterContext.Provider value={[state, dispatch]}>{children}</RegisterContext.Provider>
}