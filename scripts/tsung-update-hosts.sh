#!/bin/sh

# update /etc/hosts : auto-discover tsung_slaves
# by convention look in Marathon API $(MARATHON_URL)/v2/apps/tsung-slaves

echo "Discovering Tsung Hosts ... "
echo `date`

# the names of the Marathon apps for slave and master nodes
tsung_slave_app_name=tsung-slaves
tsung_master_app_name=tsung-master
MARATHON_URL=$(cat /etc/tsung/marathon_url)

if [[ -n "${MARATHON_URL}" ]]; then
    echo "Discovering tsung-slaves ..."
    #1. discover new tsung_slaves
    curl -s ${MARATHON_URL}/v2/apps/${tsung_slave_app_name} | grep -Po '"host":"\K.*?(?=")' | xargs dig +short | awk '{ print $1" tsung_slave"NR}' > /etc/tsung/tsung_slaves_hosts.conf
    #2. clean-up previous discovered tsung_slaves
    sed -r '/tsung_slave/d' /etc/hosts > /etc/hosts-temp
    # docker down not allow modifying /etc/hosts and the next line works around that
    cat /etc/hosts-temp | tee /etc/hosts > /dev/null
    #3. append the new list to /etc/hosts
    cat /etc/tsung/tsung_slaves_hosts.conf >> /etc/hosts
    cat /etc/tsung/tsung_slaves_hosts.conf
    echo "Discovering tsung-master ..."
    #1. discover tsung_master
    curl -s ${MARATHON_URL}/v2/apps/${tsung_master_app_name} | grep -Po '"host":"\K.*?(?=")' | xargs dig +short | awk '{ print $1" tsung_master"}' > /etc/tsung/tsung_master_hosts.conf
    #2. clean-up previous discovered tsung_master
    sed -r '/tsung_master/d' /etc/hosts > /etc/hosts-temp
    # docker down not allow modifying /etc/hosts and the next line works around that
    cat /etc/hosts-temp | tee /etc/hosts > /dev/null
    #3. append the new list to /etc/hosts
    cat /etc/tsung/tsung_master_hosts.conf >> /etc/hosts
    cat /etc/tsung/tsung_master_hosts.conf
    echo "DONE."
fi

