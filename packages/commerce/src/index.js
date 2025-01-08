import React from 'react'
import {createRoot} from 'react-dom/client'
import './global.css'
import {createBrowserRouter, RouterProvider} from 'react-router-dom'
import NotFound from './app/not-found'
import RouteWithProvider from './components/layout/route-with-provider'
import Home from './app/home'
import Organization from './app/register/organization'
import User from './app/register/user'
import Credential from './app/register/credential'
import SignIn from './app/auth/signin'
import Dashboard from './app/dashboard/page'
import RouteWithAuth from "./components/layout/route-with-auth";
import RouteWithRegister from "./components/layout/route-with-register";
import Logout from "./app/logout";
import StorePage from "./app/store/product-page";
import RouteWithRole from "./components/layout/route-with-role";

const router = createBrowserRouter([
  {
    element: <RouteWithProvider/>, children: [
      {path: '/', element: <Home/>},
      {
        element: <RouteWithAuth/>, children: [
          {
            element: <RouteWithRegister/>, children: [
              {path: '/signin', element: <SignIn/>},
              {path: '/organization', element: <Organization current="1" steps="3"/>},
              {path: '/organization/user', element: <User current="2" steps="3"/>},
              {path: '/organization/credential', element: <Credential current="3" steps="3"/>},
              {path: '/signup/user', element: <User current="1" steps="2"/>},
              {path: '/signup/credential', element: <Credential current="2" steps="2"/>}
            ]
          }, {
            element: <RouteWithRole/>, children: [
              {path: '/:id', element: <Dashboard/>},
            ]
          },
          {path: '/store', element: <StorePage/>},
        ]
      },
      {path: '/logout', element: <Logout/>},
    ]
  },
  {path: '/*', element: <NotFound/>}
])

const root = createRoot(document.getElementById('root'))
root.render(<RouterProvider router={router}/>)