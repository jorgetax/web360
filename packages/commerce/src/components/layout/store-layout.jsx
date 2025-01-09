import CartContextProvider from "../../context/cart-context-provider";
import {Link, Outlet} from "react-router-dom";
import SupervisorAccount from "../icon/supervisor-account-icon";
import CartIcon from "../icon/cart-icon";

export default function StoreLayout() {
  return (
    <CartContextProvider>
      <div className="page">
        <div className="header">
          <h1>Store</h1>
          <div className="action">
            <Link to="/logout" className="button secondary">
              <div className="wrapper">
                <SupervisorAccount/>
                <span>Salir</span>
              </div>
            </Link>
            <Link to="/store" className="button primary">
              <div className="wrapper">
                <CartIcon/>
                <span>Carrito</span>
              </div>
            </Link>
          </div>
        </div>
        <main className="main">
          <Outlet/>
        </main>
      </div>
    </CartContextProvider>
  )
}