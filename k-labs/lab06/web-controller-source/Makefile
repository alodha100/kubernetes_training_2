build:
	CGO_ENABLED=0 GOOS=linux go build -o website-controller -a pkg/website-controller.go

image: build
	docker build -t stv707/website-controller .

push: image
	docker push stv707/website-controller:latest
