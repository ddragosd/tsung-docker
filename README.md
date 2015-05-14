tsung-docker
============
Docker image to run Tsung distributed load testing tool.

### Usage

This Docker container is designed to execute `Tsung` in 3 modes: `SINGLE`,  `MASTER` and `SLAVE`.

#### Single Mode
Use this single mode to test on the local box, with a single Tsung agent:

```
docker run \
   -v /local/tests:/usr/local/tsung ddragosd/tsung-docker:latest \
   -f /usr/local/tsung/mytest.xml \
   -r \"ssh -p 22\" start
```

In this mode you can use a single Tsung client
```<client host="localhost" cpu="1" use_controller_vm="true"> </client>```
Note the `-r` flag setting `ssh` port to `22`. This is needed as the SSH runs on port `22` inside the docker container.
In a `MASTER` / `SLAVE` scenarios, we'll have this port mapped to `21` as a convention.

#### Master Mode
This mode should be used on a local machine by mounting a folder containing the Tsung tests into the container, like in the following example:

```
docker run \
   -p 21:22 \
   -p 4369:4369 \
   -p 9001-9050:9001-9050 \
   -v /local/tests:/usr/local/tsung ddragosd/tsung-docker:latest \
   -f /usr/local/tsung/mytest.xml start
```

where `/local/tests` is a folder containing an XML file `mytest.xml`.

* Note: Master Node has to be accessible from all the Slave nodes. Be aware of this when running behind a firewall.

