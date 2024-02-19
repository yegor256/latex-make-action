#!/bin/bash
# MIT License
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -x
set -e
set -o pipefail

cd "${GITHUB_WORKSPACE-/w}"

tlmgr option repository ctan
tlmgr --verify-repo=none update --self

read -r -a packages <<< "${INPUT_PACKAGES}"
if [ -n "${INPUT_DEPENDS}" ]; then
    while IFS= read -r p; do
        packages+=( "${p}" )
    done < <( cut -d' ' -f2 "${INPUT_DEPENDS}" | uniq )
fi

if [ ! "${#packages[@]}" -eq 0 ]; then
    tlmgr --verify-repo=none install "${packages[@]}"
    tlmgr --verify-repo=none --no-auto-remove update "${packages[@]}" || echo 'UPDATE FAILED'
fi

cd "${INPUT_PATH-.}"
ls -al

read -r -a opts <<< "${INPUT_OPTS}"
${INPUT_CMD} "${opts[@]}"
