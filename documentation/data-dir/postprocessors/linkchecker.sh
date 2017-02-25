#!/bin/bash
INPUT=`cat`
file_to_check="/tmp/FILE_TO_LINK_CHECK.html"
echo "$INPUT" > $file_to_check
linkchecker --no-status --anchors --check-extern $file_to_check 1>&2
cat $file_to_check
