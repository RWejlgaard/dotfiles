# A bare `make` asks which config sets this machine should use, then installs
# with that selection. Use `make basic` for the non-interactive equivalent.
.DEFAULT_GOAL := picky

picky:
	@bash ./install-scripts/pick-sets.sh
	@$(MAKE) --no-print-directory full-install

# Enable just the "basic" set and install, skipping the picker. This is what
# CI runs, and the right target for any unattended install.
basic:
	@bash ./install-scripts/pick-sets.sh basic
	@$(MAKE) --no-print-directory full-install

# Install using whatever sets are already enabled, without asking.
full-install:
	@bash ./install-scripts/01-install-packages.sh
	@bash ./install-scripts/02-move-files.sh
	@fish ./install-scripts/03-fisher-install.fish
	@fish ./install-scripts/04-fish-plugins.fish
	@fish ./install-scripts/05-tmux-plugins.fish
	@fish ./install-scripts/06-vim-setup.fish
	@bash ./install-scripts/07-last-touches.sh
	@exec fish

refresh:
	@bash ./install-scripts/02-move-files.sh
	@exec fish

.PHONY: picky basic full-install refresh
