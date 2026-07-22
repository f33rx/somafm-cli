# Usage: make [target] [bindir=PATH] [logdir=PATH]
#
# Variables:
#   bindir    Installation directory (default: ./build/bin)
#   logdir    Log directory (default: ./build/var/log)
#
# Examples:
#   make install bindir=~/bin
#   make install bindir=/usr/local/bin logdir=/var/log

.DEFAULT_GOAL := help
bindir ?= ./build/bin
logdir ?= ./build/var/log
uname := $(shell uname -s)

.PHONY: help
help: ## Show this help message
	@sed -n 's/^# //p' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

clean: | uninstall ## Remove build artifacts and uninstall

deps: ## Install runtime dependencies (jq, gawk, mpv, cava)
	@command -v npm >/dev/null 2>&1 || { echo "Error: npm is required but not installed."; exit 1; }
	@command -v bats >/dev/null 2>&1 || npm install -g bats
ifeq (${uname}, Darwin)
	@command -v brew >/dev/null 2>&1 || { echo "Error: Homebrew required. Install from https://brew.sh"; exit 1; }
	@command -v jq >/dev/null 2>&1 || brew install jq
	@command -v gawk >/dev/null 2>&1 || brew install gawk
	@command -v mpv >/dev/null 2>&1 || brew install mpv
	@command -v cava >/dev/null 2>&1 || brew install cava
	@echo "Dependencies installed successfully"
else ifeq (${uname}, Linux)
	@if command -v apt-get >/dev/null 2>&1; then \
		command -v jq >/dev/null 2>&1 || sudo apt-get install -y jq; \
		command -v gawk >/dev/null 2>&1 || sudo apt-get install -y gawk; \
		command -v mpv >/dev/null 2>&1 || sudo apt-get install -y mpv; \
		command -v cava >/dev/null 2>&1 || sudo apt-get install -y cava; \
	elif command -v dnf >/dev/null 2>&1; then \
		command -v jq >/dev/null 2>&1 || sudo dnf install -y jq; \
		command -v gawk >/dev/null 2>&1 || sudo dnf install -y gawk; \
		command -v mpv >/dev/null 2>&1 || sudo dnf install -y mpv; \
		command -v cava >/dev/null 2>&1 || sudo dnf install -y cava; \
	elif command -v pacman >/dev/null 2>&1; then \
		command -v jq >/dev/null 2>&1 || sudo pacman -S --noconfirm jq; \
		command -v gawk >/dev/null 2>&1 || sudo pacman -S --noconfirm gawk; \
		command -v mpv >/dev/null 2>&1 || sudo pacman -S --noconfirm mpv; \
		command -v cava >/dev/null 2>&1 || sudo pacman -S --noconfirm cava; \
	else \
		echo "Error: No supported package manager found (apt-get, dnf, or pacman)"; \
		echo "Please install manually: jq, gawk, mpv, cava"; \
		exit 1; \
	fi
	@echo "Dependencies installed successfully"
else
	@if command -v scoop >/dev/null 2>&1; then \
		command -v jq >/dev/null 2>&1 || scoop install jq; \
		command -v gawk >/dev/null 2>&1 || scoop install gawk; \
		command -v mpv >/dev/null 2>&1 || scoop install mpv; \
		echo "Dependencies installed successfully"; \
	else \
		echo "Error: Scoop required on Windows. Install from https://scoop.sh"; \
		echo "Then run: scoop install jq gawk mpv"; \
		exit 1; \
	fi
endif

install: | stub ## Install somafm to bindir
	@cp -r src/* ${bindir}/
ifeq (${uname}, Darwin)
	@$(eval _bindir := $(shell cd ${bindir} && pwd))
	@$(eval _logdir := $(shell cd ${logdir} && pwd))
	@sed -i ''  "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i ''  "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
else ifeq (${uname}, Linux)
	@$(eval _bindir := $(shell readlink -f ${bindir}))
	@$(eval _logdir := $(shell readlink -f ${logdir}))
	@sed -i "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
else
	@$(eval _bindir := $(shell cd ${bindir} && pwd))
	@$(eval _logdir := $(shell cd ${logdir} && pwd))
	@sed -i "s|bindir=|bindir=${_bindir}|g" ${bindir}/somafm
	@sed -i "s|logdir=|logdir=${_logdir}|g" ${bindir}/somafm
endif

stub: ## Create build directories
	@mkdir -p ${bindir}
	@mkdir -p ${logdir}

test: | test-unit test-integration ## Run all tests

test-integration: | install ## Run integration tests
	@bats test/integration

test-unit: | install ## Run unit tests
	@bats test/unit

uninstall: ## Remove installed files and directories
	@rm -rf ${bindir}
	@rm -rf ${logdir}

.PHONY: clean help install stub test test-integration test-unit uninstall
