.PHONY: docker-build
RABBITMQ_VERSION=3.7.4

all: docker-build

docker-build:
	docker build --no-cache --build-arg RABBITMQ_VERSION=$(RABBITMQ_VERSION) -t ansible/awx_rabbitmq:latest -t ansible/awx_rabbitmq:$(RABBITMQ_VERSION) .

