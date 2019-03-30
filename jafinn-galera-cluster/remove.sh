#!/bin/bash

sudo docker service rm $(sudo docker service ls -q)
sudo docker volume rm $(sudo docker volume ls -q)
sudo docker system prune --force
sudo docker swarm leave --force
