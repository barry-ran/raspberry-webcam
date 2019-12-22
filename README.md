# raspberry-webcam
树莓派网络摄像头监控

/usr/local/bin/ffmpeg -ss 0 -t 100 -pix_fmt yuv420p -i /dev/video0 -c:v h264_omx -f flv rtmp://192.168.0.111:1935/hls

https://gitee.com/andyspider/Camkit 支持硬件编解码，比较小众，缺少维护
