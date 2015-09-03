docker:
	docker build -t ddragosd/tsung-docker .

.PHONY: docker-ssh
docker-ssh:
	docker run -p 8091:8091 -ti --entrypoint='bash' ddragosd/tsung-docker:latest

.PHONY: docker-run
docker-run:
	docker run -p 21:22 -p 8091:8091 ddragosd/tsung-docker:latest

.PHONY: docker-attach
docker-attach:
	docker exec -i -t tsung-agent bash

.PHONY: docker-stop
docker-stop:
	docker stop tsung-agent
	docker rm tsung-agent



