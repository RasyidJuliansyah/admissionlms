import path from 'node:path'

export const config = {
  port: Number(process.env.PORT ?? 3001),
  /**
   * Tag image yang sedang berjalan, disuntikkan saat build lewat ARG APP_VERSION.
   * Nilainya dipakai endpoint /api/health supaya versi yang aktif di server dapat
   * dipastikan tanpa masuk ke shell container.
   */
  version: process.env.APP_VERSION ?? 'dev',
  /** Hasil build Vite yang disalin ke image pada stage terakhir Dockerfile. */
  clientDist: process.env.CLIENT_DIST ?? path.resolve(__dirname, '../../client/dist'),
}
