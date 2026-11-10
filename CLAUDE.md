# AdmissionLMS

> Memori proyek untuk Claude Code. Jaga di bawah ±200 baris. Kalau ada detail panjang, taruh di `docs/` lalu tautkan ke sini, jangan disalin.

## Ringkasan
- Tujuan produk: _isi satu kalimat_
- Pengguna utama: _isi_
- Status: MVP

## Tech stack & arsitektur
- Frontend: Vue 3 + Vuetify, utility class dari Tailwind CSS
- Backend: TypeScript, ORM Prisma
- Database: MySQL, dijalankan lewat Docker di mesin lokal
- Struktur folder utama:
  - `src/components/` komponen UI, dikelompokkan per fitur (`auth/`, `dashboard/`, `shared/`)
  - `src/services/` akses API, auth, database
  - `src/utils/` helper murni tanpa side effect
  - `src/types/` definisi tipe bersama
- Detail arsitektur: lihat `docs/architecture.md`

## Perintah
- Install: `npm install` (package manager proyek ini npm, jangan pakai pnpm atau yarn)
- Jalankan dev: `_isi_`
- Database lokal: `docker compose up -d` lalu `npx prisma migrate dev`
- Prisma client: `npx prisma generate`
- Tes: `_isi_`
- Lint/format: `_isi_`

Perintah yang masih `_isi_` menunggu package.json diisi. Jangan dikarang sebelum
skripnya benar-benar ada.

## Konvensi kode
- Satu file satu tanggung jawab. File yang sudah ratusan baris dipecah.
- Penamaan: camelCase untuk fungsi dan variabel, PascalCase untuk komponen Vue,
  snake_case untuk kolom tabel di schema Prisma.
- Vuetify dipakai untuk komponen. Tailwind hanya untuk penyesuaian layout dan spacing,
  bukan untuk menulis ulang komponen Vuetify.
- Akses database selalu lewat Prisma client di `src/services/`, tidak langsung dari
  komponen.
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
- Migrasi Prisma tidak ikut kembali saat rollback image. Periksa dampaknya sebelum
  mengembalikan versi.
- Alasan lengkapnya ada di `docs/adr/001-deploy-image-tunggal-bertag-versi.md`.

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
