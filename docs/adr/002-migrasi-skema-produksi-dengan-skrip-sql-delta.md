---
artifact: adr
version: "1.0"
created: 2026-11-10
status: accepted
---

# ADR-002: Migrasi skema produksi dengan skrip SQL delta manual

## Status

Accepted

**Date:** 2026-11-10
**Deciders:** Rasyid (Product), tim techdev

## Context

ADR-001 menetapkan deploy sebagai satu image Docker bertag versi, dengan rollback
dilakukan lewat menjalankan tag yang lebih lama. Pada bagian Consequences ADR itu
tercatat satu lubang yang belum tertutup: rollback image tidak mengembalikan struktur
tabel. Image lama dapat berakhir berjalan di atas skema yang sudah berubah.

Tim techdev sudah memakai aturan untuk proyek Skolla BSC & OKR Suite, yaitu melarang
`prisma migrate` dan `prisma db push` menyentuh MySQL produksi. Setiap perubahan skema
ditulis sebagai skrip SQL delta idempotent dan dijalankan lewat klien basis data.
Spesifikasi proyek itu menyebutnya aturan mutlak.

Pertanyaannya, apakah AdmissionLMS mengikuti aturan yang sama atau memakai
`prisma migrate deploy` sebagai bagian dari rilis.

## Decision

Kami akan mengikuti aturan yang sama dengan proyek OKR.

Perubahan skema produksi dilakukan lewat skrip SQL delta yang ditulis tangan, disimpan
di `server/prisma/deltas/` dengan nama `YYYYMMDD-<deskripsi>.sql`, dan dijalankan oleh
operator lewat klien basis data. Skrip ditulis idempotent, sehingga menjalankannya dua
kali tidak menimbulkan kerusakan.

`schema.prisma` tetap diperbarui pada commit yang sama, supaya Prisma Client yang
dihasilkan tetap sejalan dengan struktur tabel yang sebenarnya.

Setiap delta wajib kompatibel mundur terhadap satu rilis sebelumnya. Kolom baru
ditambahkan sebagai nullable atau dengan nilai default. Penghapusan kolom dan penggantian
nama dipecah menjadi dua rilis yang terpisah, yaitu rilis yang berhenti memakai kolom itu
lebih dahulu, lalu rilis berikutnya yang menghapusnya.

Urutan rilis menjadi: jalankan delta SQL, pastikan berhasil, baru jalankan image dengan
tag baru.

Di mesin lokal, `prisma db push` tetap boleh dipakai untuk iterasi cepat ke MySQL Docker.
`prisma migrate dev` tidak dipakai, supaya tidak ada folder `migrations/` yang menyimpan
riwayat berbeda dari delta produksi.

## Consequences

### Positive

- Rollback image menjadi aman, sebab skema baru tetap dapat dibaca oleh image satu versi
  sebelumnya. Ini menutup lubang yang tercatat di ADR-001.
- Setiap perubahan struktur tabel dibaca manusia sebelum dijalankan, sehingga perintah
  yang berbahaya seperti `DROP COLUMN` tidak lolos tanpa disadari.
- Jalur rilis AdmissionLMS sama dengan proyek OKR, sehingga operator tidak perlu
  mengingat dua prosedur berbeda.
- Delta tersimpan di repositori sebagai berkas, jadi riwayat perubahan skema tetap dapat
  ditelusuri lewat git.

### Negative

- Skema lokal dan skema produksi dapat berbeda tanpa ketahuan, sebab delta ditulis tangan
  dan tidak dihasilkan dari `schema.prisma`. Perbedaan baru terasa ketika kueri gagal di
  produksi.
- Menulis delta menambah pekerjaan manual pada setiap perubahan model, termasuk perubahan
  kecil seperti menambah satu kolom.
- Rilis tidak lagi satu langkah. Ada langkah manual sebelum deploy yang tidak dapat
  dijalankan otomatis oleh CI.
- Aturan kompatibel mundur memaksa penghapusan kolom dipecah menjadi dua rilis, sehingga
  pembersihan kolom lama cenderung tertunda lama.

### Neutral

- Perubahan nilai pada tipe `enum` Prisma ikut menuntut delta `ALTER TABLE`, sama seperti
  perubahan kolom lainnya. Hal ini perlu diingat saat menimbang pemakaian `enum`
  dibanding `String` untuk kolom berstatus.
- Perlu satu skrip pembanding yang memeriksa apakah struktur tabel produksi masih cocok
  dengan `schema.prisma`. Skrip itu belum ada dan menjadi pekerjaan tersendiri.

## Alternatives Considered

### `prisma migrate deploy` sebagai bagian rilis

Migrasi dihasilkan Prisma dan dijalankan otomatis saat container backend mulai. Lebih
sedikit pekerjaan manual, dan skema lokal dijamin sama dengan produksi.

Tidak dipilih karena bertentangan dengan standar techdev yang sudah berjalan, dan karena
migrasi otomatis saat startup berbahaya pada pola ADR-001. Container yang gagal bermigrasi
akan menghalangi rollback.

### Menjalankan delta otomatis dari CI

Skrip delta tetap ditulis tangan, tetapi dijalankan CI, bukan operator. Menghapus langkah
manual tanpa kehilangan kendali atas isi skrip. Belum dipilih karena CI untuk AdmissionLMS
belum ada. Layak ditinjau ulang setelah CI berjalan.

## References

- `docs/adr/001-deploy-image-tunggal-bertag-versi.md`
- `PROJECT_ARCHITECTURE_SPEC.md` proyek Skolla BSC & OKR Suite, bagian 2.3
