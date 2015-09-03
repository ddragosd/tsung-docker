#!/bin/sh

# Utility to run tsung and automatically generate reports

# configure the SSH port used to connect to tsung agents before starting sshd
erl_ssh_port=${ERL_SSH_PORT:-21}
echo "SSH will connect on Port ${erl_ssh_port} with Tsung Agents ... "
sed -i 's/Port [0-9]*/Port '${erl_ssh_port}'/' /root/.ssh/config
echo "SSH Config:"
cat /root/.ssh/config

# make sure SSHD is started in order to connect to other tsung agents
service sshd start

# start crontab to update tsung hosts found in the cluster
echo ${MARATHON_URL} > /etc/tsung/marathon_url
crontab /etc/crontab
service crond start


slave=$(echo $SLAVE)
if [[ -n "${slave}" ]]; then
    echo "Running in SLAVE mode ..."
    tail -f /var/log/tsung/tsung-update-hosts.log
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

