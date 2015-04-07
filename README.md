tsung-docker
============
Docker image to run Tsung distributed load testing tool.

### Usage

This Docker container is designed to execute `Tsung` in 3 modes: `SINGLE`,  `MASTER` and `SLAVE`.

#### Single Mode
Use this single mode to test on the local box, with a single Tsung agent:

```
docker run -v /local/tests:/usr/local/tsung ddragosd/tsung-docker:latest -f /usr/local/tsung/mytest.xml -r \"ssh -p 22\" start
```

In this mode you can use a single Tsung client
```<client host="localhost" cpu="1" use_controller_vm="true"> </client>```
Note the `-r` flag setting `ssh` port to `22`. This is needed as the SSH runs on port `22` inside the docker container.
In a `MASTER` / `SLAVE` scenarios, we'll have this port mapped to `21` as a convention.

#### Master Mode
This mode should be used on a local machine by mounting a folder containing the Tsung tests into the container, like in the following example:

```
docker run -p 21:22 -p 4369:4369 -v /local/tests:/usr/local/tsung ddragosd/tsung-docker:latest -f /usr/local/tsung/mytest.xml start
```

where `/local/tests` is a folder containing an XML file `mytest.xml`.

* Note: Master Node has to be accessible from all the Slave nodes. Be aware of this when running behind a firewall.

#### Slave Mode
Use this mode in the distributed mode. All the agents that the `MASTER` Tsung needs to connect to must be started in this mode.
By convention, the Agents run SSHD on port 21 b/c port 22 might be taken by the hosts running the docker service. For this reason, in order to avoid conflicts, the agents expose ssh on port 21.
Erlang also needs port `4369` open as its [EPMD](http://www.erlang.org/doc/man/epmd.html) Port and all the Slaves and Master need to be able to talk on this port.

To start a Docker container in the Slave mode issue the following command:

```
docker run -p 21:22 -p 4369:4369 -e "SLAVE=true" ddragosd/tsung-docker:latest
```

### Running in Apache Mesos and Marathon
TBD