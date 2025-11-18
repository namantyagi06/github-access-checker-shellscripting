#!/bin/bash

# ==========================================================
# Script Name : GitHub Repository Access Checker
# Author      : Naman Tyagi
# Version     : v1
# Description : Lists all users with permissions on a given GitHub repository using GitHub REST API.               
# Usage       : ./check-access.sh <github-username> <token> <repo-owner> <repo-name>
# Example     : ./check-access.sh naman ghp_xxx namanDev myRepo
# ==========================================================

API_URL="https://api.github.com"

# Input validation
if [ $# -ne 4 ]; then
    echo "Usage: $0 <github-username> <token> <repo-owner> <repo-name>"
    exit 1
fi

USERNAME=$1
TOKEN=$2
REPO_OWNER=$3
REPO_NAME=$4

echo ""
echo "📌 Checking access list for repository: $REPO_OWNER/$REPO_NAME"
echo "---------------------------------------------"
echo ""

# Pagination support (GitHub default 30 items per page)
PAGE=1

while true; do
    RESPONSE=$(curl -s -u "$USERNAME:$TOKEN" \
        "${API_URL}/repos/${REPO_OWNER}/${REPO_NAME}/collaborators?page=$PAGE")

    # If empty JSON array, break
    if [[ "$RESPONSE" == "[]" || -z "$RESPONSE" ]]; then
        break
    fi

    echo "$RESPONSE" | jq -r '.[] | "\(.login) --> Permission: " +
        (if .permissions.admin then "ADMIN"
         elif .permissions.push then "WRITE"
         elif .permissions.pull then "READ"
         else "UNKNOWN" end)'

    ((PAGE++))
done

echo ""
echo "✔ Permission scan completed."
