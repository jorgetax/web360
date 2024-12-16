import React, {useContext} from 'react'

const cartContext = React.createContext()

export function useCartContext() {
  return useContext(cartContext)
}

export default function CartProvider({children}) {
  const [cart, setCart] = React.useState([])
  const [cartOpen, setCartOpen] = React.useState(false)

  return (
    <cartContext.Provider value={{cart, setCart, cartOpen, setCartOpen}}>
      {children}
    </cartContext.Provider>
  )
}