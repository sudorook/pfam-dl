#! /bin/bash
set -euo pipefail

ROOT="$(readlink -f "$(dirname "${0}")")"

source "${ROOT}"/globals

! check_command awk && exit 3

if command -v pigz > /dev/null; then
  GZIP=pigz
elif command -v gzip > /dev/null; then
  GZIP=gzip
else
  show_error ERROR: No gzip compression tool found. Exiting.
  exit 3
fi

# Get current release
VERSION="$(get_pfam_current_release)"
if [ -z "${VERSION}" ]; then
  show_error ERROR: Failed to get latest Pfam release version number. Exiting.
  exit 3
fi

if ! [ -d "pfam_${VERSION}" ]; then
  show_error ERROR: Data directory not found. Exiting.
  exit 3
fi

pushd "pfam_${VERSION}" > /dev/null

for FILE in "${FILES[@]}"; do
  if [ "${FILE##*.}" = gz ]; then
    if ! [ -f "${FILE%.*}" ]; then
      if [ -f "${FILE}" ]; then
        "${GZIP}" -dkv "${FILE}"
      else
        show_error "ERROR: ${FILE@Q} missing. Exiting."
        exit 3
      fi
    fi
  fi
done

git submodule init
git submodule update

for FILE in *.sql; do
  show_info "Converting ${FILE@Q} MySQL dump to SQLite3."
  "${ROOT}"/mysql2sqlite/mysql2sqlite "${FILE}" | sqlite3 "${FILE%.*}.db"
  if [ -f "${FILE%.*}.txt" ]; then
    sqlite3 -batch "${FILE%.*}.db" << EOF
.separator "\t"
.import "${FILE%.*}.txt" "${FILE%.*}"
EOF
  fi
done

popd > /dev/null
