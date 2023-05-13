FROM node:16.20.0-alpine

LABEL maintainer="Ryo Ota <nwtgck@nwtgck.org>"

ARG USERNAME=nonroot
ARG USER_UID=10001
ARG USER_GID=$USER_UID

RUN apk add --no-cache tini \
    && addgroup -g $USER_GID -S $USERNAME \
    && adduser -u $USER_UID -G $USERNAME -S $USERNAME

COPY . /app

# Move to /app
WORKDIR /app

# Install requirements, build and remove devDependencies
# (from: https://stackoverflow.com/a/25571391/2885946)
RUN npm ci && \
    npm run build && \
    npm prune --production && \
    npm cache clean --force

USER 10001

# Run a server
ENTRYPOINT [ "tini", "--", "node", "dist/src/index.js" ]
