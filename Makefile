.PHONY: docker-build cookie
RABBITMQ_VERSION=3.6.14

all: cookie docker-build

cookie:
	echo "cookie monster" > .erlang.cookie

docker-build: cookie
	docker build --build-arg RABBITMQ_VERSION=$(RABBITMQ_VERSION) -t ansible/awx_rabbitmq:latest -t ansible/awx_rabbitmq:$(RABBITMQ_VERSION) .

clean:
	rm -f .erlang.cookie

