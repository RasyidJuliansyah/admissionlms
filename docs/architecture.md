# Arsitektur AdmissionLMS

## Bentuk sistem

Satu monorepo npm workspaces berisi dua paket, dibangun menjadi satu image Docker.

```
browser
   │
   ▼
Express (:3001)
   ├── /api/*          → route handler, service, Prisma
   └── selain /api/*   → berkas statis hasil build Vite
                          (fallback ke index.html untuk rute SPA)
   │
   ▼
MySQL 8
```

Frontend tidak punya server sendiri. Hasil `vite build` disalin ke dalam image dan
disajikan Express sebagai berkas statis. Keputusan ini beserta konsekuensinya ada di
[ADR-001](adr/001-deploy-image-tunggal-bertag-versi.md).

## Paket

| Paket | Isi |
|---|---|
| `client/` | Vue 3, Vuetify, Tailwind (utilities saja), Vue Router, Pinia, Vite |
| `server/` | Express 5, TypeScript, Prisma 7 dengan adapter mariadb |

`tests/e2e/` berada di root karena menguji keduanya sekaligus.

## Development

Client jalan di `:5173` dengan dev server Vite, server di `:3001`. Vite memproxy
`/api` ke server, sehingga panggilan API selama development memakai origin yang sama
dengan saat produksi. Tidak ada konfigurasi CORS yang perlu dibedakan antar lingkungan.

## Prisma 7 dan driver adapter

Prisma 7 memakai driver adapter, bukan engine biner Rust. Akibatnya:

- Connection string tidak lagi boleh ditulis di `schema.prisma`. Tempatnya di
  `server/prisma.config.ts`, dan hanya dipakai perintah CLI.
- Runtime memakai `@prisma/adapter-mariadb`, yang kompatibel dengan MySQL 8.
  Instansiasinya ada di `server/src/services/prisma.ts`.
- Image produksi lebih kecil, sebab tidak ada engine biner yang ikut disalin.

## Lapisan di backend

```
routes/        definisi endpoint, validasi bentuk request
controllers/   orkestrasi satu permintaan
services/      logika domain dan akses Prisma
middleware/    auth, RBAC, penanganan error
```

Akses Prisma hanya terjadi di `services/`. Route handler tidak memanggil Prisma
langsung, supaya logika domain dapat diuji tanpa lapisan HTTP.

## Versi yang berjalan

Endpoint `GET /api/health` mengembalikan tag image yang sedang aktif:

```json
{ "status": "ok", "version": "2026.11.10-abc1234", "uptimeSeconds": 42 }
```

Nilainya berasal dari `ARG APP_VERSION` saat build, yang diisi
`scripts/build-image.sh` dari tanggal dan commit SHA. Dengan begitu versi yang
berjalan di server dapat dipastikan tanpa masuk ke shell container.

## Migrasi database

Tidak memakai `prisma migrate`. Perubahan skema produksi ditulis sebagai skrip SQL
delta idempotent di `server/prisma/deltas/` dan dijalankan sebelum image versi baru
dinaikkan. Alasan dan konsekuensinya ada di
[ADR-002](adr/002-migrasi-skema-produksi-dengan-skrip-sql-delta.md).
