#! /bin/sh
#
# Usage: ./postwhite.sh
#
# Requires spf-tools (https://github.com/jsarenik/spf-tools)

# By Steve Jenkins (http://stevejenkins.com/)
# Thanks to Mike Miller (mmiller@mgm51.com) for gwhitelist.sh script

# spf-tools location (REQUIRED)
spftoolspath=/usr/local/bin/spf-tools

# Postfix location and whitelist filename
postfixpath=/etc/postfix
whitelist=postscreen_spf_whitelist.cidr

# Toggle senders you want to include (1=on / 0=off)

google=1
microsoft=1
facebook=1
twitter=1

# Create temporary files
tmpBase=`basename $0`
tmp1=`mktemp -q /tmp/${tmpBase}.XXXXXX`
tmp2=`mktemp -q /tmp/${tmpBase}.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "$0: Can't create temp file, exiting..."
		exit 1
	fi

# abort on any error
set -e

if [ "$google" == 1 ]; then

	${spftoolspath}/despf.sh google.com >> ${tmp1}

fi

if [ "$microsoft" == 1 ]; then

	${spftoolspath}/despf.sh outlook.com >> ${tmp1}

	${spftoolspath}/despf.sh hotmail.com >> ${tmp1}

fi

if [ "$facebook" == 1 ]; then

	${spftoolspath}/despf.sh facebookmail.com >> ${tmp1}

fi

if [ "$twitter" == 1 ]; then

	${spftoolspath}/despf.sh twitter.com >> ${tmp1}

fi

# Format the whitelist

printf "%s\n" | grep "^ip" ${tmp1} | cut -c5- | sed s/$/'	permit'/ > ${tmp2}

# Sort and unique the final list and write to Postfix directory

sort -u ${tmp2} > ${postfixpath}/${whitelist}

# Remove temp files
test -e ${tmp1} && rm ${tmp1}
test -e ${tmp2} && rm ${tmp2}

# Reload Postfix to pick up any changes
/usr/sbin/postfix reload
