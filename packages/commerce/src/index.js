import React from 'react'
import {createRoot} from 'react-dom/client'
import './global.css'
import {createBrowserRouter, RouterProvider} from 'react-router-dom'
import NotFound from './app/not-found'
import AuthLayout from './components/layout/auth-layout'
import Home from './app/home'
import Organization from './app/register/organization'
import User from './app/register/user'
import Credential from './app/register/credential'
import SignIn from './app/auth/signin'
import DashboardLayout from './components/layout/dashboard-layout'
import RegisterLayout from "./components/layout/register-layout";
import Logout from "./app/logout";
import StoreLayout from "./components/layout/store-layout";
import RoleLayout from './components/layout/role-layout'
import CustomerPage from './app/customer/customer-page'
import ProductPage from "./app/product/product-page";
import OrderPage from "./app/order/order-page";
import CategoryPage from "./app/category/category-page";
import UserPage from "./app/user";
import StorePage from "./app/store/store-page";

const router = createBrowserRouter([
  {
    element: <AuthLayout/>, children: [
      {path: '/', element: <Home/>},
      {
        element: <RegisterLayout/>, children: [
          {path: '/signin', element: <SignIn/>},
          {path: '/organization', element: <Organization current="1" steps="3"/>},
          {path: '/organization/user', element: <User current="2" steps="3"/>},
          {path: '/organization/credential', element: <Credential current="3" steps="3"/>},
          {path: '/signup/user', element: <User current="1" steps="2"/>},
          {path: '/signup/credential', element: <Credential current="2" steps="2"/>}
        ]
      }, {
        element: <RoleLayout/>, children: [
          {
            element: <DashboardLayout/>, children: [
              {path: '/:id', element: <div>Dashboard</div>},
              {path: '/:id/orders', element: <OrderPage/>},
              {path: '/:id/products', element: <ProductPage/>},
              {path: '/:id/categories', element: <CategoryPage/>},
              {path: '/:id/customers', element: <CustomerPage/>},
              {path: '/:id/users', element: <UserPage/>}
            ]
          },
          {
            element: <StoreLayout/>, children: [
              {path: '/store', element: <StorePage/>}
            ]
          },
        ]
      },
      {path: '/logout', element: <Logout/>},
    ]
  },
  {path: '/*', element: <NotFound/>}
])

const root = createRoot(document.getElementById('root'))
root.render(<RouterProvider router={router}/>)