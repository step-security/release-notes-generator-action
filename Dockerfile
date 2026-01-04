FROM eclipse-temurin:25-jre-alpine-3.23@sha256:fa349bc80dc209c9e98e61e2cc5c7d09d00d9e1abc23a5caec8a0ae78d49a4a1
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
