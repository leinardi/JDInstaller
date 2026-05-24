# Resolve repository root (Makefile can live anywhere)
SHELL := /bin/bash
REPO_ROOT := $(shell git rev-parse --show-toplevel 2>/dev/null || pwd)

MK_COMMON_REPO        ?= leinardi/make-common
MK_COMMON_VERSION     ?= v1

MK_COMMON_DIR         := $(REPO_ROOT)/.mk
MK_COMMON_FILES       := help.mk pre-commit.mk password.mk

MK_COMMON_BOOTSTRAP_SCRIPT := $(REPO_ROOT)/scripts/bootstrap-mk-common.sh

# Bootstrap: the script will self-update and fetch the selected .mk snippets
MK_COMMON_BOOTSTRAP := $(shell "$(MK_COMMON_BOOTSTRAP_SCRIPT)" \
  "$(MK_COMMON_REPO)" \
  "$(MK_COMMON_VERSION)" \
  "$(MK_COMMON_DIR)" \
  "$(MK_COMMON_FILES)")

# Include shared make logic
include $(addprefix $(MK_COMMON_DIR)/,$(MK_COMMON_FILES))

.PHONY: mk-common-update
mk-common-update: ## Check for remote updates of shared .mk files
	@echo "[mk] Checking for updates from $(MK_COMMON_REPO)@$(MK_COMMON_VERSION)"
	MK_COMMON_UPDATE=1 "$(MK_COMMON_BOOTSTRAP_SCRIPT)" \
	  "$(MK_COMMON_REPO)" \
	  "$(MK_COMMON_VERSION)" \
	  "$(MK_COMMON_DIR)" \
	  "$(MK_COMMON_FILES)"

.PHONY: generate-group-vars
generate-group-vars: check-installed-pre-commit ## Generate inventory/group_vars/all.yaml
	@echo "Generating inventory/group_vars/all.yaml..."
	pre-commit run generate-group-vars --all-files


.PHONY: install
install: check-ansible ## Run ansible-playbook with optional parameters
	@echo "Running ansible-playbook with optional parameters..."
	@read -r -s -p "BECOME password: " _pass; echo; \
	_tmpfile=$$(mktemp -t ansible-sudoers.XXXXXXXX); \
	printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$$USER" > "$$_tmpfile"; \
	echo "$$_pass" | sudo -S cp "$$_tmpfile" /etc/sudoers.d/90-ansible-nopasswd; \
	sudo chmod 0440 /etc/sudoers.d/90-ansible-nopasswd; \
	rm -f "$$_tmpfile"; \
	ansible-playbook playbooks/ubuntu-setup.yaml $(strip \
	$(if $(TAGS),--tags=$(TAGS)) \
	$(if $(LIMIT),--limit=$(LIMIT)) \
	$(if $(EXTRA_VARS),--extra-vars="$(EXTRA_VARS)") \
	$(if $(OTHER_PARAMS),$(OTHER_PARAMS))); \
	_rc=$$?; sudo rm -f /etc/sudoers.d/90-ansible-nopasswd; exit $$_rc

.PHONY: check-ansible
check-ansible: # Check if ansible is installed, and run the ansible installation script if not
	@if ! command -v ansible >/dev/null 2>&1; then \
		echo "Ansible is not installed, running setup script..."; \
		sudo ./install_ansible.sh; \
	else \
		echo "Ansible is already installed."; \
	fi
