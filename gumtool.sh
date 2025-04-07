#!/bin/bash

# quit on any non-0 exit code
set -e
# debug flag : set -x

PUSH=0
NO_OP=0
NO_OP_TXT_FLAG=0

# set PUSH and NO_OP based on cmdline flags
while [ "$#" -gt 0 ]; do
	case $1 in
		-p) PUSH=1 ;;
		-n) NO_OP=1 ;;
		*) echo "unknown flag">&2; exit 1;;
	esac
	shift
done

# check if nothing added to commit EXCEPT for no op version

if git diff --cached --quiet; then
	if [[ $NO_OP == 1 ]]; then
		touch .no_op.txt
		git add .no_op.txt
		NO_OP_TXT_FLAG=1
	else
		echo "no files staged!" | gum style --foreground 1
		echo "exiting, no changes made." && exit 1
	fi
fi

# type dropdown
TYPE=$(cat config/types.txt | gum choose --header "commit type")
if [ -z "$TYPE" ]; then 
	echo "commit type is mandatory!" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi

# scope input, wrap in parentheses if provided
SCOPE=$((echo "[ ]"; cat config/scopes.txt) | gum choose --header "optional scope")
[ "$SCOPE" = "[ ]" ] && SCOPE=""
test -n "$SCOPE" && SCOPE="($SCOPE)"

# collect description and body
DESC=$(gum input \
		--placeholder "mandatory description - one line summary of changes" \
		--value "$TYPE$SCOPE: ")
# checking for presence of colon
if [[ "$DESC" != *:* ]]; then
	echo "missing mandatory colon in description" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi
# zsh slicing to check that description isn't empty
DESC_ADDNS=${DESC#*:}
DESC_ADDNS=$(echo "$DESC_ADDNS" | xargs)

if [ -z "$DESC_ADDNS" ]; then 
	echo "description is mandatory!" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi

BODY=$(gum write --placeholder "optional body - multiline space for elaboration")

# assemble & check w user before committing
printf "%b" "$DESC\n\n$BODY" | gum style --border rounded --margin "1 2" --padding "1 2" --foreground 212

if gum confirm "commit changes?"; then 
	if [[ $NO_OP == 1 ]]; then
		git commit --dry-run -m "$DESC" -m "$BODY"
	else
		git commit -m "$DESC" -m "$BODY"
	fi
	
	gum style --foreground 46 "changes commited!"
	
	if [[ $PUSH == 1 ]]; then
		# gum spin --spinner line --title "preparing to push" -- sleep 1
		if [[ $NO_OP == 1 ]]; then
			gum spin --spinner line --show-output --title "pushing to remote..." -- git push --dry-run
			# git push --dry-run
		else
			# git push
			gum spin --spinner line --show-output --title "pushing to remote..." -- git push
		fi
		gum style --foreground 46 "changes pushed!"
	fi
fi

if [[ $NO_OP_TXT_FLAG == 1 ]]; then
	git restore --staged .no_op.txt
	rm .no_op.txt
fi

