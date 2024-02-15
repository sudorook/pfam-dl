#! /bin/bash
set -euo pipefail

ROOT="$(readlink -f "$(dirname "${0}")")"

source "${ROOT}"/globals

BASEURL=https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release
FILES=(pfamseq.{txt,sql}.gz)

function get_pfam_current_release {
  curl -s "${BASEURL}/relnotes.txt" |
    sed -n '2s/\s\+RELEASE\s\(.*\)\s*/\1/p'
}

function curl_dl {
  curl --retry-all-errors --connect-timeout 60 --retry 10 -O -C - "${1}"
}

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
