import AuthContextProvider from './context/auth-context-provider'
import CartContextProvider from './context/cart-context-provider'
import {BrowserRouter, Route, Routes} from 'react-router-dom'
import Home from './app/home'
import SignIn from './app/auth/signin'
import NotFound from './app/not-found'
import Signup from './app/auth/signup'
import AuthHandler from './hooks/auth-handler'
import ProductPage from './app/product'
import Layout from './components/layout/layout'

export default function App() {
  return (
    <AuthContextProvider>
      <CartContextProvider>
        <BrowserRouter>
          <Layout>
            <Routes>
              <Route path="/signin" element={<SignIn/>}/>
              <Route path="/signup" element={<Signup/>}/>
              <Route element={<AuthHandler/>}>
                <Route path="/" element={<Home/>}/>
                <Route path="/products" element={<ProductPage/>}/>
              </Route>
              <Route path="*" element={<NotFound/>}/>
            </Routes>
          </Layout>
        </BrowserRouter>
      </CartContextProvider>
    </AuthContextProvider>
  )
}
