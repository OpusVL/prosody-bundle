#!/bin/bash

data_dir_owner="$(stat -c %u "/var/lib/prosody/")"
if [[ "$(id -u prosody)" != "$data_dir_owner" ]]; then
    usermod -u "$data_dir_owner" prosody
fi
if [[ "$(stat -c %u /var/run/prosody/)" != "$data_dir_owner" ]]; then
    chown "$data_dir_owner" /var/run/prosody/
fi
if [[ "$(stat -c %u /var/log/prosody/)" != "$data_dir_owner" ]]; then
    chown "$data_dir_owner" /var/log/prosody/ -R
fi

/usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf