import React, {useContext, useReducer} from 'react'

const CartContext = React.createContext()

export function useCartContext() {
  return useContext(CartContext)
}

function reducer(cart, action) {
  switch (action.type) {
    case 'add':
      return [...cart, action.item]
    case 'remove':
      return cart.filter(item => item.id !== action.id)
    default:
      return cart
  }
}

export default function CartContextProvider({children}) {
  const [state, dispatch] = useReducer(reducer, {})
  return <CartContext.Provider value={[state, dispatch]}>{children}</CartContext.Provider>
}