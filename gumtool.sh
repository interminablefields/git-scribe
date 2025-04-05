#!/bin/sh

# type dropdown
TYPE=$(cat config/types.txt | gum choose)

# scope input, wrap in parentheses if provided
SCOPE=$(gum input --placeholder "optional scope- noun describing modified section of codebase")
test -n "$SCOPE" && SCOPE="($SCOPE)"

# collect description and body
DESC=$(gum input --value "$TYPE$SCOPE: " --placeholder "mandatory description - one line summary of changes")
BODY=$(gum write --placeholder "optional body - multiline space for elaboration")

# assemble & check w user before committing!
printf "%b" "$DESC\n\n$BODY" | gum style --border normal --margin "1 2" --padding "1 2" --foreground 212
gum confirm "commit changes?" && git commit -m "$DESC" -m "$BODY"
