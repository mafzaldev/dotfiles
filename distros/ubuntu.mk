CODENAME := $(shell . /etc/os-release && echo $${UBUNTU_CODENAME:-$$VERSION_CODENAME})
KEYRINGS := /etc/apt/keyrings
SERVICES_OFF := redis-server nginx mongod
POSTGRES_INIT := true
PKG_INSTALL := sudo apt-get install -y

define add_repo
	curl -fsSL $(2) | sudo gpg --dearmor --yes -o $(KEYRINGS)/$(1).gpg
	echo "deb [arch=amd64 signed-by=$(KEYRINGS)/$(1).gpg] $(3)" | sudo tee /etc/apt/sources.list.d/$(1).list >/dev/null
endef

define install_deb
	mkdir -p $(TMP) && curl -fL --progress-bar -o $(TMP)/pkg.deb "$(1)"
	sudo apt-get install -y $(TMP)/pkg.deb && rm -f $(TMP)/pkg.deb
endef

.PHONY: base
base: ## System upgrade + bootstrap tools
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install -y curl ca-certificates gnupg jq rsync unzip
	sudo install -d -m 0755 $(KEYRINGS)

.PHONY: repos
repos: ## Third-party repos (Docker, ngrok, pgAdmin, MongoDB)
	$(call add_repo,docker,https://download.docker.com/linux/ubuntu/gpg,https://download.docker.com/linux/ubuntu $(CODENAME) stable)
	$(call add_repo,ngrok,https://ngrok-agent.s3.amazonaws.com/ngrok.asc,https://ngrok-agent.s3.amazonaws.com bookworm main)
	$(call add_repo,pgadmin4,https://www.pgadmin.org/static/packages_pgadmin_org.pub,https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(CODENAME) pgadmin4 main)
	$(call add_repo,mongodb-org,https://www.mongodb.org/static/pgp/server-8.0.asc,https://repo.mongodb.org/apt/ubuntu $(CODENAME)/mongodb-org/8.0 multiverse)
	sudo apt-get update

.PHONY: packages
packages: ## Packages from packages/ubuntu.txt + third-party repos
	sudo apt-get install -y $$(grep -vE '^\s*(#|$$)' packages/ubuntu.txt)
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
		ngrok pgadmin4

.PHONY: mongodb
mongodb: ## MongoDB 8.0 server + mongosh (apt)
	sudo apt-get install -y mongodb-org

.PHONY: apps
apps: ## GUI apps (Chrome, VS Code, Compass, RedisInsight, Free Download Manager)
	$(call install_deb,https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb)
	./scripts/update-vscode.sh --force
	$(call install_deb,$$($(call github_asset,mongodb-js/compass,mongodb-compass_[0-9.]+_amd64\\.deb$$)))
	$(call install_deb,https://s3.amazonaws.com/redisinsight.download/public/latest/Redis-Insight-linux-amd64.deb)
	$(call install_deb,https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb)

.PHONY: store-apps
store-apps: ## Slack, Spotify (snap)
	sudo snap install slack spotify
