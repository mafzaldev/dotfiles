SERVICES_OFF := valkey nginx mongod
PKG_INSTALL := sudo dnf install -y
POSTGRES_INIT := sudo test -f /var/lib/pgsql/data/PG_VERSION || sudo postgresql-setup --initdb

.PHONY: base
base: ## System upgrade + bootstrap tools
	sudo dnf upgrade -y --refresh
	sudo dnf install -y curl ca-certificates gnupg2 jq rsync unzip dnf5-plugins

.PHONY: repos
repos: ## Third-party repos (Docker, VS Code, pgAdmin, MongoDB, COPR: Ghostty, lazygit, Starship)
	sudo dnf config-manager addrepo --overwrite --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	printf '%s\n' '[code]' 'name=Visual Studio Code' 'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
		'enabled=1' 'gpgcheck=1' 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
		| sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
	printf '%s\n' '[mongodb-org-8.0]' 'name=MongoDB 8.0' 'baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/8.0/x86_64/' \
		'enabled=1' 'gpgcheck=1' 'gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc' \
		| sudo tee /etc/yum.repos.d/mongodb-org-8.0.repo >/dev/null
	rpm -q pgadmin4-fedora-repo >/dev/null || sudo dnf install -y https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-fedora-repo-2-1.noarch.rpm
	for c in scottames/ghostty atim/lazygit atim/starship; do sudo dnf copr enable -y $$c; done

.PHONY: packages
packages: ## Packages from packages/fedora.txt + third-party repos
	sudo dnf install -y $$(grep -vE '^\s*(#|$$)' packages/fedora.txt)
	sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
		code ghostty lazygit starship pgadmin4-desktop
	mkdir -p $(TMP) && curl -fsSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz \
		| sudo tar -xzf - -C /usr/local/bin ngrok

.PHONY: mongodb
mongodb: ## MongoDB 8.0 server, mongosh and tools (RHEL 9 packages) + MongoDB's SELinux policy
	sudo dnf install -y mongodb-org git make checkpolicy policycoreutils selinux-policy-devel
	rm -rf $(TMP)/mongodb-selinux && git clone -q --depth 1 https://github.com/mongodb/mongodb-selinux $(TMP)/mongodb-selinux
	make -C $(TMP)/mongodb-selinux && sudo make -C $(TMP)/mongodb-selinux install

.PHONY: apps
apps: ## GUI apps (Chrome, Compass, RedisInsight)
	sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo dnf install -y "$$($(call github_asset,mongodb-js/compass,mongodb-compass-[0-9.]+\\.x86_64\\.rpm$$))"
	sudo dnf install -y https://s3.amazonaws.com/redisinsight.download/public/latest/Redis-Insight-linux-x86_64.rpm

.PHONY: store-apps
store-apps: ## Slack, Spotify, Free Download Manager (Flatpak)
	sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo flatpak remote-modify --enable --no-filter flathub
	sudo flatpak install -y flathub com.slack.Slack com.spotify.Client org.freedownloadmanager.Manager
