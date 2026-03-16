#!/bin/sh
# Pre-initialize the PostgreSQL cluster if needed.
# Works around embedded-postgres library's initialise() failing in containers.
PGDATA="/paperclip/instances/default/db"
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "Pre-initializing PostgreSQL cluster at $PGDATA ..."
  rm -rf "$PGDATA"
  INITDB=$(find /app -path "*/@embedded-postgres/linux-x64*" -name "initdb" | head -1)
  "$INITDB" --pgdata="$PGDATA" --encoding=UTF8 --locale=C --username=paperclip
  echo "PostgreSQL cluster initialized (PG_VERSION=$(cat "$PGDATA/PG_VERSION"))"
fi

exec node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js
