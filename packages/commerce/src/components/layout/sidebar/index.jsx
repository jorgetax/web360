import {Link, useLocation} from 'react-router-dom'
import ProductIcon from '../../icon/product-icon'
import CategoryIcon from '../../icon/category-icon'
import GroupIcon from '../../icon/group-icon'
import SupervisorAccount from '../../icon/supervisor-account-icon'
import ListIcon from '../../icon/list-icon'
import HomeIcon from '../../icon/home-icon'

const menu = [
  {name: 'Inicio', path: '/', icon: <HomeIcon/>},
  {name: 'Ordenes', path: '/orders', icon: <ListIcon/>},
  {name: 'Productos', path: '/products', icon: <ProductIcon/>},
  {name: 'Categorias', path: '/categories', icon: <CategoryIcon/>},
  {name: 'Clientes', path: '/clients', icon: <GroupIcon/>},
  {name: 'Usuarios', path: '/users', icon: <SupervisorAccount/>},
]

export default function Sidebar() {
  const location = useLocation()
  const currentPath = location.pathname

  return (
    <div className="sidebar">
      <div className="header">
        <h1>Web360</h1>
      </div>
      <div className="content">
        <ul className="menu">
          {menu.map((item, index) => (
            <li key={index}>
              <Link to={item.path} className={currentPath === item.path ? 'active' : ''}>
                <div className="wrapper">
                  {item.icon}
                  <span>{item.name}</span>
                </div>
              </Link>
            </li>
          ))}
        </ul>
      </div>
      <div className="footer">
        <p>Todos los derechos reservados</p>
      </div>
    </div>
  )
}