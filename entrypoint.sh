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
  if [ -z "${XPRA_USER}" ] && [ -z "${XPRA_PASSWORD}" ]; then
    ${XPRA}
  else
    #Credentials have been provided so create password file and link to it
    python3 /usr/lib/python3/dist-packages/xpra/server/auth/sqlite_auth.py /home/user/auth.sdb create
    python3 /usr/lib/python3/dist-packages/xpra/server/auth/sqlite_auth.py /home/user/auth.sdb add ${XPRA_USER} ${XPRA_PASSWORD}
    XPRA="${XPRA} --auth=sqlite:filename=/home/user/auth.sdb --ws-auth=sqlite:filename=/home/user/auth.sdb --tcp-auth=sqlite:filename=/home/user/auth.sdb"
    ${XPRA}
  fi

  xvfb-run --server-args="-screen 0, 1600x1200x24 -displayfd ${DISPLAY}"
else
  ${CMD}
fi
