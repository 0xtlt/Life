# Build Stage
# FROM ekidd/rust-musl-builder:latest AS builder
FROM rust:latest AS builder
ARG TYPE="devOwnMachine"
# We need to add the source code to the image because `rust-musl-builder`
# assumes a UID of 1000, but TravisCI has switched to 2000.

USER root

WORKDIR /
RUN cargo new --bin life

WORKDIR /life

# copy over your manifests
COPY --chown=rust:rust ./Cargo.lock ./Cargo.lock
COPY --chown=rust:rust ./Cargo.toml ./Cargo.toml

# If the $TYPE env var is ok, then run then cargo build
# RUN [ "$TYPE" = "devOwnMachine" ] && cargo build --release

# RUN if [ "$TYPE" = "devOwnMachine" ] && echo "devOwnMachine"

# this build step will cache your dependencies
RUN if [ "$TYPE" = "devOwnMachine" ]; then cargo build; fi
# RUN if ["$TYPE" == "devOwnMachine"]; then mv /life/target/debug/life /life-ex; fi
RUN if [ "$TYPE" = "dev" ]; then cargo build --target=x86_64-unknown-linux-musl; fi
# RUN if ["$TYPE" == "dev"]; then mv /life/target/x86_64-unknown-linux-musl/release/life /life-ex; fi
RUN if [ "$TYPE" = "release" ]; then cargo build --release --target=x86_64-unknown-linux-musl; fi
# RUN if ["$TYPE" == "release"]; then mv /life/target/x86_64-unknown-linux-musl/release/life /life-ex; fi

RUN rm src/*.rs

# copy your source tree
COPY --chown=rust:rust ./src ./src

# build
RUN if [ "$TYPE" = "devOwnMachine" ]; then cargo build; fi
RUN if [ "$TYPE" = "devOwnMachine" ]; then mv /life/target/debug/life /life-ex; fi
RUN if [ "$TYPE" = "dev" ]; then cargo build --target=x86_64-unknown-linux-musl; fi
RUN if [ "$TYPE" = "dev" ]; then mv /life/target/x86_64-unknown-linux-musl/release/life /life-ex; fi
RUN if [ "$TYPE" = "release" ]; then cargo build --release --target=x86_64-unknown-linux-musl; fi
RUN if [ "$TYPE" = "release" ]; then mv /life/target/x86_64-unknown-linux-musl/release/life /life-ex; fi

# Bundle Stage
FROM debian:buster
ARG DEBIAN_FRONTEND=noninteractive

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0

RUN apt-get update && \
    apt-get install -y \
      --no-install-recommends \
      net-tools \
      curl \
      socat \
      novnc \
      supervisor \
      x11vnc \
      xvfb \
      chromium && \
      ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 6080 9222


# Install xvfb in order to create a 'fake' display
RUN apt install screen -y
RUN apt install scrot -y

# Install java
RUN apt-get install default-jdk -y

# Install minecraft at /minecraft.jar
RUN mkdir /minecraft
RUN curl -L https://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar -o /minecraft/minecraft.jar

COPY --from=builder /life-ex /life

RUN chmod 777 /life

COPY init.sh /init.sh
RUN chmod 777 /init.sh

COPY screenshot.sh /screenshot.sh
RUN chmod 777 /screenshot.sh

COPY ./supervisord.conf /app/supervisord.conf

CMD "/init.sh"