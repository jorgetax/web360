# Backend Server

e-commerce backend server for the [web360](`./packages/frontend/README.md`) project.

## Technologies

- Node.js
- Express
- React
- SQL Server

## Features

- User Authentication
- Customer Management
- Product Management
- Order Management
- Cart Management

## Crud Operations

| Operation | Method | Route | Description           |
|-----------|--------|-------|-----------------------|
| Create    | POST   | /...  | Create a new resource |
| Read      | GET    | /...  | Get a resource        |
| Patch     | PATCH  | /...  | Update a resource     |
| Delete    | DELETE | /...  | Delete a resource     |

## Endpoints

| Route       | Description         |
|-------------|---------------------|
| /auth       | User Authentication |
| /users      | Customer Management |
| /categories | Category Management |
| /products   | Product Management  |
| /orders     | Order Management    |
| /states     | State Management    |

## Getting Started

First, run the development server:

```bash
npm run dev
```

Open [http://localhost:5000](http://localhost:5000) with your browser to see the result.


