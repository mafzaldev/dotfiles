SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DEFAULT_GOAL := help

DOT       := $(CURDIR)
ifndef DISTRO
DISTRO    := $(shell . /etc/os-release && for d in $$ID $$ID_LIKE; do [ $$d = fedora -o $$d = ubuntu ] && { echo $$d; break; }; done)
endif
ifndef DESKTOP
DESKTOP   := $(shell d=$$(echo "$${XDG_CURRENT_DESKTOP:-}" | tr A-Z a-z); if [[ $$d == *kde* ]] || { [ -z "$$d" ] && command -v plasmashell >/dev/null; }; then echo kde; else echo gnome; fi)
endif
TMP       := /tmp/dotfiles-install
NODE_DEFAULT ?= 26.12.1
PYTHON_VERSIONS ?= 3.12

export PATH := $(HOME)/.local/bin:$(HOME)/.local/go/bin:$(HOME)/.local/share/pnpm/bin:$(PATH)
export PNPM_HOME := $(HOME)/.local/share/pnpm

define github_asset
curl -fsSL https://api.github.com/repos/$(1)/releases/latest | jq -r '.assets[].browser_download_url | select(test("$(2)"))' | head -1
endef

ifeq ($(wildcard distros/$(DISTRO).mk),)
$(error Unsupported distro: this Makefile supports Ubuntu (and derivatives) and Fedora)
endif
include distros/$(DISTRO).mk

ifeq ($(wildcard desktops/$(DESKTOP).mk),)
$(error Unsupported desktop "$(DESKTOP)": use DESKTOP=gnome or DESKTOP=kde)
endif
include desktops/$(DESKTOP).mk

.PHONY: help
help: ## Show targets
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: backup
backup: ## Snapshot config + package lists into home/ and packages/
	./scripts/backup.sh

.PHONY: install
install: base repos packages apps store-apps shell node python go cli vscode dotfiles desktop services mongodb ## Full setup
	@echo "Done. Log out/in (docker group, GNOME)."

.PHONY: shell
shell: ## oh-my-bash (prompt/fonts come from dotfiles)
	[ -d $(HOME)/.oh-my-bash ] || bash -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

.PHONY: node
node: ## nvm + Node NODE_DEFAULT (default), pnpm, pnpm globals
	[ -d $(HOME)/.nvm ] || curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash
	set +u; . $(HOME)/.nvm/nvm.sh
	nvm install $(NODE_DEFAULT)
	nvm alias default $(NODE_DEFAULT) && nvm use default
	npm install -g pnpm
	xargs -r -a packages/pnpm-global.txt pnpm add -g

.PHONY: python
python: ## uv + extra Python versions
	command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
	uv python install $(PYTHON_VERSIONS)

.PHONY: go
go: ## Latest Go into ~/.local/go
	v=$$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)
	mkdir -p $(TMP) && curl -fL --progress-bar -o $(TMP)/go.tgz https://go.dev/dl/$$v.linux-amd64.tar.gz
	rm -rf $(HOME)/.local/go && tar -C $(HOME)/.local -xzf $(TMP)/go.tgz && rm $(TMP)/go.tgz
	go version

.PHONY: cli
cli: ## Claude Code
	command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

.PHONY: vscode
vscode: ## VS Code extensions
	xargs -r -n1 -a packages/vscode-extensions.txt code --install-extension --force

.PHONY: dotfiles
dotfiles: ## Copy home/ into ~ (overwritten files kept as *.pre-dotfiles)
	rsync -a --backup --suffix=.pre-dotfiles home/ $(HOME)/
	fc-cache -f >/dev/null

.PHONY: services
services: ## docker group, enable docker+postgres, keep the rest manual-start
	sudo usermod -aG docker $(USER)
	$(POSTGRES_INIT)
	sudo systemctl enable --now docker postgresql
	sudo systemctl disable --now $(SERVICES_OFF) 2>/dev/null || true
