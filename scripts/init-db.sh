#!/bin/bash

#chown -R monetdb:monetdb /var/monetdb5

FARMDIR=/var/monetdbdata/db

if [ ! -d "${FARMDIR}" ]; then
   monetdbd create ${FARMDIR}
   monetdbd set listenaddr=0.0.0.0 ${FARMDIR}

   monetdbd start ${FARMDIR}

   sleep 5
   if [ ! -d "${FARMDIR}/db" ]; then
      monetdb create db && \
      monetdb set embedr=true db && \
      monetdb release db
   else
      echo "Existing database found in '${FARMDIR}/db'"
   fi

   for i in {30..0}; do
      echo 'Testing MonetDB connection ' $i
      mclient -d db -s 'SELECT 1' &> /dev/null
      if [ $? -ne 0 ] ; then
        echo 'Waiting for MonetDB to start...'
        sleep 1
      else
        echo 'MonetDB is running'
        break
      fi
   done
   if [ $i -eq 0 ]; then
      echo >&2 'MonetDB startup failed'
      exit 1
   fi

   monetdbd stop ${FARMDIR}
   sleep 5
#mkdir -p /var/log/monetdb
#chown -R monetdb:monetdb /var/log/monetdb

   echo "Initialization done"

fi
