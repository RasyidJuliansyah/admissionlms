# AdmissionLMS

Monorepo npm workspaces: `client/` (Vue 3 + Vuetify) dan `server/` (Express + Prisma).
Satu deploy sama dengan satu image Docker yang memuat keduanya.

## Mulai

```bash
npm install
cp server/.env.example server/.env
docker compose up -d   # MySQL di :3307
npm run db:push
npm run dev
```

Client di http://localhost:5173, API di http://localhost:3001.
Panggilan `/api` dari client diproxy ke server, jadi tidak ada urusan CORS saat
development.

## Perintah

| Perintah | Guna |
|---|---|
| `npm run dev` | Jalankan client dan server sekaligus |
| `npm run build` | Build keduanya ke `client/dist` dan `server/dist` |
| `npm run typecheck` | Cek tipe tanpa menghasilkan berkas |
| `npm run db:push` | Terapkan `schema.prisma` ke MySQL lokal |
| `npm run db:generate` | Generate Prisma Client |
| `./scripts/build-image.sh` | Bangun image rilis bertag versi |
| `./scripts/smoke-test.sh <image>` | Uji image: health, query Prisma, fallback SPA |

## Rilis

Tag image berbentuk `YYYY.MM.DD-<7 karakter commit SHA>`, dibuat otomatis oleh
`scripts/build-image.sh`. Skrip menolak jalan jika masih ada perubahan yang belum
di-commit, supaya tag selalu menunjuk ke kode yang benar.

```bash
./scripts/build-image.sh
./scripts/smoke-test.sh admissionlms:2026.11.10-abc1234
./scripts/build-image.sh --push
IMAGE_TAG=2026.11.10-abc1234 docker compose -f docker-compose.prod.yml up -d
```

Rollback berarti menjalankan perintah terakhir dengan tag yang lebih lama.

Perubahan skema produksi tidak dijalankan lewat `prisma migrate`. Tulis skrip SQL
delta di `server/prisma/deltas/` dan jalankan lebih dulu sebelum menaikkan versi.

## Dokumen keputusan

- [ADR-001](docs/adr/001-deploy-image-tunggal-bertag-versi.md) deploy satu image bertag versi
- [ADR-002](docs/adr/002-migrasi-skema-produksi-dengan-skrip-sql-delta.md) migrasi produksi dengan skrip SQL delta

Aturan harian untuk Claude Code ada di [CLAUDE.md](CLAUDE.md).
# admissionlms
