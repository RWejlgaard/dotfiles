install:
	@echo "01. Install dependencies"
	./install-scripts/01-install-packages.sh
	@echo "02. Move files"
	./install-scripts/02-move-files.sh
	@echo "03. Fisher install"
	./install-scripts/03-fisher-install.fish
	@echo "04. Fish plugins"
	./install-scripts/04-fish-plugins.fish
	@echo "05. Tmux plugins"
	./install-scripts/05-tmux-plugins.fish
	@echo "06. Vim setup"
	./install-scripts/06-vim-setup.fish
	@echo "07. Change shell"
	./install-scripts/07-change-shell.sh

.PHONY: install