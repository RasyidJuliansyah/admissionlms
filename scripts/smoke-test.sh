#!/usr/bin/env bash
#
# Menjalankan image lalu memeriksa tiga hal: endpoint health, query Prisma ke
# database, dan fallback rute SPA. Dipakai setelah membangun image, terutama
# setelah menaikkan versi Prisma, sebab Dockerfile memangkas sebagian node_modules.
#
# Pemakaian:
#   ./scripts/smoke-test.sh admissionlms:2026.11.10-abc1234

set -euo pipefail

IMAGE="${1:?Sebutkan image yang mau diuji, misalnya admissionlms:uji}"
PORT="${SMOKE_PORT:-3402}"
NAME="admissionlms-smoke"
DB="${DATABASE_URL:-mysql://admission:admission@host.docker.internal:3307/admissionlms}"

cleanup() { docker rm -f "${NAME}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

cleanup
docker run -d --name "${NAME}" -p "${PORT}:3001" -e DATABASE_URL="${DB}" "${IMAGE}" >/dev/null

for _ in $(seq 1 30); do
  curl -sf "localhost:${PORT}/api/health" >/dev/null 2>&1 && break
  if [[ "$(docker inspect -f '{{.State.Running}}' "${NAME}")" != "true" ]]; then
    echo "GAGAL: container berhenti sebelum siap." >&2
    docker logs "${NAME}" 2>&1 | tail -20 >&2
    exit 1
  fi
  sleep 1
done

fail=0

echo "health      : $(curl -s "localhost:${PORT}/api/health")"

count_code=$(curl -s -o /tmp/smoke-count -w '%{http_code}' "localhost:${PORT}/api/applicants/count")
echo "prisma      : ${count_code} $(cat /tmp/smoke-count)"
[[ "${count_code}" == "200" ]] || { echo "  -> query Prisma gagal" >&2; fail=1; }

root_code=$(curl -s -o /dev/null -w '%{http_code}' "localhost:${PORT}/")
deep_code=$(curl -s -o /dev/null -w '%{http_code}' "localhost:${PORT}/pendaftaran")
echo "spa         : root ${root_code}, rute dalam ${deep_code}"
[[ "${root_code}" == "200" && "${deep_code}" == "200" ]] || { echo "  -> SPA tidak tersaji" >&2; fail=1; }

echo "ukuran      : $(docker images --format '{{.Size}}' "${IMAGE}" | head -1)"

if [[ "${fail}" -eq 0 ]]; then
  echo
  echo "Semua pemeriksaan lolos."
else
  echo
  echo "Ada pemeriksaan yang gagal." >&2
  exit 1
fi
