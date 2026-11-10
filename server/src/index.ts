import express from 'express'
import fs from 'node:fs'
import path from 'node:path'

import { config } from './config'
import { applicantsRouter } from './routes/applicants'
import { healthRouter } from './routes/health'

const app = express()

app.use(express.json())
app.use('/api', healthRouter)
app.use('/api', applicantsRouter)

// Berkas statis hasil build frontend. Satu image memuat backend dan frontend
// sekaligus, sesuai ADR-001.
if (fs.existsSync(config.clientDist)) {
  app.use(express.static(config.clientDist))

  // Fallback SPA. Ditulis sebagai middleware, bukan rute berpola wildcard, karena
  // Express 5 memakai path-to-regexp versi baru yang menolak pola '*'.
  app.use((req, res, next) => {
    if (req.path.startsWith('/api')) return next()
    res.sendFile(path.join(config.clientDist, 'index.html'))
  })
}

app.listen(config.port, () => {
  console.log(`AdmissionLMS ${config.version} berjalan di port ${config.port}`)
})
