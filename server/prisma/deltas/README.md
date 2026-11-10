# Skrip SQL delta

Setiap perubahan skema produksi ditulis di sini sebagai satu berkas `.sql`, dengan nama
`YYYYMMDD-<deskripsi>.sql`, misalnya `20261115-tambah-kolom-nomor-pendaftaran.sql`.

Aturannya ada di `docs/adr/002-migrasi-skema-produksi-dengan-skrip-sql-delta.md`.
Ringkasnya:

- Skrip harus idempotent. Menjalankannya dua kali tidak boleh merusak apa pun.
- Skrip harus kompatibel mundur satu rilis. Kolom baru dibuat nullable atau diberi
  default, sehingga image versi sebelumnya tetap dapat berjalan di atas skema ini.
- `DROP COLUMN` dan penggantian nama kolom tidak boleh berada di rilis yang sama dengan
  kode yang berhenti memakainya. Pecah jadi dua rilis.
- Perbarui `schema.prisma` pada commit yang sama.
