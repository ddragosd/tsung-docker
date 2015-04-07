#!/bin/sh

# Utility to run tsung and automatically generate reports

# make sure SSHD is started in order to connect to other tsung agents
service sshd start

slave=$(echo $SLAVE)
if [[ -n "${slave}" ]]; then
    echo "Running in SLAVE mode ..."
    tail -f /var/log/tsung/tsung.log
    exit
fi

# http://stackoverflow.com/questions/2369341/which-tcp-port-does-erlang-use-for-connecting-to-a-remote-node
# erl -kernel inet_dist_listen_min 9001 inet_dist_listen_max 9005

current_date=$(date +%Y%m%d-%H%M)
echo "Tsung log directory should be ${current_date}"
cmd='tsung -l /usr/local/tsung/ '$@
echo "Executin ${cmd} ..."
${cmd}
cd /usr/local/tsung/${current_date}/ && /usr/lib64/tsung/bin/tsung_stats.pl

