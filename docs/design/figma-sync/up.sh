#!/bin/zsh
# Uploads exported carriers to Figma: up.sh <page-id> <file-prefix> <upload-uuid...> (one file per uuid, name order).
# OUT = folder the export server writes to (default ./out).
OUT=${OUT:-out}
page=$1; prefix=$2; shift 2
files=($(ls $OUT | grep "^$prefix" | sort))
i=1
for u in "$@"; do
  f=${files[$i]}; [ -z "$f" ] && break
  r=$(curl -s -X POST -F "file=@$OUT/$f;type=image/svg+xml;filename=$f" "https://mcp.figma.com/mcp/upload/$u/submit?scaleMode=FILL&currentPageId=${page/:/%3A}")
  echo "$f $(echo $r | grep -o '"success":[a-z]*') $(echo $r | grep -o '"placedOnNodeId":"[^"]*"')"
  i=$((i+1))
done
