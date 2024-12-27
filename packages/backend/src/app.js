import express from 'express'
import cors from 'cors'
import router from './router/index.js'
import {PORT} from './config/constant.js'

const app = express()

app.use(cors())
app.use(express.json())

// dynamically import the router
app.use(router)

app.use(function (req, res, next) {
  res.setHeader('Content-Type', 'text/plain')
  res.status(404).send('Not Found')
})

app.listen(PORT, () => {
  console.log(`✓ Server is running on http://localhost:${PORT}`)
})