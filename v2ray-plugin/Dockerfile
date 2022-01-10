FROM alpine AS downloader
WORKDIR /work
COPY install.sh /
RUN /install.sh

FROM scratch
COPY --from=downloader /work /
ENTRYPOINT ["/v2ray-plugin"]
