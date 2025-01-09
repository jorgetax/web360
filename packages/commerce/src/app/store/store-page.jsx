export default function StorePage() {
  const fakeProduct = [
    {
      name: 'Fake Product',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 2',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 3',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 4',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 5',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 6',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 7',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 8',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 9',
      description: 'This is a fake product.',
      price: 99.99
    }, {
      name: 'Fake Product 10',
      description: 'This is a fake product.',
    }
  ]
  return (
    <div>
      <h1>Store Page</h1>
      <div>
        {fakeProduct.map(product => (
          <div key={product.name}>
            <h2>{product.name}</h2>
            <p>{product.description}</p>
            <p>{product.price}</p>
          </div>
        ))}
      </div>
    </div>
  );
}