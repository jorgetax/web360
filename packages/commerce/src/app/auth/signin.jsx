import '../page.css'
import Input from '../../components/ui/input'
import Button from '../../components/ui/button'
import {useState} from 'react'
import {Link, useNavigate} from 'react-router-dom'
import {signin} from './actions'
import {useForm} from 'react-hook-form'
import {useAuthContext} from '../../context/auth-context-provider'

export default function SignIn() {
  const [state, setState] = useState({loading: false, error: null})
  const {register, handleSubmit} = useForm()
  const navigate = useNavigate()
  const {login} = useAuthContext()

  const onSubmit = async (d) => {
    setState({loading: true, error: null})
    const res = await signin(d)

    if (res.status === 200) {
      login(res)
      return navigate('/')
    }
    setState({loading: false, error: res.data ? 'Usuario o contraseña incorrectos' : 'Error de conexión'})
  }

  return (
    <div className="page">
      <form className="form" onSubmit={handleSubmit(onSubmit)}>
        <Input {...register('email')} type="email" placeholder="Correo electrónico" autoComplete="email"/>
        <Input {...register('password')} type="password" placeholder="Contraseña" autoComplete="current-password"/>
        {state.error && <div className="error">{state.error}</div>}
        <Link to={'/signup'}>Crear cuenta</Link>
        <Button type="submit" disabled={state.loading}>{state.loading ? 'Cargando...' : 'Iniciar sesión'}</Button>
      </form>
    </div>
  )
}