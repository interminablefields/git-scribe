#!/bin/zsh

# quit on any non-0 exit code
set -e
# debug flag : set -x

# remove dummy files on exit
cleanup() {
  [ -f .no_op.txt ] && git restore --staged .no_op.txt && rm .no_op.txt
	echo
}
trap cleanup EXIT

display_help() {
	echo
	echo "✮ ⋆ ˚｡𖦹 ⋆｡°✩" | gum style --foreground 212
	echo
	echo "scribe: conventional git commit tool" | gum style --foreground 212 --bold
	echo
    echo "Usage: scribe [options]" 
	echo
	echo "Options":
    echo "  -p        push to remote after commit"
    echo "  -n        no-op mode; no actual commit or push. will stage a dummy file if nothing is staged."
	echo
	echo "use in the same manner as git commit-- after files are staged."
	echo "dropdowns for type and scope, text entry for everything else."
	echo
	echo "✮ ⋆ ˚｡𖦹 ⋆｡°✩" | gum style --foreground 212
	echo
}

# script / vars to track config files for dropdown menus

SCRIPT_PATH="${0:A}"
SCRIPT_DIR="${0:A:h}"
LOCAL_CONFIG="$PWD/.scribe"
DEV_CONFIG="$SCRIPT_DIR/scribe-config"

get_config_file() {
  local file="$1"
  if [ -f "$LOCAL_CONFIG/$file" ]; then # local dir has priority to override config
    echo "$LOCAL_CONFIG/$file"
  elif [ -f "$DEV_CONFIG/$file" ]; then # default to developer config
    echo "$DEV_CONFIG/$file"
  else
    echo ""  # fallback for not found
  fi
}

PUSH=0
NO_OP=0
DISP_HELP=0
NO_OP_TXT_FLAG=0

# set PUSH and NO_OP based on cmdline flags
while [ "$#" -gt 0 ]; do
	case $1 in
		-h)	DISP_HELP=1 ;; 
		-p) PUSH=1 ;;
		-n) NO_OP=1 ;;
		*) echo "fatal: unknown flag" | gum style --foreground 1 >&2; display_help; exit 1;;
	esac
	shift
done

if [[ $DISP_HELP == 1 ]]; then
	display_help
	exit 0
fi

echo

# check if nothing added to commit EXCEPT for no op version
if git diff --cached --quiet; then
	if [[ $NO_OP == 1 ]]; then
		touch .no_op.txt
		git add .no_op.txt
		NO_OP_TXT_FLAG=1
		echo "no files staged. creating dummy to test no-op" | gum style --foreground 3
		echo ""
	else
		echo "fatal: no files staged!" | gum style --foreground 1
		echo "exiting, no changes made." && exit 1
	fi
fi

# display committed files
STAGED=$(git diff --cached --name-only)
echo "files staged for commit: " | gum style --foreground 212 --bold
echo "$STAGED" | awk '{print "★", $0}' | gum format

echo ""

# type dropdown. pull from config
TYPE_FILE=$(get_config_file "types.txt")
if [ -z "$TYPE_FILE" ]; then
	echo "fatal: cannot locate types.txt config file." | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi
	
TYPE=$(cat $TYPE_FILE | gum choose --header "commit type")
if [ -z "$TYPE" ]; then 
	echo "fatal: commit type is mandatory!" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi

# scope dropdown. pull from config
SCOPE_FILE=$(get_config_file "scopes.txt")
if [ -z "$SCOPE_FILE" ]; then
	echo "fatal: cannot locate scopes.txt config file." | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi
# scope input, wrap in parentheses if provided
SCOPE=$((echo "[ ]"; cat $SCOPE_FILE ) | gum choose --header "optional scope")
[ "$SCOPE" = "[ ]" ] && SCOPE=""
test -n "$SCOPE" && SCOPE="($SCOPE)"

# collect description and body
DESC=$(gum input \
		--placeholder "mandatory description - one line summary of changes" \
		--value "$TYPE$SCOPE: ")
# checking for presence of colon
if [[ "$DESC" != *:* ]]; then
	echo "fatal: missing mandatory colon in description" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi
# zsh slicing to check that description isnt empty

DESC_ADDNS=${DESC#*:}
DESC_ADDNS=$(echo "$DESC_ADDNS" | xargs)

if [ -z "$DESC_ADDNS" ]; then 
	echo "fatal: description is mandatory!" | gum style --foreground 1
	echo "exiting, no changes made." && exit 1
fi

BODY=$(gum write --placeholder "optional body - multiline space for elaboration")

# assemble & check w user before committing
gum style --bold --foreground 212 "assembled commit message: "
printf "%b" "$DESC\n\n$BODY" | gum style --border rounded --margin "1 2" --padding "1 2" --foreground 212 

export GUM_CONFIRM_PROMPT_FOREGROUND=212
if gum confirm "commit approved?"; then 
	echo "⋆˚☆˖°⋆｡° ✮˖ ࣪ ⊹⋆.˚" | gum style --foreground 212
	if [[ $NO_OP == 1 ]]; then
		git commit --dry-run -m "$DESC" -m "$BODY"
	else
		git commit -m "$DESC" -m "$BODY"
	fi
	echo "⋆˚☆˖°⋆｡° ✮˖ ࣪ ⊹⋆.˚" | gum style --foreground 212
	echo
	gum style --foreground 212 "changes commited! "
	
	if [[ $PUSH == 1 ]]; then
		echo
		echo "*ੈ✩‧₊˚༺☆༻*ੈ✩‧₊˚" | gum style --foreground 212
		if [[ $NO_OP == 1 ]]; then
			gum spin --spinner line --show-output --title "pushing to remote..." -- git push --dry-run
			# git push --dry-run
		else
			# git push
			gum spin --spinner line --show-output --title "pushing to remote..." -- git push
		fi
		echo "*ੈ✩‧₊˚༺☆༻*ੈ✩‧₊˚" | gum style --foreground 212
		echo
		gum style --foreground 212 "changes pushed! "
	fi
fi
