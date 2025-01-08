import {useForm} from 'react-hook-form'
import {useRegisterContext} from '../../context/register-context-provider'
import {useEffect} from 'react'
import Progress from './progress'
import Input from '../../components/ui/input'
import Button from '../../components/ui/button'
import {useNavigate} from 'react-router-dom'
import {organization, signup} from './actions'
import {object, string} from 'yup'

export default function Credential({current, steps}) {
  const [state, dispatch] = useRegisterContext()
  const navigate = useNavigate()
  const {register, handleSubmit, reset, setError, formState: {errors}} = useForm()

  useEffect(() => {
    if (!state.user && steps > 2) {
      navigate('/organization')
    } else if (!state.user) {
      navigate('/signup')
    }
  }, [state.user, steps, navigate])

  useEffect(() => {
    dispatch({type: 'SET_STEP', data: {current, steps}})

    if (!state.credential) return
    reset(state.credential)
  }, [state.credential, current, steps, dispatch, reset])

  const onSubmit = async (data) => {
    const credential = object({
      email: string().email().required('Correo electrónico es requerido'),
      password: string().required('Contraseña es requerida')
    })
    dispatch({type: 'SET_CREDENTIAL', data})

    try {
      await credential.validate(data, {abortEarly: false})
      if (steps > 2) {
        const res = await organization({...state.company, ...state.user, ...data})
        if (res.status !== 201) {
          return setError('email', {type: 'manual', message: res.data.message})
        }
        return navigate('/signin')
      }

      const res = await signup({...state.user, ...data})
      if (res.status !== 201) {
        return setError('email', {type: 'manual', message: res.data.message})
      }
      return navigate('/signin')
    } catch (e) {
      if (e.name !== 'ValidationError') {
        return setError('email', {type: 'manual', message: 'Algo salió mal, el correo electrónico ya está en uso'})
      }
      e.inner.forEach(({path, message}) => {
        if (path === 'email') return setError(path, {type: 'manual', message: 'Coloca un correo electrónico válido'})
        setError(path, {type: 'manual', message})
      })
    }
  }

  return (
    <div className="form">
      <div className="">
        <Progress/>
        <div>Introduce tus credenciales</div>
      </div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label>Correo electrónico</label>
        <Input {...register('email')} type="email"/>
        {errors.email && <span className="error">{errors.email.message}</span>}
        <label>Contraseña</label>
        <Input {...register('password')} type="password"/>
        {errors.password && <span className="error">{errors.password.message}</span>}
        <div className="action">
          <Button type="submit">Crear cuenta</Button>
        </div>
      </form>
    </div>
  )
}
