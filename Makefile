PREFIX ?= $(HOME)/dotfiles/bin

install:
	cp scribe.sh $(PREFIX)/git-scribe
	cp -r scribe-config $(PREFIX)/scribe-config

uninstall:
	rm -f $(PREFIX)/git-scribe
	rm -rf $(PREFIX)/scribe-config
