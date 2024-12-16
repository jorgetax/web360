import './styles.css'
import Input from '../components/ui/input'
import Button from '../components/ui/button'
import {useState} from 'react'
import {IsEmpty} from '../lib/check'
import {useNavigate} from "react-router-dom";

export default function SignIn() {
  const [form, setForm] = useState({email: '', password: ''})
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const navigate = useNavigate()

  const handleChange = (e) => {
    const {name, value} = e.target
    setForm({...form, [name]: value})
    if (error) setError(null)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)

    if (Object.values(form).some(value => IsEmpty(value))) {
      setError('Todos los campos son requeridos.')
      setLoading(false)
      return
    }

    const res = await fetch('http://localhost:5000/auth/signin', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(form)
    })
    const data = await res.json()

    if (res.status !== 200) {
      setError('Credenciales incorrectas.')
    }

    if (res.status === 500) {
      setError('Error en el servidor.')
    }

    setLoading(false)
    setError(JSON.stringify(data, null, 2))

    return navigate('/')
  }

  return (
    <div className="page">
      <div className="grid-2">
        <div className="wrapper">
          <h1 className="h1">Web360</h1>
          <p className="p">Ingresa tus datos para iniciar sesión, si no tienes una cuenta puedes solicitar acceso a tu
            administrador.</p>
        </div>
        <form className="form" onSubmit={handleSubmit}>
          <div className="wrapper">
            <Input type="email" placeholder="Correo electrónico" value={form.email} onChange={handleChange}
                   name="email"/>
            <Input type="password" placeholder="Contraseña" value={form.password} onChange={handleChange}
                   name="password"/>
            {error && <p className="error">{error}</p>}
            <Button type="submit" disabled={loading}>{loading ? 'Cargando...' : 'Iniciar sesión'}</Button>
          </div>
        </form>
      </div>
    </div>
  )
}