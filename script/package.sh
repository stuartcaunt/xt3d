#!/bin/sh

NEW_VERSION=$1
XT_FILE='../xt3d/utils/XT.hx'
XT_VERSION_TEXT="public static inline var VERSION:String"
HX_FILE='../haxelib.json'
HX_VERSION_TEXT="\"version\""
GIT_LAST_TAG=`git describe --abbrev=0`
HISTORY_FILE='../history.md'


if [ "$#" -ne 1 ]; then
	echo "You need to provide a package version number"
	exit 1
fi



# replace XT package version
sed -i.bkup "/$XT_VERSION_TEXT/c\\
	\	$XT_VERSION_TEXT = \"$NEW_VERSION\";
	" $XT_FILE
rm $XT_FILE.bkup

# replace haxelib version
sed -i.bkup "/$HX_VERSION_TEXT/c\\
	\  $HX_VERSION_TEXT: \"$NEW_VERSION\",
	" $HX_FILE
rm $HX_FILE.bkup


# Format version and date
HISTORY_TITLE="$NEW_VERSION / `date +%Y-%m-%d`"
LOG_ENTRY=$HISTORY_TITLE"\n"
LEN=`printf "$HISTORY_TITLE" | wc -c`
for ((i=0; i<=LEN; i++)); do
	LOG_ENTRY=$LOG_ENTRY=
done
LOG_ENTRY=$LOG_ENTRY"\n"

# get all git log entries since last tag
LOG_LINES=`git log --format=%B  $GIT_LAST_TAG..HEAD | sed '/^$/d'`

# iterate over logs
IFS=$'\n'       # make newlines the only separator
for LOG in $LOG_LINES
do
	LOG_ENTRY=$LOG_ENTRY" * $LOG"
done
LOG_ENTRY=$LOG_ENTRY"\n"

# update history file
echo $LOG_ENTRY | cat - $HISTORY_FILE > temp && mv temp $HISTORY_FILE