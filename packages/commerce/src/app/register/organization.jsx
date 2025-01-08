import '../page.css'
import {useForm} from 'react-hook-form'
import {useRegisterContext} from '../../context/register-context-provider'
import Input from '../../components/ui/input'
import {useNavigate} from 'react-router-dom'
import {useEffect} from 'react'
import Progress from './progress'
import Button from '../../components/ui/button'
import {object, string} from 'yup'

export default function Organization({current, steps}) {
  const [state, dispatch] = useRegisterContext()
  const navigate = useNavigate()
  const {register, handleSubmit, reset, setError, formState: {errors}} = useForm()

  useEffect(() => {
    dispatch({type: 'SET_STEP', data: {current, steps}})
    if (!state.company) return
    reset(state.company)
  }, [state.company, reset])

  const onSubmit = async (data) => {
    const company = object({
      name: string().required('El nombre de la empresa es requerido'),
      description: string().required('La descripción de la empresa es requerida')
    })
    try {
      await company.validate(data, {abortEarly: false})
      dispatch({type: 'SET_COMPANY', data})
      navigate('/organization/user')
    } catch (e) {
      e.inner.forEach(({path, message}) => {
        setError(path, {type: 'manual', message})
      })
    }
  }

  return (
    <div className="form">
      <div className="">
        <Progress/>
        <div>¡Bienvenido!, estamos a punto de crear tu cuenta en nuestra plataforma. Por favor, completa los siguientes
          campos.
        </div>
      </div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <label>Nombre de la empresa</label>
        <Input {...register('name')} placeholder="Mi empresa S.A."/>
        {errors.name && <span className="error">{errors.name.message}</span>}
        <label>Descripción de la empresa</label>
        <Input {...register('description')}
               placeholder="Empresa dedicada a la venta de productos..."/>
        {errors.description && <span className="error">{errors.description.message}</span>}
        <div className="action">
          <Button type="submit">Siguiente</Button>
        </div>
      </form>
    </div>
  )
}