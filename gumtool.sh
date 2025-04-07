#!/bin/bash

# quit on any non-0 exit code
set -e

PUSH=0
NO_OP=0

while [ "$#" -gt 0 ]; do
	case $1 in
		-p) PUSH=1 ;;
		-n) NO_OP=1 ;;
		*) echo "unknown flag">&2; exit 1;;
	esac
	shift
done

# type dropdown
TYPE=$(cat config/types.txt | gum choose --header "commit type")
[ -z $TYPE ] && echo "commit type is mandatory! exiting, no changes made." && exit 1

# scope input, wrap in parentheses if provided
SCOPE=$((echo "[ ]"; cat config/scopes.txt) | gum choose --header "optional scope")
[ "$SCOPE" = "[ ]" ] && SCOPE=""

test -n "$SCOPE" && SCOPE="($SCOPE)"

# collect description and body
DESC=$(gum input \
		--placeholder "mandatory description - one line summary of changes" \
		--value "$TYPE$SCOPE: ")
DESC_ADDNS=$(echo "$DESC" | cut -d: -f2- | xargs)
[ -z "$DESC_ADDNS" ] && echo "description is mandatory! exiting, no changes made." && exit 1

BODY=$(gum write --placeholder "optional body - multiline space for elaboration")

# assemble & check w user before committing!
printf "%b" "$DESC\n\n$BODY" | gum style --border double --margin "1 2" --padding "1 2" --foreground 212
echo ""
if gum confirm "commit changes?"; then 
	if [ -n "$NO_OP" ]; then
		exit 0
	fi
	echo "$PUSH"
	git commit -m "$DESC" -m "$BODY"
	if [ -n "$PUSH" ]; then
		echo "here"
		gum spin --spinner line --title "preparing to push" -- sleep 2
		git push
	fi
fi


