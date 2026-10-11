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

# Resolve repository root (Makefile can live anywhere)
SHELL := /bin/bash
REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null || pwd)

MK_COMMON_REPO    ?= leinardi/make-common
MK_COMMON_VERSION ?= v1

MK_COMMON_DIR := $(REPO_ROOT)/.mk

# Shared snippets coming from make-common
MK_COMMON_FILES := help.mk pre-commit.mk password.mk

# Project-specific snippets that live only in this repo
MK_LOCAL_FILES := ansible.mk

MK_COMMON_BOOTSTRAP_SCRIPT := $(REPO_ROOT)/scripts/bootstrap-mk-common.sh

# Bootstrap: the script will self-update and fetch the selected .mk snippets
MK_COMMON_BOOTSTRAP := $(shell "$(MK_COMMON_BOOTSTRAP_SCRIPT)" \
  "$(MK_COMMON_REPO)" \
  "$(MK_COMMON_VERSION)" \
  "$(MK_COMMON_DIR)" \
  "$(MK_COMMON_FILES)")

# -----------------------------------------------------------------------------
# Include shared make logic (fetched from make-common)
# -----------------------------------------------------------------------------
include $(addprefix $(MK_COMMON_DIR)/,$(MK_COMMON_FILES))
include $(addprefix $(MK_COMMON_DIR)/,$(MK_LOCAL_FILES))

.PHONY: mk-common-update
mk-common-update: ## Check for remote updates of shared .mk files
	@echo "[mk] Checking for updates from $(MK_COMMON_REPO)@$(MK_COMMON_VERSION)"
	MK_COMMON_UPDATE=1 "$(MK_COMMON_BOOTSTRAP_SCRIPT)" \
	  "$(MK_COMMON_REPO)" \
	  "$(MK_COMMON_VERSION)" \
	  "$(MK_COMMON_DIR)" \
	  "$(MK_COMMON_FILES)"

# -----------------------------------------------------------------------------
# Adding new targets
# -----------------------------------------------------------------------------
# Do NOT add recipes directly to this file. Instead:
#   - Project-specific targets -> new .mk/<fragment>.mk added to MK_LOCAL_FILES
#   - Generic targets (useful beyond this repo) -> new or updated .mk/<fragment>.mk
#     added to MK_COMMON_FILES, then open a PR to port the change upstream at
#     https://github.com/leinardi/make-common so mk-common-update keeps working.
