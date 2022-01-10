FROM alpine AS downloader
WORKDIR /
COPY install.sh /
RUN /install.sh

FROM scratch
COPY --from=downloader /work /
ENTRYPOINT ["/frps"]
CMD ["-c", "/conf/frps.ini"]
