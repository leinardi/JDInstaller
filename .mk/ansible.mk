ifndef MK_LOCAL_ANSIBLE_INCLUDED
MK_LOCAL_ANSIBLE_INCLUDED := 1

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
