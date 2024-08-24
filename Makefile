IMAGE_REPOSITORY=thelande
IMAGE_NAME=7dtd
IMAGE_TAG=0.4.7

all::

.PHONY: nerdctl-build
nerdctl-build:  ## Build the image using nerdctl
	nerdctl -n k8s.io build -t $(IMAGE_REPOSITORY)/$(IMAGE_NAME):$(IMAGE_TAG) .
