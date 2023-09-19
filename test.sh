# create a image 

docker buildx build --build-arg IDRIS_VERSION=latest --file base.Dockerfile --tag base-v0.6.0:base --load .

docker buildx build --build-arg BASE_IMG=base-v0.6.0:base --file debian.Dockerfile --load .
