import 'dotenv/config'
import { PrismaMariaDb } from '@prisma/adapter-mariadb'
import { PrismaClient } from '@prisma/client'

/**
 * Prisma 7 memakai driver adapter, bukan engine biner. Adapter mariadb kompatibel
 * dengan MySQL 8 dan membuat image produksi lebih kecil karena tidak ada engine Rust
 * yang ikut disalin.
 */
const databaseUrl = process.env.DATABASE_URL

if (!databaseUrl) {
  throw new Error('DATABASE_URL belum diisi. Salin server/.env.example ke server/.env.')
}

const adapter = new PrismaMariaDb(databaseUrl)

export const prisma = new PrismaClient({ adapter })
