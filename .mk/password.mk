ifndef MK_COMMON_PASSWORD_INCLUDED
MK_COMMON_PASSWORD_INCLUDED := 1

.PHONY: password
password: ## Generate a 99-character password (PostgreSQL compatible)
	@echo "Generating a 99-character password (PostgreSQL compatible)..."
	@env LC_ALL=C tr -dc 'A-Za-z0-9_.-+=,' < /dev/urandom | head -c 99; echo

endif  # MK_COMMON_PASSWORD_INCLUDED
