##################################################################################
#
# Docker image with Qt6 QML tooling for CI/CD pipelines.
# Provides qmllint (QML linter) and qsb (Qt Shader Baker).
#
# NOTE: Changes to this file automatically trigger a rebuild and push
# of the image to GHCR (see docker-qt6-tools.yml workflow).
#
# Author: Marcin Orlowski <mail (#) marcinOrlowski (.) com>
#
##################################################################################

FROM ubuntu:25.10

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        qt6-declarative-dev-tools \
        qt6-shader-baker \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Make Qt6 tools available on PATH
ENV PATH="/usr/lib/qt6/bin:${PATH}"
