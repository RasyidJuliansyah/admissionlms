# syntax=docker/dockerfile:1
#
# Satu image memuat backend dan frontend sekaligus, sesuai ADR-001.
# Frontend dibangun jadi berkas statis pada stage build, lalu disalin ke stage
# runtime dan disajikan Express.
#
# Build lewat scripts/build-image.sh supaya tag versinya konsisten.

ARG NODE_VERSION=22-alpine

# --- Stage 1: dependency lengkap, termasuk devDependencies ---------------------
FROM node:${NODE_VERSION} AS deps
WORKDIR /app
COPY package.json package-lock.json ./
COPY client/package.json client/
COPY server/package.json server/
RUN npm ci

# --- Stage 2: generate Prisma Client lalu build client dan server --------------
FROM node:${NODE_VERSION} AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run db:generate && npm run build

# --- Stage 3: dependency produksi saja -----------------------------------------
# devDependencies ditinggal di sini. Vue, Vite, Vuetify, dan Tailwind hanya dipakai
# saat build, jadi tidak ikut ke image akhir.
FROM node:${NODE_VERSION} AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
COPY client/package.json client/
COPY server/package.json server/
RUN npm ci --omit=dev --workspace=server --include-workspace-root

# Prisma Client hasil generate ditimpakan ke paket yang baru dipasang, sebab
# npm ci memasang versi yang belum digenerate. Kode hasil generate sendiri ada di
# node_modules/.prisma, dan @prisma/client hanya meneruskan ke sana, jadi keduanya
# wajib ikut tersalin.
COPY --from=build /app/node_modules/@prisma/client ./node_modules/@prisma/client
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma

# @prisma/client mendeklarasikan `prisma` sebagai peer dependency, dan npm
# memperlakukan peer dari dependency produksi sebagai produksi juga. Akibatnya CLI
# Prisma, Prisma Studio, dan engine Rust ikut terbawa walaupun sudah --omit=dev.
# Tidak satu pun dipakai saat runtime, sebab koneksi ditangani driver adapter.
# Memangkasnya menurunkan image dari sekitar 734MB menjadi sekitar 400MB.
#
# Kalau suatu saat smoke test `GET /api/applicants/count` gagal setelah menaikkan
# versi Prisma, daftar di bawah inilah yang pertama harus diperiksa.
RUN rm -rf \
      node_modules/prisma \
      node_modules/@prisma/studio-core \
      node_modules/@prisma/dev \
      node_modules/@prisma/engines \
      node_modules/@prisma/fetch-engine \
      node_modules/@prisma/config \
      node_modules/typescript \
      node_modules/esbuild \
      node_modules/effect \
      node_modules/@electric-sql \
      node_modules/react \
      node_modules/react-dom \
      node_modules/elkjs

# --- Stage 4: runtime ----------------------------------------------------------
FROM node:${NODE_VERSION} AS runtime
WORKDIR /app

ARG APP_VERSION=dev
ENV NODE_ENV=production \
    APP_VERSION=${APP_VERSION} \
    PORT=3001 \
    CLIENT_DIST=/app/client/dist

COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=prod-deps /app/package.json ./package.json
COPY --from=build /app/server/dist ./server/dist
COPY --from=build /app/server/package.json ./server/package.json
COPY --from=build /app/server/prisma ./server/prisma
COPY --from=build /app/client/dist ./client/dist

# Jalankan sebagai pengguna tanpa hak akses root. User "node" sudah ada di image resmi.
USER node

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3001)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server/dist/index.js"]