#### Slave Mode
Use this mode in the distributed mode. All the agents that the `MASTER` Tsung needs to connect to must be started in this mode.
By convention, the Agents run SSHD on port `21` b/c port `22` might be taken by the hosts running the docker service. For this reason, in order to avoid conflicts, the agents expose ssh on port `21`.
Erlang needs port `4369` open as its [EPMD](http://www.erlang.org/doc/man/epmd.html) Port and all Slaves and Master nodes need to be able to use this port.
Erlang also uses other ports for communication and this container exposes ports in the range `9001-9050`.

To start a Docker container in the Slave mode issue the following command:

```
docker run \
   -p 21:22 \
   -p 4369:4369 \
   -p 9001-9050:9001-9050 \
   -e "SLAVE=true" \
   ddragosd/tsung-docker:latest
```

#### Running Tsung in a static environment
When you know the IPs of the nodes running Tsung you can manually expose them to docker through the `--add-host` parameter.

For the master node you can use:
```
docker run -d \
  -p 21:22 \
  -p 4369:4369 \
  -p 9001-9050:9001-9050 \
  --add-host tsung_slave1:10.132.35.108 \
  --add-host tsung_slave2:10.132.35.109 \
  --add-host target:10.132.35.110 \
  -h tsung_master \
  --name tsung \
  ddragosd/tsung-docker:latest -f /usr/local/tsung/tsung.xml start
```

And for the tsung-slave nodes:

```
docker run -d \
  -p 21:22 \
  -p 4369:4369 \
  -p 9001-9050:9001-9050 \  
  -e "SLAVE=true" \
  -h tsung_slave1 \
  --add-host tsung_master:10.132.35.107 \
  --add-host target:10.132.35.110 \
  --name tsung_slave \
  ddragosd/tsung-docker:latest
```

### Running in Apache Mesos and Marathon

![image](https://cloud.githubusercontent.com/assets/541933/7624252/9e98b2d2-f99a-11e4-9cdc-828fee71c30e.png)

The main purpose of running a Docker container with Tsung is the ease of scale and Mesos with Marathon have great support for this.
The containers need Marathon's base URL in order to auto-discover the nodes in the cluster; this is set in an environment variable : `MARATHON_URL`. 

* First step is to start the `tsung-master` node. It should be a single node.
The configuration is almost identical to the Slaves with 2 differences: `id` and `parameters`.

It's recommended to also mount a volume from the host machine to `/usr/local/tsung` inside the container and place the tsung logs in there.
You can then expose that data via a web-server such as `nginx`. The directory on the host must be specified as an absolute path and if the directory doesn't exist Docker should automatically create it for you.

Use Marathon API to make a POST to `http://<marathon-url>/v2/apps`
```javascript
{
  "id": "tsung-master",
  "container": {
    "type": "DOCKER",
     "volumes": [
         {
             "containerPath": "/usr/local/tsung",
             "hostPath": "/media/ephemeral0/var/log/tsung",
             "mode": "RW"
         }
     ],
    "docker": {
      "image": "ddragosd/tsung-docker:latest",
      "network": "BRIDGE",
      "portMappings": [
        { "containerPort": 22, "hostPort": 21, "protocol": "tcp" },
        { "containerPort": 4369, "hostPort": 4369, "protocol": "tcp" },
        { "containerPort": 9001, "hostPort": 9001, "protocol": "tcp" },
        { "containerPort": 9002, "hostPort": 9002, "protocol": "tcp" },
        { "containerPort": 9003, "hostPort": 9003, "protocol": "tcp" },
        { "containerPort": 9004, "hostPort": 9004, "protocol": "tcp" },
        { "containerPort": 9005, "hostPort": 9005, "protocol": "tcp" },
        { "containerPort": 9006, "hostPort": 9006, "protocol": "tcp" },
        { "containerPort": 9007, "hostPort": 9007, "protocol": "tcp" },
        { "containerPort": 9008, "hostPort": 9008, "protocol": "tcp" },
        { "containerPort": 9009, "hostPort": 9009, "protocol": "tcp" },
        { "containerPort": 9010, "hostPort": 9010, "protocol": "tcp" },
        { "containerPort": 9011, "hostPort": 9011, "protocol": "tcp" },
        { "containerPort": 9012, "hostPort": 9012, "protocol": "tcp" },
        { "containerPort": 9013, "hostPort": 9013, "protocol": "tcp" },
        { "containerPort": 9014, "hostPort": 9014, "protocol": "tcp" },
        { "containerPort": 9015, "hostPort": 9015, "protocol": "tcp" },
        { "containerPort": 9016, "hostPort": 9016, "protocol": "tcp" },
        { "containerPort": 9017, "hostPort": 9017, "protocol": "tcp" },
        { "containerPort": 9018, "hostPort": 9018, "protocol": "tcp" },
        { "containerPort": 9019, "hostPort": 9019, "protocol": "tcp" },
        { "containerPort": 9020, "hostPort": 9020, "protocol": "tcp" },
        { "containerPort": 9021, "hostPort": 9021, "protocol": "tcp" },
        { "containerPort": 9022, "hostPort": 9022, "protocol": "tcp" },
        { "containerPort": 9023, "hostPort": 9023, "protocol": "tcp" },
        { "containerPort": 9024, "hostPort": 9024, "protocol": "tcp" },
        { "containerPort": 9025, "hostPort": 9025, "protocol": "tcp" },
        { "containerPort": 9026, "hostPort": 9026, "protocol": "tcp" },
        { "containerPort": 9027, "hostPort": 9027, "protocol": "tcp" },
        { "containerPort": 9028, "hostPort": 9028, "protocol": "tcp" },
        { "containerPort": 9029, "hostPort": 9029, "protocol": "tcp" },
        { "containerPort": 9030, "hostPort": 9030, "protocol": "tcp" },
        { "containerPort": 9031, "hostPort": 9031, "protocol": "tcp" },
        { "containerPort": 9032, "hostPort": 9032, "protocol": "tcp" },
        { "containerPort": 9033, "hostPort": 9033, "protocol": "tcp" },
        { "containerPort": 9034, "hostPort": 9034, "protocol": "tcp" },
        { "containerPort": 9035, "hostPort": 9035, "protocol": "tcp" },
        { "containerPort": 9036, "hostPort": 9036, "protocol": "tcp" },
        { "containerPort": 9037, "hostPort": 9037, "protocol": "tcp" },
        { "containerPort": 9038, "hostPort": 9038, "protocol": "tcp" },
        { "containerPort": 9039, "hostPort": 9039, "protocol": "tcp" },
        { "containerPort": 9040, "hostPort": 9040, "protocol": "tcp" },
        { "containerPort": 9041, "hostPort": 9041, "protocol": "tcp" },
        { "containerPort": 9042, "hostPort": 9042, "protocol": "tcp" },
        { "containerPort": 9043, "hostPort": 9043, "protocol": "tcp" },
        { "containerPort": 9044, "hostPort": 9044, "protocol": "tcp" },
        { "containerPort": 9045, "hostPort": 9045, "protocol": "tcp" },
        { "containerPort": 9046, "hostPort": 9046, "protocol": "tcp" },
        { "containerPort": 9047, "hostPort": 9047, "protocol": "tcp" },
        { "containerPort": 9048, "hostPort": 9048, "protocol": "tcp" },
        { "containerPort": 9049, "hostPort": 9049, "protocol": "tcp" },
        { "containerPort": 9050, "hostPort": 9050, "protocol": "tcp" }
     ],
      "parameters": [
          { "key": "hostname", "value": "tsung_master" }
      ]
    }
  },
  "cpus": 1,
  "mem": 2048.0,
  "env": {
    "SLAVE": "true",
    "MARATHON_URL":"http://<marathon-host>:8080"
  },
  "constraints": [
    [
      "hostname",
      "UNIQUE"
    ]
  ],
  "ports": [
    21,
    4369,
    9001,9002,9003,9004,9005,9006,9007,9008,9009,9010,
    9011,9012,9013,9014,9015,9016,9017,9018,9019,9020,
    9021,9022,9023,9024,9025,9026,9027,9028,9029,9030,
    9031,9032,9033,9034,9035,9036,9037,9038,9039,9040,
    9041,9042,9043,9044,9045,9046,9047,9048,9049,9050
  ],
  "instances": 1
}
```

* Once the master is up and running you can start the slave nodes:


```javascript
{
  "id": "tsung-slaves",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "ddragosd/tsung-docker:latest",
      "network": "BRIDGE",
      "portMappings": [
        { "containerPort": 22, "hostPort": 21, "protocol": "tcp" },
        { "containerPort": 4369, "hostPort": 4369, "protocol": "tcp" },
        { "containerPort": 9001, "hostPort": 9001, "protocol": "tcp" },
        { "containerPort": 9002, "hostPort": 9002, "protocol": "tcp" },
        { "containerPort": 9003, "hostPort": 9003, "protocol": "tcp" },
        { "containerPort": 9004, "hostPort": 9004, "protocol": "tcp" },
        { "containerPort": 9005, "hostPort": 9005, "protocol": "tcp" },
        { "containerPort": 9006, "hostPort": 9006, "protocol": "tcp" },
        { "containerPort": 9007, "hostPort": 9007, "protocol": "tcp" },
        { "containerPort": 9008, "hostPort": 9008, "protocol": "tcp" },
        { "containerPort": 9009, "hostPort": 9009, "protocol": "tcp" },
        { "containerPort": 9010, "hostPort": 9010, "protocol": "tcp" },
        { "containerPort": 9011, "hostPort": 9011, "protocol": "tcp" },
        { "containerPort": 9012, "hostPort": 9012, "protocol": "tcp" },
        { "containerPort": 9013, "hostPort": 9013, "protocol": "tcp" },
        { "containerPort": 9014, "hostPort": 9014, "protocol": "tcp" },
        { "containerPort": 9015, "hostPort": 9015, "protocol": "tcp" },
        { "containerPort": 9016, "hostPort": 9016, "protocol": "tcp" },
        { "containerPort": 9017, "hostPort": 9017, "protocol": "tcp" },
        { "containerPort": 9018, "hostPort": 9018, "protocol": "tcp" },
        { "containerPort": 9019, "hostPort": 9019, "protocol": "tcp" },
        { "containerPort": 9020, "hostPort": 9020, "protocol": "tcp" },
        { "containerPort": 9021, "hostPort": 9021, "protocol": "tcp" },
        { "containerPort": 9022, "hostPort": 9022, "protocol": "tcp" },
        { "containerPort": 9023, "hostPort": 9023, "protocol": "tcp" },
        { "containerPort": 9024, "hostPort": 9024, "protocol": "tcp" },
        { "containerPort": 9025, "hostPort": 9025, "protocol": "tcp" },
        { "containerPort": 9026, "hostPort": 9026, "protocol": "tcp" },
        { "containerPort": 9027, "hostPort": 9027, "protocol": "tcp" },
        { "containerPort": 9028, "hostPort": 9028, "protocol": "tcp" },
        { "containerPort": 9029, "hostPort": 9029, "protocol": "tcp" },
        { "containerPort": 9030, "hostPort": 9030, "protocol": "tcp" },
        { "containerPort": 9031, "hostPort": 9031, "protocol": "tcp" },
        { "containerPort": 9032, "hostPort": 9032, "protocol": "tcp" },
        { "containerPort": 9033, "hostPort": 9033, "protocol": "tcp" },
        { "containerPort": 9034, "hostPort": 9034, "protocol": "tcp" },
        { "containerPort": 9035, "hostPort": 9035, "protocol": "tcp" },
        { "containerPort": 9036, "hostPort": 9036, "protocol": "tcp" },
        { "containerPort": 9037, "hostPort": 9037, "protocol": "tcp" },
        { "containerPort": 9038, "hostPort": 9038, "protocol": "tcp" },
        { "containerPort": 9039, "hostPort": 9039, "protocol": "tcp" },
        { "containerPort": 9040, "hostPort": 9040, "protocol": "tcp" },
        { "containerPort": 9041, "hostPort": 9041, "protocol": "tcp" },
        { "containerPort": 9042, "hostPort": 9042, "protocol": "tcp" },
        { "containerPort": 9043, "hostPort": 9043, "protocol": "tcp" },
        { "containerPort": 9044, "hostPort": 9044, "protocol": "tcp" },
        { "containerPort": 9045, "hostPort": 9045, "protocol": "tcp" },
        { "containerPort": 9046, "hostPort": 9046, "protocol": "tcp" },
        { "containerPort": 9047, "hostPort": 9047, "protocol": "tcp" },
        { "containerPort": 9048, "hostPort": 9048, "protocol": "tcp" },
        { "containerPort": 9049, "hostPort": 9049, "protocol": "tcp" },
        { "containerPort": 9050, "hostPort": 9050, "protocol": "tcp" }
      ]
    }
  },
  "cpus": 4,
  "mem": 4096.0,
  "env": {
    "SLAVE": "true",
    "MARATHON_URL":"http://<marathon-host>:8080"
  },
  "constraints": [
    [
      "hostname",
      "UNIQUE"
    ]
  ],
  "ports": [
    21,
    4369,
    9001,9002,9003,9004,9005,9006,9007,9008,9009,9010,
    9011,9012,9013,9014,9015,9016,9017,9018,9019,9020,
    9021,9022,9023,9024,9025,9026,9027,9028,9029,9030,
    9031,9032,9033,9034,9035,9036,9037,9038,9039,9040,
    9041,9042,9043,9044,9045,9046,9047,9048,9049,9050
  ],
  "instances": 2
}
```

#### Exposing Tsung test results from Master via Nginx

Use Marathon API to make a POST to `http://<marathon-url>/v2/apps`
Note: This container should run on the same host where `tsung-master` runs.
You can use [constraints](https://github.com/mesosphere/marathon/blob/master/docs/docs/constraints.md) to achieve that.


```javascript
{
  "id": "tsung-nginx",
  "container": {
    "type": "DOCKER",
     "volumes": [
         {
             "containerPath": "/usr/share/nginx/html/tsung",
             "hostPath": "/media/ephemeral0/var/log/tsung",
             "mode": "RO"
         }
     ],
    "docker": {
      "image": "nginx",
      "network": "BRIDGE",
      "portMappings": [
        { "containerPort": 80, "hostPort": 80, "protocol": "tcp" }
      ]
    }
  },
  "cpus": 1,
  "mem": 1024.0,
  "constraints": [],
  "ports": [
    80
  ],
  "instances": 1
}
```

By default the nginx server does not index directories. To fix this you can ssh into the docker container and execute:
```
sed -i s/"htm;"/"htm; autoindex on;"/g /etc/nginx/conf.d/default.conf
nginx -s reload
```
