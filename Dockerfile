FROM eclipse-temurin:25-jre-alpine-3.23@sha256:f10d6259d0798c1e12179b6bf3b63cea0d6843f7b09c9f9c9c422c50e44379ec
LABEL "maintainer"="step-security <security@stepsecurity.io>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.12"
ENV RELEASE_NOTE_GENERATOR_CHECKSUM="f42a5b90e3b3cc02c74d289b36af36c317c71d4be67d86f575cc3a853d9e3c7e"

COPY *.sh /
RUN apk add --no-cache curl && \
    chmod +x JSON.sh && \
    wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar && \
    echo "$RELEASE_NOTE_GENERATOR_CHECKSUM  github-release-notes-generator.jar" | sha256sum -c -

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
