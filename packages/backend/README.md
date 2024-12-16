## REST API

| Ruta          | Descripción       | Acceso                 |
|---------------|-------------------|------------------------|
| /states       | Listar estados    | Administrador, Usuario |
| /categories   | Listar categorías | Administrador, Usuario |
| /products     | Listar productos  | Administrador, Usuario |
| /products/:id | Obtener producto  | Administrador, Usuario |
| /orders       | Listar órdenes    | Administrador, Usuario |
| /orders/:id   | Obtener orden     | Administrador, Usuario |

## Ejecutar el proyecto localmente

> Nota: Asegúrate de configurar las variables de entorno en un archivo `.env` en la raíz del proyecto.
> Puedes encontrar un archivo de ejemplo en `.env.example`.

```bash
npm install
npm run dev
```