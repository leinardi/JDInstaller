#!/bin/bash
#
# Copyright 2024 Roberto Leinardi.
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


# Installs uv, which `make` uses to run a pinned ansible-core (see .mk/ansible.mk), so the machine
# needs no Ansible of its own. uv goes to ~/.local/bin with Astral's standalone installer; the
# Makefile puts that directory on PATH, so no shell profile is changed.

# Enable bash strict mode
set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo "Run this script as your own user, not as root: uv is installed into your home directory." >&2
  exit 1
fi

if command -v uv >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/uv" ]]; then
  echo "uv is already installed."
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

echo "Installing uv into ${HOME}/.local/bin..."
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="${HOME}/.local/bin" UV_NO_MODIFY_PATH=1 sh
