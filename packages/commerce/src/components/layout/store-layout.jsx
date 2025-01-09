import CartContextProvider from "../../context/cart-context-provider";
import {Outlet} from "react-router-dom";
import GithubIcon from "../icon/github-icon";

export default function StoreLayout() {
  return (
    <CartContextProvider>
      <div className="page">
        <div className="header">
          <a href="https://github.com/jorgetax/web360.git" target="_blank">
            <GithubIcon/>
            <span>Ver en Github →</span>
          </a>
        </div>
        <main className="main">
          <Outlet/>
        </main>
      </div>
    </CartContextProvider>
  );
}