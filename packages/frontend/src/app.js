import './app.css'
import Layout from './components/layout/layout'
import AuthContext from './context/auth-context'
import CartContext from './context/cart-context'
import {BrowserRouter, Route, Routes} from 'react-router-dom'
import Home from './page/home'
import SignIn from './page/signin'
import NotFound from "./page/not-found";

export default function App() {
  return (
    <AuthContext>
      <CartContext>
        <BrowserRouter>
          <Layout>
            <Routes>
              <Route path="/" element={<Home/>}/>
              <Route path="/signin" element={<SignIn/>}/>
              <Route path="*" element={<NotFound/>}/>
            </Routes>
          </Layout>
        </BrowserRouter>
      </CartContext>
    </AuthContext>
  )
}
