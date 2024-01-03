#!/bin/bash

# SPDX-FileCopyrightText: 2024 sudorook <daemon@nullcodon.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.

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
