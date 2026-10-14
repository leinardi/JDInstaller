#
# MIT License
#
# Copyright (c) 2025 Roberto Leinardi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

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
