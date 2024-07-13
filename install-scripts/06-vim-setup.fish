#!/usr/bin/env fish

# wait for packer to install, output is messy so let's hide it
nvim --headless -c 'sleep 1000m' -c 'qall' > /dev/null 2>&1

# run PackerSync, output is messy so let's hide it
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' > /dev/null 2>&1