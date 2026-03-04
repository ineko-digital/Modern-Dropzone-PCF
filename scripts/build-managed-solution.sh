#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOLUTION_PROJECT="${ROOT_DIR}/Solution/ModernDropzone/ModernDropzone.cdsproj"
ARTIFACTS_DIR="${ROOT_DIR}/artifacts"

if ! command -v dotnet >/dev/null 2>&1; then
  echo "dotnet SDK is required to build the solution." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to build the PCF control." >&2
  exit 1
fi

mkdir -p "${ARTIFACTS_DIR}"

pushd "${ROOT_DIR}" >/dev/null
npm ci
npm run build

dotnet restore "${SOLUTION_PROJECT}"
dotnet build "${SOLUTION_PROJECT}" \
  -c Release \
  /p:SolutionPackageType=Managed \
  /p:Configuration=Release

find "${ROOT_DIR}/Solution/ModernDropzone/bin/Release" -maxdepth 1 -type f -name '*.zip' -exec cp {} "${ARTIFACTS_DIR}/" \;

popd >/dev/null

echo "Managed solution package(s) copied to: ${ARTIFACTS_DIR}"
