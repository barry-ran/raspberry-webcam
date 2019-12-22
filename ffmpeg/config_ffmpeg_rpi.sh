#!/bin/sh
PREFIX=/usr/local
./configure \
--enable-gpl    --enable-version3 --enable-nonfree \
--enable-static --disable-shared \
\
--prefix=$PREFIX \
\
--disable-opencl \
--disable-thumb \
--disable-pic \
--disable-stripping \
\
--enable-small \
\
--enable-ffmpeg \
--enable-ffplay \
--enable-ffprobe \
\
--disable-doc \
--disable-htmlpages \
--disable-podpages \
--disable-txtpages \
--disable-manpages \
\
--disable-everything \
\
--enable-libx264 \
--enable-encoder=libx264 \
--enable-decoder=h264 \
--enable-encoder=aac \
--enable-decoder=aac \
--enable-encoder=ac3 \
--enable-decoder=ac3 \
--enable-encoder=rawvideo \
--enable-decoder=rawvideo \
--enable-encoder=mjpeg \
--enable-decoder=mjpeg \
\
--enable-demuxer=concat \
--enable-muxer=flv \
--enable-demuxer=flv \
--enable-demuxer=live_flv \
--enable-muxer=hls \
--enable-muxer=segment \
--enable-muxer=stream_segment \
--enable-muxer=mov \
--enable-demuxer=mov \
--enable-muxer=mp4 \
--enable-muxer=mpegts \
--enable-demuxer=mpegts \
--enable-demuxer=mpegvideo \
--enable-muxer=matroska \
--enable-demuxer=matroska \
--enable-muxer=wav \
--enable-demuxer=wav \
--enable-muxer=pcm* \
--enable-demuxer=pcm* \
--enable-muxer=rawvideo \
--enable-demuxer=rawvideo \
--enable-muxer=rtsp \
--enable-demuxer=rtsp \
--enable-muxer=rtsp \
--enable-demuxer=sdp \
--enable-muxer=fifo \
--enable-muxer=tee \
--enable-muxer=image2 \
--enable-demuxer=image2 \ 
\
--enable-parser=h264 \
--enable-parser=aac \
\
--enable-protocol=file \
--enable-protocol=tcp \
--enable-protocol=rtmp \
--enable-protocol=cache \
--enable-protocol=pipe \
\
--enable-filter=aresample \
--enable-filter=allyuv \
--enable-filter=scale \
--enable-libfreetype \
\
--enable-indev=v4l2 \
--enable-indev=alsa \
\
--enable-omx \
--enable-omx-rpi \
--enable-encoder=h264_omx \
\
--enable-mmal \
--enable-hwaccel=h264_mmal \
--enable-decoder=h264_mmal \
\