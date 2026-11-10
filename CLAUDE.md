# AdmissionLMS

> Memori proyek untuk Claude Code. Jaga di bawah ±200 baris. Kalau ada detail panjang, taruh di `docs/` lalu tautkan ke sini, jangan disalin.

## Ringkasan
- Tujuan produk: _isi satu kalimat_
- Pengguna utama: _isi_
- Status: MVP / beta / produksi

## Tech stack & arsitektur
- Bahasa/framework: _isi (mis. TypeScript + Next.js)_
- Database: _isi_
- Struktur folder utama:
  - `src/components/` komponen UI, dikelompokkan per fitur (`auth/`, `dashboard/`, `shared/`)
  - `src/services/` akses API, auth, database
  - `src/utils/` helper murni tanpa side effect
  - `src/types/` definisi tipe bersama
- Detail arsitektur: lihat `docs/architecture.md`

## Perintah
- Install: `_isi_`
- Jalankan dev: `_isi_`
- Tes: `_isi_`
- Lint/format: `_isi_`

## Konvensi kode
- Satu file satu tanggung jawab. File yang sudah ratusan baris dipecah.
- Penamaan: _isi (camelCase untuk fungsi, PascalCase untuk komponen, dst.)_
- Error ditangani di layer service, bukan di komponen UI.

## Testing
- Setiap fitur baru datang bersama tes dasarnya di `tests/unit/`.
- Bug diperbaiki dengan menulis tes yang gagal dulu.
- Alur kritis (login, simpan data) punya tes di `tests/e2e/`.

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
