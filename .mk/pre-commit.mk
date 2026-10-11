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
