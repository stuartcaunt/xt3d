#!/bin/sh

NEW_VERSION=$1
HISTORY_FILE='../history.md'
XT_FILE='../xt3d/utils/XT.hx'
XT_VERSION_TEXT="public static inline var VERSION:String"
HX_FILE='../haxelib.json'
HX_VERSION_TEXT="\"version\""
GIT_LAST_TAG=`git describe --abbrev=0`
#GIT_LAST_TAG=0.2.8


echo "Previous version was $GIT_LAST_TAG"

if [ -z $1 ]; then
	NEW_VERSION=`echo $GIT_LAST_TAG | awk -F. -v OFS=. '{$NF=($NF+1); print}'`

	while true; do
		read -p "Set new version to $NEW_VERSION? [Y/N] " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
else
	echo "Setting new version to $NEW_VERSION"
fi


# replace XT package version
sed -i.bkup "/$XT_VERSION_TEXT/c\\
	\	$XT_VERSION_TEXT = \"$NEW_VERSION\";
	" $XT_FILE
rm $XT_FILE.bkup
echo "Updated XT version"

# replace haxelib version
sed -i.bkup "/$HX_VERSION_TEXT/c\\
	\  $HX_VERSION_TEXT: \"$NEW_VERSION\",
	" $HX_FILE
rm $HX_FILE.bkup
echo "Updated haxelib version"


# Format version and date
HISTORY_TITLE="$NEW_VERSION / `date +%Y-%m-%d`"
LOG_ENTRY=$HISTORY_TITLE"\n"
LEN=`printf "$HISTORY_TITLE" | wc -c`
for ((i=0; i<=LEN; i++)); do
	LOG_ENTRY=$LOG_ENTRY=
done
LOG_ENTRY=$LOG_ENTRY"\n"

# get all git log entries since last tag. Sed used to remove empty lines and then split multi-sentence messages
LOG_LINES=`git log --format=%B  $GIT_LAST_TAG..HEAD | sed '/^$/d' | sed -e 's/[.] /.\'$'\n/g'`

# iterate over logs
IFS=$'\n'       # make newlines the only separator
for LOG in $LOG_LINES
do
	LOG_ENTRY=$LOG_ENTRY" * $LOG\n"
done

# update history file
echo $LOG_ENTRY | cat - $HISTORY_FILE > temp && mv temp $HISTORY_FILE
echo "Updated history file"
