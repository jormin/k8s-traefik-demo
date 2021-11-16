#!/bin/bash

# music
cd music
rm -rf music
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o music main.go
docker build -t jormin/music:latest -f ./Dockerfile .
docker push jormin/music:latest

# video
cd ../video
rm -rf video
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o video main.go
docker build -t jormin/video:latest -f ./Dockerfile .
docker push jormin/video:latest