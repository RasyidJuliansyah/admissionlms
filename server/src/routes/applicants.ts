import { Router } from 'express'
import { prisma } from '../services/prisma'

export const applicantsRouter = Router()

/**
 * Endpoint sederhana yang memang menyentuh database. Selain berguna sendiri, ini
 * dipakai smoke test image untuk membuktikan Prisma Client masih utuh setelah
 * paket CLI dipangkas dari node_modules produksi.
 */
applicantsRouter.get('/applicants/count', async (_req, res, next) => {
  try {
    const total = await prisma.applicant.count({ where: { isActive: true } })
    res.json({ total })
  } catch (err) {
    next(err)
  }
})
