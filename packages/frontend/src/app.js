import AuthContextProvider from './context/auth-context-provider'
import CartContextProvider from './context/cart-context-provider'
import {BrowserRouter, Route, Routes} from 'react-router-dom'
import Home from './page/home'
import SignIn from './page/auth/signin'
import NotFound from './page/not-found'
import Signup from './page/auth/signup'
import AuthHandler from './hooks/auth-handler'
import ProductPage from './page/product'
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
