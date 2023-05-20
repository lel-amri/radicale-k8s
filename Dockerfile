# syntax=docker.io/docker/dockerfile:1.3
ARG PYTHON_BASE_IMAGE_NAME=docker.io/library/python
ARG PYTHON_BASE_IMAGE_TAG=3.11-slim-bullseye
ARG RADICALE_VERSION=3.1.8
FROM docker.io/library/python:3-slim-bullseye AS helper
ARG RADICALE_VERSION
RUN set -eux ;\
	apt-get update ;\
	apt-get install -y curl tar gzip ;
RUN set -eux ;\
	mkdir -p "/usr/src/radicale-${RADICALE_VERSION}" ;\
	cd "/usr/src/radicale-${RADICALE_VERSION}" ;\
	curl -Lo - "https://github.com/Kozea/Radicale/archive/refs/tags/v${RADICALE_VERSION}.tar.gz" | gunzip -c - | tar -xv --strip-components=1
RUN set -eux ;\
	pip install build wheel setuptools ;
RUN set -eux ;\
	cd "/usr/src/radicale-${RADICALE_VERSION}" ;\
	python -m build --wheel ;
FROM ${PYTHON_BASE_IMAGE_NAME}:${PYTHON_BASE_IMAGE_TAG}
ARG RADICALE_VERSION
COPY --from=helper /usr/src/radicale-${RADICALE_VERSION}/dist/*.whl /usr/src/radicale/dist/
RUN set -eux ;\
	set -- /usr/src/radicale/dist/*.whl ;\
	[ -e "$1" ] ;\
	pip install --no-cache "$1"[bcrypt] wsgi_lithium ;\
	rm -rf /usr/src/radicale ;
VOLUME ["/var/lib/radicale/collections"]
EXPOSE 80/tcp
CMD ["wsgi-lithium", "-b", "0.0.0.0:80", "radicale"]
