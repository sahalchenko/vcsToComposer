#!/bin/bash

################ SET VARIABLES ################
VENDOR_LIST="/app/extensions.txt"
VENDOR_EXT="/app/render.txt"
SATIS_CONF="/app/satis.json"

################ PREPARE PAGE_URL ################
owner=$(echo $GIT_REPOSITORY | cut -d / -f 1)
repository=$(echo $GIT_REPOSITORY | cut -d / -f 2)
PAGE_URL="https://$owner.github.io/$repository/html"

################ PREPARE GITHUB LIST EXT ################
for file in $VENDOR_LIST; do
  grep '^https://github.com' "$file" >> "$VENDOR_EXT"
done
grep -v '^[[:space:]]*$' $VENDOR_EXT
sort $VENDOR_EXT | uniq > $VENDOR_EXT.tmp
rm $VENDOR_EXT && mv $VENDOR_EXT.tmp $VENDOR_EXT

################ PREPARE SATIS JSON FILE ################
echo "{" > $SATIS_CONF
echo "  \"name\": \"my/repository\"," >> $SATIS_CONF
echo "  \"homepage\": \"$PAGE_URL\"," >> $SATIS_CONF
echo "  \"output-html\": true," >> $SATIS_CONF
echo "  \"repositories\": [" >> $SATIS_CONF
while read -r line || [ -n "$line" ]; do
  line=$(echo $line | tr -d '\r\n')
  echo "    {" >> $SATIS_CONF
  echo "      \"type\": \"vcs\"," >> $SATIS_CONF
  echo "      \"url\": \"$line\"" >> $SATIS_CONF
  echo "    }," >> $SATIS_CONF
done < "$VENDOR_EXT"
sed -i '$ s/,$//' $SATIS_CONF # Remove the trailing comma from the last JSON object
echo "  ]," >> $SATIS_CONF
# Write the remaining fields to the JSON object
echo "  \"require-all\": true," >> $SATIS_CONF

# Add the archive block if ZIP_REPOSITORY is true
if [ "$ZIP_REPOSITORY" = true ]; then
echo "  \"archive\": {" >> $SATIS_CONF
echo "     \"skip-dev\": true," >> $SATIS_CONF
echo "     \"format\": \"zip\"," >> $SATIS_CONF
echo "     \"directory\": \"dist\" " >> $SATIS_CONF
echo "  }," >> $SATIS_CONF
fi
echo "  \"require-dependencies\": false," >> $SATIS_CONF
echo "  \"require-dev-dependencies\": false," >> $SATIS_CONF
echo "  \"only-best-candidates\": true," >> $SATIS_CONF
echo "  \"providers\": true," >> $SATIS_CONF
echo "  \"providers-history-size\": 3," >> $SATIS_CONF
echo "  \"config\": {" >> $SATIS_CONF
echo "    \"preferred-install\": \"dist\"," >> $SATIS_CONF
echo "    \"github-protocols\": [\"https\",\"http\"]," >> $SATIS_CONF
echo "    \"github-oauth\": {" >> $SATIS_CONF
echo "      \"github.com\": \"$GIT_TOKEN\"" >> $SATIS_CONF
echo "    }" >> $SATIS_CONF
echo "  }" >> $SATIS_CONF
echo "}" >> $SATIS_CONF
cat satis.json
satis build satis.json /app/html