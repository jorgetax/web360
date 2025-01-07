import {useRegisterContext} from '../../context/register-context-provider'

export default function Progress() {
  const [state] = useRegisterContext()

  return (
    <div className="progress">
      <h3>{state.step.current}/{state.step.steps}</h3>
    </div>
  )
}