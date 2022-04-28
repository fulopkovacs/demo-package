#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# The first argument to the script
# is the name of the package
PACKAGE_NAME="$1"

echo "$PACKAGE_NAME"

echo "$KEY"

exit 0

# Reference: https://docs.digitalocean.com/reference/api/spaces-api/

# Step 1: Define the parameters for the Space you want to upload to.
SPACE="nyc-tutorial-space" # Find your endpoint in the control panel, under Settings.
REGION="nyc3"              # Must be "us-east-1" when creating new Spaces. Otherwise, use the region in your endpoint (e.g. nyc3).
STORAGETYPE="STANDARD"     # Storage type, can be STANDARD, REDUCED_REDUNDANCY, etc.
KEY="5SGMECSBJ6UPVC2AJ6B4" # Access key pair. You can create access key pairs using the control panel or API.
SECRET="$SECRET"           # Secret access key defined through an environment variable.

# Step 2: Define a function that uploads your object via cURL.
function putS3 {
	path="."               # The local path to the file you want to upload.
	file="hello-world.txt" # The file you want to upload.
	space_path="/"         # The path within your Space where you want to upload the new file.
	space="${SPACE}"
	date=$(date +"%a, %d %b %Y %T %z")
	acl="x-amz-acl:private"   # Defines Access-control List (ACL) permissions, such as private or public.
	content_type="text/plain" # Defines the type of content you are uploading.
	storage_type="x-amz-storage-class:${STORAGETYPE}"
	string="PUT\n\n$content_type\n$date\n$acl\n$storage_type\n/$space$space_path$file"
	signature=$(echo -en "${string}" | openssl sha1 -hmac "${SECRET}" -binary | base64)
	curl -s -X PUT -T "$path/$file" \ # The cURL command that uploads your file.
	-H "Host: $space.${REGION}.digitaloceanspaces.com" \
		-H "Date: $date" \
		-H "Content-Type: $content_type" \
		-H "$storage_type" \
		-H "$acl" \
		-H "Authorization: AWS ${KEY}:$signature" \
		"https://$space.${REGION}.digitaloceanspaces.com$space_path$file"
}

# Step 3: Run the putS3 function.
for file in "$path"/*; do
	putS3 "$path" "${file##*/}" "nyc-tutorial-space/"
done
