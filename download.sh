#! /bin/bash
set -euo pipefail

BASEURL=https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release
FILES=(pfamseq.{txt,sql}.gz)

function get_pfam_current_release {
  curl -s "${BASEURL}/relnotes.txt" |
    sed -n '2s/\s\+RELEASE\s\(.*\)\s*/\1/p'
}

# Get current release
VERSION="$(get_pfam_current_release)"
if [ -z "${VERSION}" ]; then
  echo Failed to get latest Pfam release version number. Exiting.
  exit 3
fi

mkdir -p "pfam_${VERSION}"
pushd "pfam_${VERSION}" > /dev/null

curl --retry-all-errors -O -C - "${BASEURL}/userman.txt"
for FILE in "${FILES[@]}"; do
  curl --retry-all-errors -O -C - "${BASEURL}/database_files/${FILE}"
done

popd > /dev/null
