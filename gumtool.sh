#!/bin/sh

# type dropdown
TYPE=$(cat config/types.txt | gum choose --header "commit type")

# scope input, wrap in parentheses if provided
SCOPE=$((echo "[ ]"; cat config/scopes.txt) | gum choose --header "optional scope")
[ "$SCOPE" = "[ ]" ] && SCOPE=""

test -n "$SCOPE" && SCOPE="($SCOPE)"

# collect description and body
DESC=$(gum input \
		--placeholder "mandatory description - one line summary of changes" \
		--value "$TYPE$SCOPE: ") 
BODY=$(gum write --placeholder "optional body - multiline space for elaboration")

# assemble & check w user before committing!
printf "%b" "$DESC\n\n$BODY" | gum style --border double --margin "1 2" --padding "1 2" --foreground 212
gum confirm "commit changes?" && git commit -m "$DESC" -m "$BODY"
