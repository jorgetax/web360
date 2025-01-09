import {Link} from "react-router-dom";
import AddIcon from "../../components/icon/add-icon";

export default function CategoryPage() {
  const categories = [
    {id: "1", code: "t-shirt", name: "Camisetas"},
    {id: "2", code: "pants", name: "Pantalones"},
    {id: "3", code: "shoes", name: "Zapatos"},
    {id: "4", code: "accessories", name: "Accesorios"},
  ]
  return (
    <div className="page">
      <header className="header">
        <h1>Categorias</h1>
        <div className="action">
          <Link to="/store" className="button primary">
            <div className="wrapper">
              <AddIcon/>
              <span>Nuevo</span>
            </div>
          </Link>
        </div>
      </header>
      <main className="main">
        <table className={"table"}>
          <thead>
          <tr>
            <th>Código</th>
            <th>Nombre</th>
            <th>Acciones</th>
          </tr>
          </thead>
          <tbody>
          {categories.map(category => (
            <tr key={category.id}>
              <td>{category.code}</td>
              <td>{category.name}</td>
              <td>
                <Link to={`/categories/${category.id}`}>Editar</Link>
              </td>
            </tr>
          ))}
          </tbody>
        </table>
      </main>
    </div>
  );
}