#!/bin/sh
set -e

TRIGGER_ACTION="closed"

echo "Getting Action Information"
ACTION=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["action"]' | cut -f2 | sed 's/\"//g')
GH_EVENT_MILESTONE_NUMBER=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","number"]' | cut -f2)
REPOSITORY_NAME=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["repository","name"]' | cut -f2 | sed 's/\"//g')
OWNER_ID=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["repository","owner","login"]' | cut -f2 | sed 's/\"//g')
GH_USERNAME=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["sender","login"]' | cut -f2 | sed 's/\"//g')
PROVIDED_MILESTONE_ID=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["inputs","milestoneId"]' | cut -f2 | sed 's/\"//g')

API_URL="https://agent.api.stepsecurity.io/v1/github/$GITHUB_REPOSITORY/actions/subscription"

# Set a timeout for the curl command (3 seconds)
RESPONSE=$(curl --max-time 3 -s -w "%{http_code}" "$API_URL" -o /dev/null) || true
CURL_EXIT_CODE=${?}

# Check if the response code is not 200
if [ $CURL_EXIT_CODE -ne 0 ]; then
  echo "Timeout or API not reachable. Continuing to next step."
elif [ "$RESPONSE" = "200" ]; then
  :
elif [ "$RESPONSE" = "403" ]; then
  echo "Subscription is not valid. Reach out to support@stepsecurity.io"
  exit 1
else
  echo "Timeout or API not reachable. Continuing to next step."
fi

MILESTONE_ID_TO_USE=${MILESTONE_NUMBER:-$PROVIDED_MILESTONE_ID}
MILESTONE_ID_TO_USE=${MILESTONE_ID_TO_USE:-$GH_EVENT_MILESTONE_NUMBER}
echo "Action running with milestone $MILESTONE_ID_TO_USE on event $GITHUB_EVENT_NAME and action $ACTION"

#Check if Milestone exists, which means actions was raised by a milestone operation.
if [[ -z "$MILESTONE_ID_TO_USE" ]]; then
    echo "Milestone number is missing. Was the action raised by a milestone event?"
    exit 1
fi

OUTPUT_FILENAME="release_file.md"

#Check if we should use milestone title instead
if [[ -z "$FILENAME" && ! -z "$USE_MILESTONE_TITLE" ]]; then
    MILESTONE_TITLE=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","title"]' | cut -f2 | sed 's/\"//g' | sed 's/ /_/g')
    OUTPUT_FILENAME="$MILESTONE_TITLE.md"
fi

#Check if a filename is provided
if [[ ! -z "$FILENAME" ]]; then
    OUTPUT_FILENAME="$FILENAME.md"
fi

#Check if a filename prefix is provided
if [[ ! -z "$FILENAME_PREFIX" ]]; then
  if [[ ! -z "$FILENAME" ]]; then
    OUTPUT_FILENAME="$FILENAME_PREFIX$FILENAME.md"
  else
    OUTPUT_FILENAME="$FILENAME_PREFIX$MILESTONE_ID_TO_USE.md"
  fi
fi

#Output folder configuration
if [ -z "$OUTPUT_FOLDER" ]; then
  echo "OUTPUT_FOLDER ENV is missing, using the default one"
  OUTPUT_FOLDER='.'
else
  mkdir -p $OUTPUT_FOLDER
fi

echo "Checking for custom configuration..."
CONFIG_FILE=".github/release-notes.yml"
if [[ ! -f ${CONFIG_FILE} ]]; then
    echo "No config file specified."
    CONFIG_FILE=""
else
    echo "Configuring the action using $CONFIG_FILE"
fi

if [[ "workflow_dispatch" == "$GITHUB_EVENT_NAME" || "$ACTION" == "$TRIGGER_ACTION" ]]; then
    echo "Creating release notes for Milestone $MILESTONE_ID_TO_USE into the $OUTPUT_FILENAME file"
    java -jar /github-release-notes-generator.jar \
    --changelog.repository=${OWNER_ID}/${REPOSITORY_NAME} \
    --github.username=${GH_USERNAME} \
    --github.password=${GITHUB_TOKEN} \
    --changelog.milestone-reference=id \
    --spring.config.location=${CONFIG_FILE} \
    ${MILESTONE_ID_TO_USE} \
    ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
    cat ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
else
    echo "Release notes generation skipped because action was: $ACTION"
    exit 78
fi
