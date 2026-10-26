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

ifndef MK_LOCAL_ANSIBLE_INCLUDED
MK_LOCAL_ANSIBLE_INCLUDED := 1

# Every Ansible tool the targets run comes from an ansible-core that uvx installs in its own cached
# environment, so the machine needs no Ansible of its own. The version comes from
# requirements-ci.txt, where Dependabot's pip ecosystem keeps it current. install_uv.sh puts uv in
# ~/.local/bin, which a fresh install does not have on PATH yet.
export PATH := $(HOME)/.local/bin:$(PATH)
ANSIBLE_CORE_VERSION := $(shell sed -n 's/^ansible-core==//p' requirements-ci.txt)
ANSIBLE_UVX          := uvx --from ansible-core==$(ANSIBLE_CORE_VERSION)

.PHONY: generate-group-vars
generate-group-vars: check-installed-pre-commit ## Generate inventory/group_vars/all.yaml
	@echo "Generating inventory/group_vars/all.yaml..."
	pre-commit run generate-group-vars --all-files

# The playbook runs with a temporary passwordless sudoers rule for the current user, so a long run
# never stops at a sudo prompt. The EXIT trap removes it however the recipe ends: a failed
# playbook, Ctrl-C (the signal traps turn INT, TERM and HUP into an exit, which runs the trap), or
# a failing step before the playbook. While the rule exists, the `sudo rm` needs no password. The
# recipe's exit status stays the playbook's.
.PHONY: install
install: ansible-galaxy-install ## Run ansible-playbook with optional parameters
	@echo "Running ansible-playbook with optional parameters..."
	@read -r -s -p "BECOME password: " _pass; echo; \
	_sudoers=/etc/sudoers.d/90-ansible-nopasswd; \
	_tmpfile=$$(mktemp -t ansible-sudoers.XXXXXXXX); \
	trap 'rm -f "$$_tmpfile"; sudo rm -f "$$_sudoers"' EXIT; \
	trap 'exit 129' HUP; trap 'exit 130' INT; trap 'exit 143' TERM; \
	printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$$USER" > "$$_tmpfile"; \
	echo "$$_pass" | sudo -S cp "$$_tmpfile" "$$_sudoers"; \
	sudo chmod 0440 "$$_sudoers"; \
	$(ANSIBLE_UVX) ansible-playbook playbooks/ubuntu-setup.yaml $(strip \
	$(if $(TAGS),--tags=$(TAGS)) \
	$(if $(LIMIT),--limit=$(LIMIT)) \
	$(if $(EXTRA_VARS),--extra-vars="$(EXTRA_VARS)") \
	$(if $(OTHER_PARAMS),$(OTHER_PARAMS)))

.PHONY: check-uv
check-uv: # Install uv if it is missing, and check that the ansible-core pin can be read
	@if ! command -v uvx >/dev/null 2>&1; then \
		echo "uv is not installed, running install_uv.sh..."; \
		./install_uv.sh; \
	fi
	@if [ -z "$(ANSIBLE_CORE_VERSION)" ]; then \
		echo "Error: no ansible-core==<version> line in requirements-ci.txt."; \
		exit 1; \
	fi

# The collections in requirements.yml go to ./.galaxy/collections, the first entry of
# collections_path in ansible.cfg, so neither a run nor a syntax check depends on what the host
# happens to have installed globally.
.PHONY: ansible-galaxy-install
ansible-galaxy-install: check-uv ## Install the collections listed in requirements.yml into .galaxy/
	$(ANSIBLE_UVX) ansible-galaxy collection install -r requirements.yml -p .galaxy/collections

# Every playbook, not only the entry point: a playbook that is not imported yet is still checked.
.PHONY: ansible-syntax-check
ansible-syntax-check: ansible-galaxy-install ## Check the syntax of every playbook (no host is contacted)
	$(ANSIBLE_UVX) ansible-playbook --syntax-check playbooks/*.yaml

endif  # MK_LOCAL_ANSIBLE_INCLUDED
