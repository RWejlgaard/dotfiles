install:
	@bash ./install-scripts/01-install-packages.sh
	@bash ./install-scripts/02-move-files.sh
	@fish ./install-scripts/03-fisher-install.fish
	@fish ./install-scripts/04-fish-plugins.fish
	@fish ./install-scripts/05-tmux-plugins.fish
	@fish ./install-scripts/06-vim-setup.fish
	@bash ./install-scripts/07-change-shell.sh

.PHONY: install