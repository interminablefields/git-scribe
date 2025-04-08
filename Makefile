 # whichever folder your user-installed binaries live. make sure it's in your $PATH! 
PREFIX ?= $(HOME)/dotfiles/bin

install:
	# copying local shell script into user binary folder
	cp scribe.sh $(PREFIX)/git-scribe
	# scribe-config should live at the same level as the scribe binary
	cp -r scribe-config $(PREFIX)/scribe-config 

uninstall:
	rm -f $(PREFIX)/git-scribe
	rm -rf $(PREFIX)/scribe-config
