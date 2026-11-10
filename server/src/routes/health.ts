import { Router } from 'express'
import { config } from '../config'

export const healthRouter = Router()

healthRouter.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    version: config.version,
    uptimeSeconds: Math.floor(process.uptime()),
  })
})
