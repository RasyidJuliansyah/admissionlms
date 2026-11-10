import 'dotenv/config'
import { defineConfig } from 'prisma/config'

/**
 * Prisma 7 tidak lagi menerima `url` di dalam blok datasource pada schema.prisma.
 * Connection string pindah ke sini, dan hanya dipakai perintah yang benar-benar
 * menyentuh database seperti `prisma db push`. Runtime aplikasi memakai driver
 * adapter, lihat src/services/prisma.ts.
 *
 * Dibaca lewat process.env, bukan helper env() dari Prisma, sebab helper itu melempar
 * error ketika variabelnya kosong. `prisma generate` tidak butuh koneksi, dan saat
 * build image memang tidak ada .env yang ikut tersalin.
 */
export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: process.env.DATABASE_URL,
  },
})
