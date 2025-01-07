import clsx from 'clsx'

export default function Button(props) {
  return <button className={clsx('button', 'primary')} {...props}/>
}