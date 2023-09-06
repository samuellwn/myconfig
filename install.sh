#! /bin/bash

install -d -m 755 ~/.config
install -d -m 755 ~/.config/nvim
install -d -m 755 ~/.config/nvim/colors
install -d -m 755 ~/.config/nvim-qt

install -m 644 nvim/init.lua ~/.config/nvim/init.lua
install -m 644 nvim/ginit.vim ~/.config/nvim/ginit.vim
install -m 644 nvim/dracowizard.lua ~/.config/nvim/colors/dracowizard.lua
install -m 644 nvim/nvim-qt.conf ~/.config/nvim-qt/nvim-qt.conf
