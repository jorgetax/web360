import '../page.css'
import Input from '../../components/ui/input'
import Button from '../../components/ui/button'
import {useState} from 'react'
import {Link, useNavigate} from 'react-router-dom'
import {useForm} from 'react-hook-form'
import {useAuthContext} from '../../context/auth-context-provider'
import {signup} from './actions'
import {ButtonGroup, Select} from "@mui/material";

export default function Signup() {
  const [state, setState] = useState({loading: false, error: null})
  const {register, handleSubmit} = useForm()
  const navigate = useNavigate()
  const {login} = useAuthContext()

  const onSubmit = async (d) => {
    setState({loading: true, error: null})
    const res = await signup(d)

    if (res.status === 200) {
      login(res)
      return navigate('/')
    }
    setState({loading: false, error: res.data ? 'Usuario o contraseña incorrectos' : 'Error de conexión'})
  }

  return (
    <div className="page">
      <form className="form" onSubmit={handleSubmit(onSubmit)}>
        <Input {...register('first_name')} type="text" placeholder="Nombre"/>
        <Input {...register('last_name')} type="text" placeholder="Apellido"/>
        <Input {...register('birth_date')} type="date" placeholder="Fecha de nacimiento"/>
        <Input {...register('email')} type="email" placeholder="Correo electrónico" autoComplete="email"/>
        <Input {...register('password')} type="password" placeholder="Contraseña" autoComplete="current-password"/>
        {state.error && <div className="error">{state.error}</div>}
        <Link to={'/signin'}>¿Ya tienes una cuenta?</Link>
        <Select variant={"outlined"} {...register('role')} placeholder="Rol">
          <option value="admin">Administrador</option>
          <option value="user">Usuario</option>
        </Select>
        <Button type="submit" disabled={state.loading}>{state.loading ? 'Cargando...' : 'Registrarse'}</Button>
      </form>
    </div>
  )
}