# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: check
check: check-installed-pre-commit
	@pre-commit run --all-files

.PHONY: check-stage
check-stage: check-installed-pre-commit
	@echo "Running pre-commit on current staging area..."
	pre-commit run

.PHONY: check-master-changes
check-master-changes: check-installed-pre-commit
	@REF=; \
	if git rev-parse --verify --quiet origin/master >/dev/null && \
	   git merge-base --is-ancestor origin/master HEAD; then \
	  REF=origin/master; \
	elif git rev-parse --verify --quiet master >/dev/null && \
	     git merge-base --is-ancestor master HEAD; then \
	  REF=master; \
	else \
	  echo "Error: neither origin/master nor master is an ancestor of HEAD." >&2; \
	  exit 1; \
	fi; \
	echo "Running pre-commit on new commits since $$REF..."; \
	echo "pre-commit run --from-ref $$REF --to-ref HEAD"; \
	pre-commit run --from-ref $$REF --to-ref HEAD

# Task to run shellcheck on all shell scripts
.PHONY: shellcheck
shellcheck: check-installed-pre-commit check-installed-shellcheck
	@echo "Running shellcheck..."
	pre-commit run shellcheck --all-files

# Task to run prettier on all .yml and .yaml files
.PHONY: prettier
prettier: check-installed-pre-commit
	pre-commit run prettier-yaml --all-files

# Task to run ansible-lint on all playbooks after prettier
.PHONY: ansible-lint
ansible-lint: check-installed-pre-commit
	@echo "Running ansible-lint..."
	pre-commit run ansible-lint --all-files

.PHONY: actionlint
actionlint: check-installed-pre-commit
	@echo "Running actionlint..."
	pre-commit run actionlint --all-files

# Task to run yamllint on all playbooks after prettier
.PHONY: yamllint
yamllint: check-installed-pre-commit
	@echo "Running yamllint..."
	pre-commit run yamllint --all-files

.PHONY: check-installed-shellcheck
check-installed-shellcheck:
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "Error: shellcheck is not installed."; \
		echo "Install it with:"; \
		echo "  macOS: brew install shellcheck"; \
		echo "  Ubuntu: sudo apt-get install -y shellcheck"; \
		exit 1; \
	fi

.PHONY: check-installed-prettier
check-installed-prettier:
	@if ! command -v prettier >/dev/null 2>&1; then \
		echo "Error: prettier is not installed."; \
		echo "Install it with:"; \
		echo "  macOS: brew install prettier"; \
		echo "  Ubuntu: npm install --global prettier"; \
		exit 1; \
	fi

.PHONY: check-installed-pre-commit
check-installed-pre-commit:
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "Error: pre-commit is not installed."; \
		echo "Install it with:"; \
		echo "  macOS: brew install pre-commit"; \
		echo "  Ubuntu: pip install pre-commit"; \
		exit 1; \
	fi

.PHONY: install-pre-commit
install-pre-commit: check-installed-pre-commit
	@echo "Setting up pre-commit..."
	pre-commit install

# Task to generate group_vars/all.yml
.PHONY: generate-group-vars
generate-group-vars: check-installed-pre-commit
	@echo "Generating group_vars/all.yml..."
	pre-commit run generate-group-vars --all-files

# Task to run ansible-playbook with optional parameters like TAGS, LIMIT, EXTRA_VARS, OTHER_PARAMS
.PHONY: install
install: check-ansible
	@echo "Running ansible-playbook with optional parameters..."
	ansible-playbook ubuntu-setup.yml --ask-become-pass $(strip \
	$(if $(TAGS),--tags=$(TAGS)) \
	$(if $(LIMIT),--limit=$(LIMIT)) \
	$(if $(EXTRA_VARS),--extra-vars="$(EXTRA_VARS)") \
	$(if $(OTHER_PARAMS),$(OTHER_PARAMS)))

# Check if ansible is installed, and run the ansible installation script if not
.PHONY: check-ansible
check-ansible:
	@if ! command -v ansible >/dev/null 2>&1; then \
		echo "Ansible is not installed, running setup script..."; \
		sudo ./install_ansible.sh; \
	else \
		echo "Ansible is already installed."; \
	fi
