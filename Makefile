# Define default task
check: generate-group-vars shellcheck prettier ansible-lint

# Task to generate group_vars/all.yml
generate-group-vars:
	@echo "Generating group_vars/all.yml..."
	./generate-group-vars.sh

# Task to run shellcheck on all shell scripts
shellcheck:
	@echo "Running shellcheck..."
	find . -name "*.sh" | xargs shellcheck

# Task to run prettier on all .yml files
prettier:
	@echo "Running prettier on .yml files..."
	prettier --write "**/*.yml"

# Task to run ansible-lint on all playbooks after prettier
ansible-lint:
	@echo "Running ansible-lint..."
	ansible-lint

# Task to run ansible-playbook with optional parameters like TAGS, LIMIT, EXTRA_VARS, OTHER_PARAMS
install: check-ansible
	@echo "Running ansible-playbook with optional parameters..."
	ansible-playbook ubuntu-setup.yml --ask-become-pass $(strip \
	$(if $(TAGS),--tags=$(TAGS)) \
	$(if $(LIMIT),--limit=$(LIMIT)) \
	$(if $(EXTRA_VARS),--extra-vars="$(EXTRA_VARS)") \
	$(if $(OTHER_PARAMS),$(OTHER_PARAMS)))

# Check if ansible is installed, and run the ansible installation script if not
check-ansible:
	@if ! command -v ansible >/dev/null 2>&1; then \
		echo "Ansible is not installed, running setup script..."; \
		sudo ./install_ansible.sh; \
	else \
		echo "Ansible is already installed."; \
	fi
