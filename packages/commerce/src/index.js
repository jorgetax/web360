import React from 'react'
import {createRoot} from 'react-dom/client'
import './global.css'
import {createBrowserRouter, RouterProvider} from 'react-router-dom'
import NotFound from './app/not-found'
import Layout from './components/layout/layout'
import Home from './app/home'
import Register from './app/register/register'
import Organization from './app/register/organization'
import User from './app/register/user'
import Credential from './app/register/credential'
import SignIn from './app/auth/signin'
import AuthHandler from "./hooks/auth-handler";

const router = createBrowserRouter([
  {
    element: <Layout/>, children: [
      {path: '/', element: <Home/>},
      {
        path: '/register', element: <Register steps="3"/>, children: [
          {path: 'organization', element: <Organization current="1" steps="3"/>},
          {path: 'user', element: <User current="2" steps="3"/>},
          {path: 'credential', element: <Credential current="3" steps="3"/>}
        ]
      },
      {path: '/signin', element: <SignIn/>},
      {
        path: '/signup', element: <Register steps="2"/>, children: [
          {path: 'user', element: <User current="1" steps="2"/>},
          {path: 'credential', element: <Credential current="2" steps="2"/>}
        ]
      },
      {
        element: <AuthHandler/>, children: [
          {path: '/:id', element: <div>Profile</div>},
        ]
      },
      {path: '/*', element: <NotFound/>}
    ]
  }
])

const root = createRoot(document.getElementById('root'))
root.render(<RouterProvider router={router}/>)