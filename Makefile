.PHONY: install

install:
	brew install stow
	stow zsh nvim git tmux gh ghostty --target=/Users/doug
