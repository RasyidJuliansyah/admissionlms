---
artifact: adr
version: "1.0"
created: 2026-11-10
status: accepted
---

# ADR-001: Deploy sebagai satu image Docker bertag versi

## Status

Accepted

**Date:** 2026-11-10
**Deciders:** Rasyid (Product), tim techdev

## Context

AdmissionLMS memakai Vue 3 dan Vuetify di sisi frontend, sedangkan backend ditulis
dengan TypeScript di atas Prisma dan MySQL. Keduanya dijalankan di server lewat Docker.

Cara deploy yang ingin ditinggalkan adalah menyalin hasil build ke server lalu menimpa
berkas versi yang sedang berjalan. Pola itu menyimpan dua persoalan. Pertama, versi lama
hilang begitu disalin, sehingga tidak ada jalan cepat kembali jika rilis baru bermasalah
di produksi. Kedua, frontend dan backend dapat tersalin pada waktu yang berbeda, dan
kombinasi versi yang akhirnya berjalan di server bisa saja belum pernah diuji bersama.

Techdev meminta setiap deploy diperlakukan sebagai satu kesatuan antara backend dan
frontend. Permintaan itu menutup persoalan kedua secara langsung, dan membuka jalan
untuk menutup persoalan pertama lewat penomoran versi pada artefak deploy.

## Decision

Kami akan membangun satu image Docker per deploy yang memuat backend dan frontend
sekaligus. Frontend dibangun lebih dahulu menjadi berkas statis pada stage terpisah,
hasilnya disalin ke stage backend, dan backend yang menyajikannya ke pengguna.

Setiap image diberi tag berisi tanggal build dan tujuh karakter pertama commit SHA,
dengan bentuk `YYYY.MM.DD-<sha>`, misalnya `2026.11.10-fd97829`. Tag `latest` boleh ada
untuk kemudahan, tetapi tidak dipakai sebagai acuan deploy, sebab tag itu berpindah dan
menghapus jejak versi yang sebenarnya berjalan.

Deploy berarti menjalankan image dengan tag tertentu. Rollback berarti menjalankan image
dengan tag yang lebih lama. Berkas di server tidak pernah ditimpa.

Yang belum termasuk di dalam keputusan ini: pilihan registry, kebijakan retensi image
lama, dan cara menjalankan migrasi database. Ketiganya perlu keputusan sendiri.

## Consequences

### Positive

- Rollback cukup dengan menjalankan tag sebelumnya, tanpa build ulang dan tanpa menunggu
  perbaikan kode.
- Tiap tag dapat dilacak ke commit persisnya, sehingga pertanyaan "versi mana yang
  sedang jalan" terjawab dari nama tag saja.
- Tanggal di depan tag membuat urutan rilis langsung terbaca, termasuk ketika ada
  beberapa deploy dalam satu hari.
- Kombinasi backend dan frontend yang berjalan di produksi selalu kombinasi yang sudah
  dibangun dan diuji bersama.

### Negative

- Perubahan kecil di frontend, bahkan sebatas teks, tetap memicu build ulang seluruh
  image dan deploy ulang backend.
- Waktu build menjadi lebih lama daripada membangun salah satu sisi saja, karena kedua
  stage dijalankan setiap kali.
- Backend dan frontend tidak dapat diberi jumlah instance yang berbeda, sebab keduanya
  berada di dalam satu proses yang sama.
- Ukuran image bertambah, dan penyimpanan registry akan tumbuh lebih cepat.

### Neutral

- Registry perlu disiapkan sebelum pola ini dapat dipakai, baik registry publik maupun
  yang dipasang sendiri.
- Image lama perlu kebijakan retensi, karena menyimpan semuanya tanpa batas akan
  menghabiskan ruang disk.
- Migrasi skema Prisma tidak ikut kembali ketika image dikembalikan ke tag lama.
  Rollback image dengan sendirinya tidak mengembalikan struktur tabel, dan hal ini perlu
  ditangani pada keputusan tersendiri tentang migrasi.

## Alternatives Considered

### Dua image terpisah dengan satu tag rilis

Backend dan frontend dibangun menjadi image masing-masing, lalu dideploy bersama dengan
tag versi yang sama melalui satu berkas compose. Frontend disajikan Nginx.

Pilihan ini memungkinkan kedua sisi diberi jumlah instance yang berbeda dan membuat build
frontend tidak menyeret backend. Tidak dipilih karena menambah satu komponen yang harus
dikelola sejak awal, sedangkan ukuran AdmissionLMS saat ini belum menuntut penskalaan
terpisah. Jika beban frontend dan backend nanti terbukti berbeda jauh, ADR ini dapat
ditinjau ulang.

### Menyalin berkas hasil build ke server

Pola yang sedang dipakai. Tidak dipilih karena keduanya persoalan yang disebut pada
bagian Context, yaitu hilangnya versi lama dan kemungkinan kombinasi versi yang belum
teruji.

### Tag dengan commit SHA saja

Tag berisi SHA tanpa tanggal, misalnya `fd97829`. Cukup untuk pelacakan, tetapi urutan
rilis tidak terbaca dari nama tag, sehingga menentukan mana yang lebih baru menuntut
pemeriksaan ke riwayat git.

## References

- `CLAUDE.md`, bagian Tech stack dan Perintah
- Keputusan primary key dan tipe kolom uang pada commit `fd97829`
