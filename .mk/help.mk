ifndef MK_COMMON_HELP_INCLUDED
MK_COMMON_HELP_INCLUDED := 1

# Set help as the default goal.
# Repos can override by assigning .DEFAULT_GOAL after including this file.
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help and usage
	@awk 'BEGIN {FS=":.*##"} /^[a-zA-Z0-9_\/-]+:.*##/ { printf "%s:%s\n", $$1, $$2 }' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS=":"; print "\nTargets:"} { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 }'
	@echo ""

endif  # MK_COMMON_HELP_INCLUDED
