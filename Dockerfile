FROM eclipse-temurin:25-jre-alpine-3.23@sha256:c707c0d18cb9e8556380719f80d96a7529d0746fbb42143893949b98ed2f8943
LABEL "maintainer"="step-security <security@stepsecurity.io>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.14"
ENV RELEASE_NOTE_GENERATOR_CHECKSUM="e5ca69af07325023c0f0f9b74ccb5a346113a93d7165a356eb0af4f06bb29ebb"

COPY *.sh /
RUN apk upgrade --no-cache && \
    apk add --no-cache curl jq && \
    chmod +x JSON.sh && \
    wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar && \
    echo "$RELEASE_NOTE_GENERATOR_CHECKSUM  github-release-notes-generator.jar" | sha256sum -c -

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
