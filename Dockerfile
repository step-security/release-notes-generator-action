FROM openjdk:18-alpine@sha256:e5c5b35b831a4f655074a25604130ce53e33567b82c8a7204f0e5641b66d477e
LABEL "maintainer"="step-security <security@stepsecurity.io>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.8"
ENV RELEASE_NOTE_GENERATOR_CHECKSUM="4ac5387565b3b6d050a6ecc7bc7188e7cf62bf464596603b233ece457a66be60"

COPY *.sh /
RUN chmod +x JSON.sh && \
    wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar && \
    echo "$RELEASE_NOTE_GENERATOR_CHECKSUM  github-release-notes-generator.jar" | sha256sum -c -

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
