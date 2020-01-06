### Keenetic config backup

##### Reqs
- keenetic router (all supported ssh-server)
- ssh-server installed
- ssh access to router
- docker (persistent volume)

##### Get Started

change variable in magic.sh
Set router username, password and ipAdd
```
PASSWORD=admin
USERNAME=admin
NUMBER_OF_BACKUPS=30
ROUTER_HOST=192.168.1.1
```

All backup will be in `/opt/` folder

RUN `docker build -t mybackup:latest .`
RUN `docker run -d -v /path/to/backup/folder:/opt mybackup:latest`

##### Why? 

A router often has many settings, network, users, accesses, routing rules, and more. If one unfortunate day the router dies, or it is accidentally (specially) reset to factory settings. You may be in a lot of pain. If you have a server (nat/virtual machine/cloud/raspberry pi) you can run a backup script that will add once a day (cron expression) the script of your entire configuration to the folder you need. Additionally, it is possible to send logs to the elc stack, or you can add the necessary notifications to monitor the progress of backups. You can also configure the total number of backups in the configuration


##### Optional

If you use elk stack for logging, you can enable simple logging in var `ENABLE_LOGGING=1`
You need set `HOSTNAME_ELK` to correct elk url + port `9200` as default.

##### License MIT



