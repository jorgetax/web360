import './app.css'
import Layout from './components/layout/layout'
import AuthProvider from './provider/auth-provider'
import CartProvider from './provider/cart-provider'
import {BrowserRouter, Route, Routes} from 'react-router-dom'
import Home from './page/home'
import SignIn from './page/signin'
import NotFound from "./page/not-found";

export default function App() {
  return (
    <AuthProvider>
      <CartProvider>
        <BrowserRouter>
          <Layout>
            <Routes>
              <Route path="/" element={<Home/>}/>
              <Route path="/signin" element={<SignIn/>}/>
              <Route path="*" element={<NotFound/>}/>
            </Routes>
          </Layout>
        </BrowserRouter>
      </CartProvider>
    </AuthProvider>
  )
}
