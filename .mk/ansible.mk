ifndef MK_LOCAL_ANSIBLE_INCLUDED
MK_LOCAL_ANSIBLE_INCLUDED := 1

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
install: check-ansible ## Run ansible-playbook with optional parameters
	@echo "Running ansible-playbook with optional parameters..."
	@read -r -s -p "BECOME password: " _pass; echo; \
	_sudoers=/etc/sudoers.d/90-ansible-nopasswd; \
	_tmpfile=$$(mktemp -t ansible-sudoers.XXXXXXXX); \
	trap 'rm -f "$$_tmpfile"; sudo rm -f "$$_sudoers"' EXIT; \
	trap 'exit 129' HUP; trap 'exit 130' INT; trap 'exit 143' TERM; \
	printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$$USER" > "$$_tmpfile"; \
	echo "$$_pass" | sudo -S cp "$$_tmpfile" "$$_sudoers"; \
	sudo chmod 0440 "$$_sudoers"; \
	ansible-playbook playbooks/ubuntu-setup.yaml $(strip \
	$(if $(TAGS),--tags=$(TAGS)) \
	$(if $(LIMIT),--limit=$(LIMIT)) \
	$(if $(EXTRA_VARS),--extra-vars="$(EXTRA_VARS)") \
	$(if $(OTHER_PARAMS),$(OTHER_PARAMS)))

.PHONY: check-ansible
check-ansible: # Check if ansible is installed, and run the ansible installation script if not
	@if ! command -v ansible >/dev/null 2>&1; then \
		echo "Ansible is not installed, running setup script..."; \
		sudo ./install_ansible.sh; \
	else \
		echo "Ansible is already installed."; \
	fi

# The collections in requirements.yml go to ./.galaxy/collections, the first entry of
# collections_path in ansible.cfg, so a syntax check never depends on what the host happens to
# have installed globally.
.PHONY: ansible-galaxy-install
ansible-galaxy-install: ## Install the collections listed in requirements.yml into .galaxy/
	ansible-galaxy collection install -r requirements.yml -p .galaxy/collections

# Every playbook, not only the entry point: a playbook that is not imported yet is still checked.
.PHONY: ansible-syntax-check
ansible-syntax-check: ansible-galaxy-install ## Check the syntax of every playbook (no host is contacted)
	ansible-playbook --syntax-check playbooks/*.yaml

endif  # MK_LOCAL_ANSIBLE_INCLUDED
