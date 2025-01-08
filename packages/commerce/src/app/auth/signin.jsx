import '../page.css'
import Input from '../../components/ui/input'
import Button from '../../components/ui/button'
import {Link, Navigate, useNavigate} from 'react-router-dom'
import {signin} from './actions'
import {useForm} from 'react-hook-form'
import {useAuthContext} from '../../context/auth-context-provider'
import {object, string} from 'yup'

export default function SignIn() {
  const {register, handleSubmit, reset, setError, formState: {errors}} = useForm()
  const navigate = useNavigate()
  const {login} = useAuthContext()

  const onSubmit = async (data) => {
    const schema = object({
      email: string().email('Correo electrónico inválido').required('Correo electrónico requerido'),
      password: string().required('Contraseña requerida')
    })
    try {
      await schema.validate(data, {abortEarly: false})
      const res = await signin(data)

      if (res.status !== 200) {
        setError('email', {type: 'manual', message: 'Credenciales inválidas'})
        return
      }

      login(res.data)
      navigate('/dashboard')
    } catch (e) {
      e.inner.forEach(({path, message}) => {
        setError(path, {type: 'manual', message})
      })
    }
  }

  return (
    <div className="page">
      <main className="main">
        <div className="form">
          <h1>Iniciar sesión</h1>
          <form onSubmit={handleSubmit(onSubmit)}>
            <label>Correo electrónico</label>
            <Input {...register('email')} type="email" placeholder="Correo electrónico" autoComplete="email"/>
            {errors.email && <span className="error">{errors.email.message}</span>}
            <label>Contraseña</label>
            <Input {...register('password')} type="password" placeholder="Contraseña" autoComplete="current-password"/>
            {errors.password && <span className="error">{errors.password.message}</span>}
            <div className="action">
              <Link to={'/signup/user'} className="button secondary">Crear cuenta</Link>
              <Button type="submit"
                      disabled={Object.keys(errors) > 0}>{Object.keys(errors) > 0 ? 'Cargando...' : 'Iniciar sesión'}</Button>
            </div>
          </form>
        </div>
      </main>
    </div>
  )
}