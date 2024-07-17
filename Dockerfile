FROM openjdk:8-alpine@sha256:94792824df2df33402f201713f932b58cb9de94a0cd524164a0f2283343547b3
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
