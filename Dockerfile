FROM alpine:3.10 AS ffmpeg_builder

WORKDIR /app/ffmpeg

ENV FFMPEG_VERSION=4.1.4
ENV FFMPEG_VERSION_URL=http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
ENV PREFIX=/app/ffmpeg/install

RUN cd && \
apk update && \
apk upgrade && \
apk --no-cache add freetype-dev \
  gnutls-dev \
  lame-dev \
  libass-dev \
  libogg-dev \
  libtheora-dev \
  libvorbis-dev \
  libvpx-dev \
  libwebp-dev \
  libssh2 \
  opus-dev \
  rtmpdump-dev \
  x264-dev \
  x265-dev \
  soxr-dev \
  yasm-dev && \
apk add --no-cache   --virtual \
  .build-dependencies \
  build-base \
  bzip2 \
  coreutils \
  gnutls \
  nasm \
  tar \
  x264 && \
apk add fdk-aac-dev --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
TMP_DIR=$(mktemp -d) && \
cd ${TMP_DIR} && \
wget ${FFMPEG_VERSION_URL} && \
tar xjvf ffmpeg-${FFMPEG_VERSION}.tar.bz2  && \
cd ffmpeg* && \
./configure --prefix="$PREFIX" --disable-debug  --disable-doc \
  --disable-ffplay \
  --enable-avresample \
  --enable-gnutls \
  --enable-gpl \
  --enable-libass \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-librtmp \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libsoxr \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libfdk-aac \
  --enable-nonfree \
  --enable-postproc \
  --enable-small \
  --enable-version3 && \
make && \
make install && \
make distclean && \
rm -rf ${TMP_DIR}  && \
apk del --purge .build-dependencies && \
rm -rf /var/cache/apk/*

FROM alpine:3.10

WORKDIR /app

COPY --from=ffmpeg_builder /app/ffmpeg/install/lib /usr/lib/
COPY --from=ffmpeg_builder /app/ffmpeg/install/bin /usr/bin/
COPY --from=ffmpeg_builder \
  /usr/lib/libx265.so.169 \
  /usr/lib/libx264.so.152  \
  /usr/lib/libwebpmux.so.3  \
  /usr/lib/libwebp.so.7  \
  /usr/lib/libvpx.so.6  \
  /usr/lib/libvorbisfile.so.3 \
  /usr/lib/libvorbisenc.so.2  \
  /usr/lib/libvorbis.so.0  \
  /usr/lib/libtheoraenc.so.1  \
  /usr/lib/libtheoradec.so.1  \
  /usr/lib/libsoxr.so.0  \
  /usr/lib/librtmp.so.1  \
  /lib/libz.so.1  \
  /lib/libuuid.so.1.3.0 \
  /usr/lib/libopus.so.0  \
  /usr/lib/libmp3lame.so.0  \
  /usr/lib/libfreetype.so.6  \
  /usr/lib/libass.so.9  \
  /usr/lib/libgnutls.so.30  \
  /lib/ld-musl-x86_64.so.1  \
  /usr/lib/libstdc++.so.6  \
  /usr/lib/libogg.so.0  \
  /usr/lib/libgomp.so.1  \
  /usr/lib/libbz2.so.1  \
  /usr/lib/libpng16.so.16  \
  /usr/lib/libfribidi.so.0  \
  /usr/lib/libfontconfig.so.1  \
  /usr/lib/libp11-kit.so.0  \
  /usr/lib/libunistring.so.2  \
  /usr/lib/libtasn1.so.6  \
  /usr/lib/libnettle.so.6  \
  /usr/lib/libhogweed.so.4  \
  /usr/lib/libgmp.so.10  \
  /usr/lib/libgcc_s.so.1  \
  /usr/lib/libexpat.so.1  \
  /usr/lib/libffi.so.6  \
  /usr/lib/libfdk-aac.so.2 \
  /usr/lib/

RUN ln -s /usr/lib/libuuid.so.1.3.0 /usr/lib/libuuid.so.1
