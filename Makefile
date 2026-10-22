SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DEFAULT_GOAL := help

DOT       := $(CURDIR)
CODENAME  := $(shell . /etc/os-release && echo $$VERSION_CODENAME)
KEYRINGS  := /etc/apt/keyrings
TMP       := /tmp/dotfiles-install
NODE_DEFAULT ?= 26.12.1
PYTHON_VERSIONS ?= 3.12

export PATH := $(HOME)/.local/bin:$(HOME)/.local/go/bin:$(HOME)/.local/share/pnpm/bin:$(PATH)
export PNPM_HOME := $(HOME)/.local/share/pnpm

define add_repo
	curl -fsSL $(2) | sudo gpg --dearmor --yes -o $(KEYRINGS)/$(1).gpg
	echo "deb [arch=amd64 signed-by=$(KEYRINGS)/$(1).gpg] $(3)" | sudo tee /etc/apt/sources.list.d/$(1).list >/dev/null
endef

define install_deb
	mkdir -p $(TMP) && curl -fL --progress-bar -o $(TMP)/pkg.deb "$(1)"
	sudo apt-get install -y $(TMP)/pkg.deb && rm -f $(TMP)/pkg.deb
endef

define github_deb
	$(call install_deb,$$(curl -fsSL https://api.github.com/repos/$(1)/releases/latest | jq -r '.assets[].browser_download_url | select(test("$(2)"))' | head -1))
endef

.PHONY: help
help: ## Show targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: backup
backup: ## Snapshot config + package lists into home/ and packages/
	./scripts/backup.sh

.PHONY: install
install: base repos packages apps snaps shell node python go cli vscode dotfiles gnome services ## Full setup
	@echo "Done. Log out/in (docker group, GNOME)."

.PHONY: base
base: ## apt update/upgrade + bootstrap tools
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install -y curl ca-certificates gnupg jq rsync unzip
	sudo install -d -m 0755 $(KEYRINGS)

.PHONY: repos
repos: ## Third-party apt repos (docker, ngrok, pgadmin, mongodb)
	$(call add_repo,docker,https://download.docker.com/linux/ubuntu/gpg,https://download.docker.com/linux/ubuntu $(CODENAME) stable)
	$(call add_repo,ngrok,https://ngrok-agent.s3.amazonaws.com/ngrok.asc,https://ngrok-agent.s3.amazonaws.com bookworm main)
	$(call add_repo,pgadmin4,https://www.pgadmin.org/static/packages_pgadmin_org.pub,https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(CODENAME) pgadmin4 main)
	$(call add_repo,mongodb-org,https://www.mongodb.org/static/pgp/server-8.0.asc,https://repo.mongodb.org/apt/ubuntu $(CODENAME)/mongodb-org/8.0 multiverse)
	sudo apt-get update

.PHONY: packages
packages: ## apt packages (packages/apt.txt + repo packages)
	sudo apt-get install -y $$(grep -vE '^\s*(#|$$)' packages/apt.txt)
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
		ngrok pgadmin4 mongodb-org

.PHONY: apps
apps: ## GUI apps shipped as .deb (Chrome, VS Code, Compass, RedisInsight, LocalSend, ...)
	$(call install_deb,https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb)
	./scripts/update-vscode.sh --force
	$(call github_deb,mongodb-js/compass,mongodb-compass_[0-9.]+_amd64\\.deb$$)
	$(call github_deb,localsend/localsend,linux-x86-64\\.deb$$)
	$(call install_deb,https://s3.amazonaws.com/redisinsight.download/public/latest/Redis-Insight-linux-amd64.deb)
	$(call install_deb,https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb)

.PHONY: snaps
snaps: ## Snaps (Slack, Spotify)
	sudo snap install slack spotify

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

.PHONY: gnome
gnome: ## Load GNOME settings (desktop, shell/extensions, mutter, shortcuts)
	shopt -s nullglob
	for f in packages/dconf-*.ini; do
		p=$$(basename $$f .ini); p=$${p#dconf-}
		dconf load /org/gnome/$${p//.//}/ < $$f
	done

.PHONY: services
services: ## docker group, enable docker+postgres, keep the rest manual-start
	sudo usermod -aG docker $(USER)
	sudo systemctl enable --now docker postgresql
	sudo systemctl disable --now redis-server nginx mongod 2>/dev/null || true
