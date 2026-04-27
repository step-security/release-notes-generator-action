FROM eclipse-temurin:25-jre-alpine-3.23@sha256:2d3cd2323c18a9a8073935503f0a1733b6c45b455b94f23294c3df336240fde7
LABEL "maintainer"="step-security <security@stepsecurity.io>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.13"
ENV RELEASE_NOTE_GENERATOR_CHECKSUM="afc30f5000e6bb6773f51dc8c8f7579e6e9a4edb27cd874144bc0575270783bc"

COPY *.sh /
RUN apk add --no-cache curl jq && \
    chmod +x JSON.sh && \
    wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar && \
    echo "$RELEASE_NOTE_GENERATOR_CHECKSUM  github-release-notes-generator.jar" | sha256sum -c -

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
