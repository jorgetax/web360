import fs from 'fs'
import {dirname} from 'path'
import {fileURLToPath} from 'url'
import express from 'express'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const router = express.Router()

fs.readdirSync(__dirname).forEach(file => {
  if (file === 'index.js') return

  const pathname = file.split('.')[0]

  import(`./${file}`).then(({default: route}) => {
    router.use(`/${pathname}`, route)
  })
})

export default router