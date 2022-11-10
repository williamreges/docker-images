#!/bin/bash
docker run -d -p 15672:15672 -p 5672:5672 --hostname my-rabbit --name some-rabbit -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management
