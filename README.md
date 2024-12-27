[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/jorgetax/web360?tab=BSD-2-Clause-1-ov-file#readme)

# Tienda en línea

Este proyecto es un sistema de ventas en línea, donde los usuarios pueden registrarse, iniciar sesión, ver productos,
agregar productos al carrito, realizar pedidos y ver el historial de pedidos.

## Tecnologías

- Node.js
- Express
- React
- SQL Server

## Proyecto

- [`backend`](packages/backend) backend de la aplicación.
- [`database.sql`](resource/database.sql) script de la base de datos.
- [`commerce`](packages/commerce) frontend de la aplicación.

![](/resource/web360.png)

## Estructura de directorios

```text
.
|-- packages
|   |-- backend
|   |-- frontend
|-- resource
|-- |-- database.sql
|   |-- web360.png
|-- .gitignore 
|-- compose.yml
|-- package.json
|-- LICENSE
|-- README.md
```

## Configuración del proyecto

1. Clonar el repositorio
2. Crear la base de datos con el script `database.sql`

```bash
# clonar el repositorio
git clone https://github.com/jorgetax/web360.git

# si utiliza docker compose para crear la base de datos
docker compose up -d

# instalar dependencias
cd packages/backend
npm install

# instalar dependencias
cd packages/commerce
npm install
```

## Ejecutar el proyecto

```bash
# ejecutar el backend   
npm run backend

# ejecutar el frontend
npm run commerce
```
