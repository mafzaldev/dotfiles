DESKTOP_PKGS_ubuntu := gnome-shell-extensions gnome-tweaks
DESKTOP_PKGS_fedora := gnome-extensions-app gnome-shell-extension-user-theme gnome-tweaks

.PHONY: desktop
desktop: ## GNOME: Tweaks, extensions, settings from packages/dconf-*.ini
	$(PKG_INSTALL) $(DESKTOP_PKGS_$(DISTRO))
	shopt -s nullglob
	for f in packages/dconf-*.ini; do
		p=$$(basename $$f .ini); p=$${p#dconf-}
		dconf load /org/gnome/$${p//.//}/ < $$f
	done
