#!/usr/bin/env bash
#
# Membangun image AdmissionLMS dengan tag YYYY.MM.DD-<7 karakter commit SHA>,
# sesuai ADR-001.
#
# Pemakaian:
#   ./scripts/build-image.sh                 # build saja
#   ./scripts/build-image.sh --push          # build lalu push ke registry
#   IMAGE_REGISTRY=ghcr.io/skolla/admissionlms ./scripts/build-image.sh --push

set -euo pipefail

cd "$(dirname "$0")/.."

REGISTRY="${IMAGE_REGISTRY:-admissionlms}"
PUSH=false
[[ "${1:-}" == "--push" ]] && PUSH=true

# Tag harus dapat dilacak ke satu commit. Kalau working tree kotor, isi image tidak
# sama dengan isi commit yang disebut tag, dan pelacakan jadi bohong.
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo "Working tree masih ada perubahan yang belum di-commit." >&2
  echo "Commit dulu, supaya tag image benar-benar menunjuk ke kode yang dibangun." >&2
  git status --short >&2
  exit 1
fi

SHA="$(git rev-parse --short=7 HEAD)"
TAG="$(date +%Y.%m.%d)-${SHA}"
IMAGE="${REGISTRY}:${TAG}"

echo "Membangun ${IMAGE}"

docker build \
  --build-arg "APP_VERSION=${TAG}" \
  --tag "${IMAGE}" \
  .

echo
echo "Selesai: ${IMAGE}"
echo
echo "Jalankan lokal:"
echo "  docker run --rm -p 3001:3001 -e DATABASE_URL=... ${IMAGE}"
echo
echo "Deploy di server:"
echo "  IMAGE_TAG=${TAG} docker compose -f docker-compose.prod.yml up -d"

if [[ "${PUSH}" == true ]]; then
  echo
  echo "Push ${IMAGE}"
  docker push "${IMAGE}"
fi
