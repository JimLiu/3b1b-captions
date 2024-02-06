#!/bin/bash
# This script generates the automatic labeler for the 3b1b/captions repository.

year="20[0-9]{2}"
video_id="[^/]+"
language="[^/]+"

normal_videos="$year/$video_id/$language"
shorts="$year/shorts/$video_id/$language"
blog="$year/blog/$video_id/$language"

# Use find and grep to search for matching folders
# and keep only the las part of the path
#
# Note that we must exclude the shorts and blog folders since they would labeled as normal_videos_languages language
# in order to avoid this we could check for the presence of specific files in the folder , but the 
# structure of the project does not guarantee that the files will be present in the folder
normal_videos_languages=$(find . -type d | grep -E "$normal_videos" | grep -v "/shorts/" | grep -v "/blog/" | awk -F/ '{print $NF}')
shorts_languages=$(find . -type d | grep -E "$shorts" | grep -v "/blog/" | awk -F/ '{print $NF}')
blog_languages=$(find . -type d | grep -E "$blog" | grep -v "/shorts/" | awk -F/ '{print $NF}')

# Join the two lists and remove duplicates
languages=$(cat <(echo "$normal_videos_languages") <(echo "$shorts_languages") <(echo "$blog_languages") | sort | uniq)
labeler_file=".github/labeler.yml"

echo "# This file was automatically generated by the labeler.sh script. Do not edit manually." > $labeler_file
echo "" >> $labeler_file

for language in $languages;
do
    # Set the label name, with the first letter capitalized 
    label_name=$(echo "$language" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')

    # Add the label to the labeler config file
    {
        echo "$label_name:"
        echo "- changed-files:"
        echo "  - any-glob-to-any-file: '**/$language/*'"
        echo ""
    } >> $labeler_file
done
