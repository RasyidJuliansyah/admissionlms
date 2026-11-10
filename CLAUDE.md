# AdmissionLMS

> Memori proyek untuk Claude Code. Jaga di bawah ±200 baris. Kalau ada detail panjang, taruh di `docs/` lalu tautkan ke sini, jangan disalin.

## Ringkasan
- Tujuan produk: _isi satu kalimat_
- Pengguna utama: _isi_
- Status: MVP

## Tech stack & arsitektur
- Frontend: Vue 3 + Vuetify, utility class dari Tailwind CSS, Vue Router, Pinia.
  Dibangun dengan Vite jadi SPA statis, tanpa SSR.
- Backend: Express 5 + TypeScript, Prisma 7. Modul dipisah per domain ke dalam
  `routes/`, `controllers/`, `services/`, dan `middleware/`.
- Database: MySQL 8, dijalankan lewat Docker di mesin lokal.
- Monorepo npm workspaces dengan dua paket:
  - `client/` frontend Vite. Komponen di `src/components/` per fitur, halaman di
    `src/pages/`, rute di `src/router/`, store Pinia di `src/stores/`.
  - `server/` backend Express. Skema dan skrip delta di `server/prisma/`.
  - `tests/e2e/` menguji keduanya sekaligus, jadi tetap di root.
- Prisma 7 memakai driver adapter (`@prisma/adapter-mariadb`), bukan engine biner.
  Connection string ada di `server/prisma.config.ts`, tidak lagi di `schema.prisma`.
- Detail arsitektur: lihat `docs/architecture.md`

## Perintah
- Install: `npm install` (package manager proyek ini npm, jangan pakai pnpm atau yarn)
- Jalankan dev: `npm run dev` (client di :5173, server di :3001, `/api` diproxy)
- Database lokal: `docker compose up -d` lalu `npm run db:push` (MySQL di port 3307,
  bukan 3306, supaya tidak bentrok dengan MySQL lain di mesin ini)
- Prisma client: `npm run db:generate`
- Build: `npm run build`
- Cek tipe: `npm run typecheck`
- Bangun image rilis: `./scripts/build-image.sh`
- Uji image: `./scripts/smoke-test.sh <image>` (wajib dijalankan setelah menaikkan
  versi Prisma, sebab Dockerfile memangkas sebagian node_modules)
- Tes: belum ada. Tambahkan perintahnya di sini begitu test runner dipilih.
- Lint/format: belum ada.

## Konvensi kode
- Satu file satu tanggung jawab. File yang sudah ratusan baris dipecah.
- Penamaan: camelCase untuk fungsi dan variabel, PascalCase untuk komponen Vue,
  snake_case untuk kolom tabel di schema Prisma.
- Vuetify dipakai untuk komponen. Tailwind hanya untuk penyesuaian layout dan spacing,
  bukan untuk menulis ulang komponen Vuetify. Preflight Tailwind sengaja dimatikan di
  `client/src/styles/main.css` supaya resetnya tidak menimpa styling Vuetify.
- Akses database selalu lewat Prisma client di `server/src/services/`, tidak langsung
  dari route handler maupun komponen.
- Primary key tiap tabel memakai auto increment, bukan UUID atau CUID. Di schema Prisma
  bentuknya `id Int @id @default(autoincrement())`. Pakai `Int` untuk semua tabel.
- Kolom uang memakai `Decimal` dengan dua angka di belakang koma, karena nominalnya bisa
  sampai satuan sen. Bentuknya `Decimal @db.Decimal(14, 2)`. Jangan pakai `Float` atau
  `Double` untuk uang, sebab keduanya menimbulkan galat pembulatan.
- Error ditangani di layer service, bukan di komponen UI.

## Testing
- Setiap fitur baru datang bersama tes dasarnya di `tests/unit/`.
- Bug diperbaiki dengan menulis tes yang gagal dulu.
- Alur kritis (login, simpan data) punya tes di `tests/e2e/`.

## Deploy
- Satu deploy sama dengan satu image Docker yang memuat backend dan frontend sekaligus.
  Frontend dibangun jadi berkas statis di stage terpisah, lalu disalin ke stage backend.
- Tag image berbentuk `YYYY.MM.DD-<7 karakter commit SHA>`, misalnya `2026.11.10-fd97829`.
- Jangan deploy memakai tag `latest`. Tag itu berpindah, sehingga jejak versi yang
  sedang berjalan ikut hilang.
- Rollback dilakukan dengan menjalankan tag yang lebih lama. Berkas di server tidak
  pernah ditimpa.
- Urutan rilis: jalankan skrip SQL delta dulu, pastikan berhasil, baru jalankan image
  dengan tag baru.
- Alasan lengkapnya ada di `docs/adr/001-deploy-image-tunggal-bertag-versi.md`.

## Migrasi database
- Jangan pernah menjalankan `prisma migrate deploy`, `prisma migrate dev`, atau
  `prisma db push` ke MySQL produksi.
- Perubahan skema produksi ditulis sebagai skrip SQL delta idempotent di
  `server/prisma/deltas/`, dengan nama `YYYYMMDD-<deskripsi>.sql`, lalu dijalankan
  operator lewat klien basis data.
- `schema.prisma` tetap diperbarui pada commit yang sama agar Prisma Client sinkron.
- Tiap delta wajib kompatibel mundur satu rilis. Kolom baru dibuat nullable atau diberi
  default. Hapus kolom dan ganti nama dipecah jadi dua rilis terpisah.
- Di mesin lokal pakai `npx prisma db push` ke MySQL Docker. Jangan pakai
  `prisma migrate dev`, supaya tidak ada folder `migrations/` yang riwayatnya berbeda
  dari delta produksi.
- Alasan lengkapnya ada di `docs/adr/002-migrasi-skema-produksi-dengan-skrip-sql-delta.md`.

## Git workflow
- Branch: `feat/<nama>`, `fix/<nama>`, `chore/<nama>`
- Commit kecil setelah setiap tugas yang lolos tes. Format: `feat(scope): deskripsi`
- Jangan push ke `main` tanpa review.

## Keamanan
- Rahasia hanya di `.env` (tidak di-commit). Contoh variabel ada di `.env.example`.
- Jangan pernah menulis API key, password, atau token di file ini.

## Jangan lakukan
- Jangan menambah dependency baru tanpa menyebutkan alasannya.
- Jangan mengubah file di `docs/` tanpa diminta.
