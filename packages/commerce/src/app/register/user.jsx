import {useForm} from 'react-hook-form'
import {useRegisterContext} from '../../context/register-context-provider'
import {useEffect} from 'react'
import Progress from './progress'
import Input from '../../components/ui/input'
import Button from '../../components/ui/button'
import {useNavigate} from 'react-router-dom'
import {date, object, string} from 'yup'

export default function User({current, steps}) {
  const [state, dispatch] = useRegisterContext()
  const navigate = useNavigate()
  const {register, handleSubmit, reset, setError, formState: {errors}} = useForm()

  useEffect(() => {
    if (!state.company && steps > 2) navigate('/organization')
  }, [state.company, steps, navigate])

  useEffect(() => {
    dispatch({type: 'SET_STEP', data: {current, steps}})
    if (!state.user) return
    reset(state.user)
  }, [state.user, reset])

  const onSubmit = async (data) => {
    const user = object({
      first_name: string().required('El nombre es requerido'),
      last_name: string().required('El apellido es requerido'),
      //format dd/mm/yyyy
      birth_date: date().required('La fecha de nacimiento es requerida').typeError('La fecha de nacimiento es requerida')
    })
    try {
      await user.validate(data, {abortEarly: false})
      dispatch({type: 'SET_USER', data})
      navigate(steps > 2 ? '/organization/credential' : '/signup/credential')
    } catch (e) {
      e.inner.forEach(({path, message}) => {
        if (path === 'birth_date') return setError(path, {
          type: 'manual',
          message: 'Coloca una fecha de nacimiento válida'
        })
        setError(path, {type: 'manual', message})
      })
    }
  }

  return (
    <div className="form">
      <div className="">
        <Progress/>
        <p>Intruduce tus datos personales</p>
      </div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label>Nombre</label>
        <Input {...register('first_name',)} placeholder="John"/>
        {errors.first_name && <span className="error">{errors.first_name.message}</span>}
        <label>Apellido</label>
        <Input {...register('last_name',)} placeholder="Doe"/>
        {errors.last_name && <span className="error">{errors.last_name.message}</span>}
        <label>Fecha de nacimiento</label>
        <Input type="date" {...register('birth_date',)}/>
        {errors.birth_date && <span className="error">{errors.birth_date.message}</span>}
        <div className="action">
          <Button type="submit">Siguiente</Button>
        </div>
      </form>
    </div>
  )
}
