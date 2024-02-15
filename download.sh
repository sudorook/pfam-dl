#! /bin/bash
set -euo pipefail

ROOT="$(readlink -f "$(dirname "${0}")")"

source "${ROOT}"/globals

! check_command curl sed && exit 3

# Get current release
VERSION="$(get_pfam_current_release)"
if [ -z "${VERSION}" ]; then
  show_error Failed to get latest Pfam release version number. Exiting.
  exit 3
fi

mkdir -p "pfam_${VERSION}"
pushd "pfam_${VERSION}" > /dev/null

curl_dl "${BASEURL}/userman.txt"
for FILE in "${FILES[@]}"; do
  curl_dl "${BASEURL}/database_files/${FILE}"
done

popd > /dev/null
