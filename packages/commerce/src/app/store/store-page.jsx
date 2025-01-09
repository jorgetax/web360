import {Link} from "react-router-dom";
import Button from "../../components/ui/button";
import GithubIcon from "../../components/icon/github-icon";
import {useEffect, useState} from "react";
import {useAuthContext} from "../../context/auth-context-provider";
import {allProducts} from "./actions";

export default function StorePage() {
  const [products, setProducts] = useState([])
  const {tokens} = useAuthContext()

  useEffect(() => {
    if (!products.length) {
      const {access_token} = tokens
      allProducts(access_token).then((res) => {
        if (res.status === 200) {
          setProducts(res.data)
        }
      })
    }
  }, []);

  const addToCart = (product) => {
    console.log('Adding product to cart:', product);
  }


  return (
    <div className="gallery">
      {products.length ? products.map(product => (
        <div className={'product'} key={product.name}>
          <div className="badge">
            <p>{product.stock} disponibles</p>
          </div>
          <Link key={product.name} to={`/store/${product.name}`} className={'product'}>
            <img src="https://via.placeholder.com/150" alt="Product"/>
          </Link>
          <div className="action flex padding-top">
            <div className="info flex">
              <p className="name">{product.name}</p>
              <h3 className="price">Q{product.price}</h3>
            </div>
            <Button className="button secondary" onClick={() => addToCart(product)}>
              <GithubIcon/>
            </Button>
          </div>
        </div>
      )) : <p>No hay productos disponibles</p>}
    </div>
  );
}