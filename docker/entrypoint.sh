#!/usr/bin/env bash

set -e

if [[ -f /tmp/.env  ]]; then
    yes | cp -f /tmp/.env /usr/local/learninglocker/.env
fi

# Set to 0 if not set to one for commands to run on first start up.
CREATE_ACCOUNT=${CREATE_ACCOUNT:-0}
MIGRATION_DOWN=${MIGRATION_DOWN:-0}
MIGRATION_UP=${MIGRATION_UP:-0}
FIRST_TIME=${FIRST_TIME:-0}
SERVICE_TYPE=$([[ "$SERVICE_TYPE" == "api" || "$SERVICE_TYPE" == "ui" ]] && echo "$SERVICE_TYPE" || echo "api")

# Execute commands based on input options.
if [[ ${MIGRATION_DOWN} -gt 0 ]]; then yarn rollback; fi
if [[ ${MIGRATION_UP} -gt 0 ]]; then yarn migrate; fi
if [[ ${CREATE_ACCOUNT} -gt 0 ]]; then node cli/dist/server createSiteAdmin "admin@growthtribe.nl" "GrowthTribe" "123456"; fi

# Special first time command that will run commands to initialize database and create account.
if [[ ${FIRST_TIME} -gt 0 ]]; then node cli/dist/server createSiteAdmin "admin@growthtribe.nl" "GrowthTribe" "123456" && yarn migrate; fi

# No defaults because this is set in entry point.
if [[ "${SERVICE_TYPE}" == "ui" ]]; then pm2 start pm2/worker.json && pm2 start pm2/ui.json; fi
if [[ "${SERVICE_TYPE}" == "api" ]]; then pm2 start pm2/worker.json && pm2 start pm2/api.json; fi

# For all other commands pass through to terminal.
if [[ $# -eq 1 && $1 == "bash" ]]; then
  $@;
else
  exec "$@";
fi
