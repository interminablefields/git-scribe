#!/bin/zsh

TYPE=$(cat config/types.txt | gum filter)
SCOPE=$(gum input --placeholder "optional scope; noun describing modified section of codebase")
DESC=$(gum input --placeholder "mandatory description; one line summary of changes")
BODY=$(gum write --placeholder "optional body; multiline space for elaboration")

if [[ -n $SCOPE ]]; then 
	HEADER="$TYPE($SCOPE):$DESC"
else
	HEADER="$TYPE:$DESC"
fi

if [[ -n $BODY ]]; then
	COMMIT="$HEADER\n\n$BODY"
else
	COMMIT="$HEADER"
fi

gum style --border normal --margin "1 2" --padding "1 2" --foreground 212 "$COMMIT"

gum confirm "commit changes?" && git commit -m "$COMMIT"
