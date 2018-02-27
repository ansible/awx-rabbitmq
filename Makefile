.PHONY: docker-build
RABBITMQ_VERSION=3.6.14

all: cookie docker-build

.erlang.cookie:

cookie: .erlang.cookie
	echo "cookie monster" > .erlang.cookie

docker-build:
	docker build --build-arg RABBITMQ_VERSION=$(RABBITMQ_VERSION) -t ansible/awx_rabbitmq:latest -t ansible/awx_rabbitmq:$(RABBITMQ_VERSION) .

clean:
	rm -f .erlang.cookie

