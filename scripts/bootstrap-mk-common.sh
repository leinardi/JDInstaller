#!/usr/bin/env bash
set -euo pipefail

MK_REPO="${1:?MK repo (e.g. leinardi/make-common) required}"
VERSION="${2:?version (e.g. v1.2.0 or latest) required}"
MK_DIR="${3:?target .mk directory required}"
FILES="${4:?list of .mk files required}"

# Mode: normal bootstrap vs update
MK_UPDATE_MODE="${MK_COMMON_UPDATE:-0}"

# Resolve repo root (so Makefile can live anywhere in the repo)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

SCRIPT_PATH="${REPO_ROOT}/scripts/bootstrap-mk-common.sh"

# Normalise MK_DIR and derive version file
MK_DIR="${MK_DIR%/}"
MK_VERSION_FILE="${MK_DIR}/.mk-common-version"
EXPECTED="${MK_REPO}@${VERSION}"

NEED_REFRESH=0
STORED_EXPECTED=""
STORED_SHA=""
REMOTE_SHA=""

# Read existing version file, if any: format "<repo>@<version> [sha]"
if [[ -f "${MK_VERSION_FILE}" ]]; then
  IFS=' ' read -r STORED_EXPECTED STORED_SHA < "${MK_VERSION_FILE}" || true
fi

if [[ "${MK_UPDATE_MODE}" = "1" ]]; then
  # ---------------------------------------------------------------------------
  # UPDATE MODE: go online, compare remote SHA, refresh only if changed
  # ---------------------------------------------------------------------------
  REMOTE_URL="https://github.com/${MK_REPO}.git"
  REMOTE_SHA="$(git ls-remote "${REMOTE_URL}" "${VERSION}" 2>/dev/null | awk 'NR==1 {print $1}')"

  if [[ -z "${REMOTE_SHA}" ]]; then
    echo "[mk] ERROR: could not resolve '${VERSION}' in ${REMOTE_URL}" >&2
    echo "[mk]        Check MK_COMMON_VERSION or your network connection." >&2
    exit 1
  fi

  # Decide if we need to refresh:
  # - tag name changed
  # - or no stored SHA (first time / old format)
  # - or stored SHA != remote SHA (mutable tag/branch moved)
  if [[ "${STORED_EXPECTED}" != "${EXPECTED}" ]] \
     || [[ -z "${STORED_SHA}" ]] \
     || [[ "${STORED_SHA}" != "${REMOTE_SHA}" ]]; then
    NEED_REFRESH=1
  fi

  if [[ "${NEED_REFRESH}" -eq 0 ]]; then
    echo "[mk] Shared makefiles already up to date for ${EXPECTED} (${REMOTE_SHA})" >&2
    exit 0
  fi
else
  # ---------------------------------------------------------------------------
  # NORMAL MODE: only compare tag string + ensure files exist
  # ---------------------------------------------------------------------------
  if [[ -z "${STORED_EXPECTED}" ]] || [[ "${STORED_EXPECTED}" != "${EXPECTED}" ]]; then
    NEED_REFRESH=1
  fi

  # Also refresh if any requested .mk file is missing
  if [[ "${NEED_REFRESH}" -eq 0 ]]; then
    for f in ${FILES}; do
      if [[ ! -f "${MK_DIR}/${f}" ]]; then
        NEED_REFRESH=1
        break
      fi
    done
  fi
fi

# ---------------------------------------------------------------------------
# Refresh: update script + .mk files, write version file, re-exec
# ---------------------------------------------------------------------------

if [[ "${NEED_REFRESH}" -eq 1 ]]; then
  echo "[mk] Updating bootstrap-mk-common.sh and .mk files from ${MK_REPO}@${VERSION}" >&2
  mkdir -p "${REPO_ROOT}/scripts" "${MK_DIR}"

  # If we don't already know REMOTE_SHA (normal mode), resolve it now.
  # This only happens when we are *already* going online to download files.
  if [[ -z "${REMOTE_SHA}" ]]; then
    REMOTE_URL="https://github.com/${MK_REPO}.git"
    REMOTE_SHA="$(git ls-remote "${REMOTE_URL}" "${VERSION}" 2>/dev/null | awk 'NR==1 {print $1}')"
    if [[ -z "${REMOTE_SHA}" ]]; then
      echo "[mk] WARNING: could not resolve SHA for ${EXPECTED};" \
           "version file will not contain a SHA." >&2
    fi
  fi

  # Fetch the script itself from the tagged ref
  curl -fsSL \
    "https://raw.githubusercontent.com/${MK_REPO}/${VERSION}/scripts/bootstrap-mk-common.sh" \
    -o "${SCRIPT_PATH}"
  chmod +x "${SCRIPT_PATH}"

  # Fetch all requested .mk files
  for f in ${FILES}; do
    echo "[mk] Fetching ${f} from ${MK_REPO}@${VERSION}" >&2
    curl -fsSL \
      "https://raw.githubusercontent.com/${MK_REPO}/${VERSION}/.mk/${f}" \
      -o "${MK_DIR}/${f}"
  done

  # Store "<repo>@<version> <sha>" (sha may be empty only if resolution failed)
  if [[ -n "${REMOTE_SHA}" ]]; then
    printf '%s %s\n' "${EXPECTED}" "${REMOTE_SHA}" > "${MK_VERSION_FILE}"
  else
    printf '%s\n' "${EXPECTED}" > "${MK_VERSION_FILE}"
  fi

  # Re-exec the freshly downloaded script so any new logic applies immediately
  exec "${SCRIPT_PATH}" "$@"
fi

# If we reach here in normal mode, script + .mk files are already up to date.
# Nothing else to do; Make just needed us for our side effects.
