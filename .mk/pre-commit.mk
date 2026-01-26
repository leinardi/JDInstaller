ifndef MK_COMMON_PRECOMMIT_INCLUDED
MK_COMMON_PRECOMMIT_INCLUDED := 1

.PHONY: check
check: check-installed-pre-commit ## Run pre-commit on all files
	@pre-commit run --all-files

.PHONY: check-stage
check-stage: check-installed-pre-commit ## Run pre-commit on the current staging area
	@echo "Running pre-commit on current staging area..."
	@pre-commit run

.PHONY: pre-commit-install
pre-commit-install: check-installed-pre-commit ## Install pre-commit git hook in this repo
	@pre-commit install

.PHONY: pre-commit-autoupdate
pre-commit-autoupdate: check-installed-pre-commit ## Update pre-commit hook versions (immediate)
	@pre-commit autoupdate

.PHONY: check-installed-pre-commit
check-installed-pre-commit: # Verify that pre-commit is installed, print install help otherwise
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "Error: pre-commit is not installed."; \
		echo "Install it with:"; \
		echo "  macOS:  brew install pre-commit"; \
		echo "  Ubuntu: sudo apt install pre-commit"; \
		echo "  (or)  pipx install pre-commit"; \
		exit 1; \
	fi

endif  # MK_COMMON_PRECOMMIT_INCLUDED
