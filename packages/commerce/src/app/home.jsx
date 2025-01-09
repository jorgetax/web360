import './page.css'
import {Link, Navigate} from 'react-router-dom'
import GithubIcon from '../components/icon/github-icon'
import ProductIcon from '../components/icon/product-icon'
import GroupIcon from '../components/icon/group-icon'
import ListIcon from '../components/icon/list-icon'
import CategoryIcon from '../components/icon/category-icon'
import {useAuthContext} from "../context/auth-context-provider"

export default function Home() {
  const {isAuthenticated, loading, profile} = useAuthContext()

  if (isAuthenticated && loading) return <div>Loading...</div>

  if (isAuthenticated && profile) {
    const {organization} = profile
    return <Navigate to={organization ? `/${organization.id}` : '/store'}/>
  }

  return (
    <div className="page">
      <div className="header">
        <a href="https://github.com/jorgetax/web360.git" target="_blank">
          <GithubIcon/>
          <span>Ver en Github →</span>
        </a>
      </div>
      <main className="main">
        <div className="banner">
          <div className="content">
            <h1>La mejor aplicación para tu negocio</h1>
            <p>Administra tus productos, clientes y pedidos de forma sencilla.</p>
          </div>
          <div className="features">
            <h2>Características</h2>
            <ol>
              <li><CategoryIcon/><span>Categorías</span></li>
              <li><ProductIcon/><span>Productos</span></li>
              <li><GroupIcon/><span>Clientes</span></li>
              <li><ListIcon/><span>Pedidos</span></li>
            </ol>
          </div>
        </div>
        <div className="action">
          <Link to="/organization" className="button primary">Comenzar</Link>
          <Link to="/signin" className="button secondary">Iniciar sesión</Link>
        </div>
      </main>
      <footer className="footer">
        <p>&copy; {new Date().getFullYear()}</p>
      </footer>
    </div>
  )
}