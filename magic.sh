#!/bin/sh

# Change vars
PASSWORD=admin
USERNAME=admin
NUMBER_OF_BACKUPS=30
ROUTER_HOST=192.168.1.1
DATE=$(date +'%d-%m-%Y')
FULLDATE=$(date +'%d-%m-%Y-%H:%M:%S')
ELK_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Optional logging to elasticsearch (0 = disable)
ENABLE_LOGGING=0
HOSTNAME_ELK=HOSTNAME:9200

#system var
ERROR_CODE=1

# DO BACKUP
sshpass -p "${PASSWORD}" ssh "${USERNAME}@${ROUTER_HOST}" 'show running-config' > /opt/temp
if [ $? -eq 0 ]
then
  ERROR_CODE=0
  mv /opt/temp "/opt/keenetic-backup-${DATE}.txt"
fi

count=$(ls -latc /opt/*.txt | wc -l)
# Check backup count
if [ ${count} -gt ${NUMBER_OF_BACKUPS} ]
then
  file_to_del=$(find /opt/*.txt -type f -print0 | xargs -0 ls -ltr | head -n 1 | awk '{ print $9}')
  # remove oldest file
  rm -rf "${file_to_del}"
fi

# Backup complete success alert to elk
if [ ${ERROR_CODE} -eq 0 ] && [ ${ENABLE_LOGGING} -eq 1 ]
then
curl -XPOST ${HOSTNAME_ELK}/router/_doc/ -H 'Content-Type: application/json' -d "{
  \"@timestamp\": \"${ELK_TIME}\",
  \"Service\": \"router_backuper\",
  \"Message\": \"Backup is success at ${FULLDATE}\",
  \"BackupsCount\": ${count},
  \"Level\": \"INFO\"
}"
fi

# Backup complete error to ELk
if [ ${ERROR_CODE} -ne 0 ] && [ ${ENABLE_LOGGING} -eq 1 ]
then
curl -XPOST ${HOSTNAME_ELK}/router/_doc/ -H 'Content-Type: application/json' -d "{
  \"@timestamp\": \"${ELK_TIME}\",
  \"Service\": \"router_backuper\",
  \"Message\": \"ERROR ON BACKUP AS ${FULLDATE}\",
  \"BackupsCount\": ${count},
  \"Level\": \"ERROR\"
}"
fi