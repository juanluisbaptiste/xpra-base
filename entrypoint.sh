#!/bin/bash

#Read env variables set by derived containers.
if [ -f .envrc ]; then
  . .envrc
fi

if [ "${DEBUG}" == "yes" ]; then
  env
  set -x
fi

if [ "${CMD}" == "" ]; then
  echo "ERROR: No command specified." && exit 1
fi

#Use Xpra to enable access through a web browser
if [ "${ENABLE_WEB_VIEW}" == "yes" ]; then

  XPRA="xpra start --bind-tcp=0.0.0.0:${WEB_VIEW_PORT} --html=on --start=${CMD} --daemon=no --pulseaudio=no --notifications=no --bell=no"

  #Check if credentials have been provided
  if [ -z "${XPRA_USER}" ] && [ -z "${XPRA_PASS}" ]; then
    ${XPRA}
  else
    #Credentials have been provided so create password file and link to it
    echo -n "${XPRA_USER}|${XPRA_PASS}" > ./credentials.txt
    XPRA="${XPRA} --auth=multifile:filename=./credentials.txt"
    ${XPRA}
  fi

  xvfb-run --server-args="-screen 0, 1600x1200x24 -displayfd ${DISPLAY}"
else
  ${CMD}
fi
