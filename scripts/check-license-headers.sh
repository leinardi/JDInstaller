#!/usr/bin/env bash
#
# Copyright 2026 Roberto Leinardi.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# License header checker.
#
# JDInstaller is Apache-2.0-licensed, and every code file says so in its own header. This fails on
# any tracked code file whose first lines do not carry the Apache-2.0 notice with Roberto
# Leinardi's copyright, so a missing header is caught as surely as one copied from another project.
#
# Governed: shell and Python scripts, the Makefile and the repo-local .mk fragments. Never YAML,
# JSON or Markdown: the playbooks, roles, inventory (including inventory/group_vars/all.yaml, which
# generate-group-vars.sh writes) and templates are not code files in this sense. Exempt, each for a
# stated reason: the make-common files the bootstrap fetches (upstream, named in the Makefile's
# MK_COMMON_FILES) and scripts/bootstrap-mk-common.sh, which comes from make-common too.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/check-license-headers.sh

Checks every tracked code file for the Apache-2.0 license header and lists the files that lack it.
Run from anywhere inside the repository.
USAGE
}

if [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
fi

cd "$(git rev-parse --show-toplevel)"

# How many leading lines the header must sit in: a shebang and a comment line may precede it.
HEADER_WINDOW=30

REQUIRED_LINES=(
  "Licensed under the Apache License, Version 2.0 (the \"License\");"
  "you may not use this file except in compliance with the License."
  "https://www.apache.org/licenses/LICENSE-2.0"
  "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
)

# The copyright line names the year (or years) and the author, on one line.
COPYRIGHT_REGEX='Copyright [0-9]{4}([-, ]+[0-9]{4})* Roberto Leinardi\.$'

# Exact paths that are not this repository's own code.
EXEMPT_PATHS=(
  "scripts/bootstrap-mk-common.sh"
)

# The shared make fragments, read from the Makefile so the list cannot drift from what the
# bootstrap actually fetches.
mk_common_files() {
  sed -n 's/^MK_COMMON_FILES[[:space:]]*:=[[:space:]]*//p' Makefile
}

is_governed() {
  local path="$1"

  case "${path}" in
    *.sh | *.bash | *.py | .mk/*.mk | Makefile | */Makefile)
      return 0
      ;;
  esac

  return 1
}

is_exempt() {
  local path="$1" entry

  for entry in "${EXEMPT_PATHS[@]}"; do
    if [[ ${path} == "${entry}" ]]; then
      return 0
    fi
  done

  for entry in ${COMMON_FILES}; do
    if [[ ${path} == ".mk/${entry}" ]]; then
      return 0
    fi
  done

  return 1
}

has_header() {
  local path="$1" head line
  head="$(head -n "${HEADER_WINDOW}" -- "${path}")"

  for line in "${REQUIRED_LINES[@]}"; do
    if [[ ${head} != *"${line}"* ]]; then
      return 1
    fi
  done

  grep -Eq -- "${COPYRIGHT_REGEX}" <<<"${head}"
}

COMMON_FILES="$(mk_common_files)"
if [[ -z ${COMMON_FILES} ]]; then
  echo "Could not read MK_COMMON_FILES from the Makefile." >&2
  exit 1
fi

missing=()
checked=0

while IFS= read -r -d '' path; do
  if ! is_governed "${path}" || is_exempt "${path}"; then
    continue
  fi

  # A tracked file deleted in the working tree is not this check's concern.
  if [[ ! -f ${path} ]]; then
    continue
  fi

  checked=$((checked + 1))

  if ! has_header "${path}"; then
    missing+=("${path}")
  fi
done < <(git ls-files -z)

if [[ ${checked} -eq 0 ]]; then
  echo "No governed files found: the check has nothing to check." >&2
  exit 1
fi

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "These files lack the Apache-2.0 license header:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  echo "Copy the header from any shell script, with the year the file was created." >&2
  exit 1
fi

echo "License headers: ${checked} files checked, all carry the Apache-2.0 header."
