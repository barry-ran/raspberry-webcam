# raspberry-webcam
树莓派网络摄像头监控

/usr/local/bin/ffmpeg -ss 0 -t 100 -pix_fmt yuv420p -i /dev/video0 -c:v h264_omx -f flv rtmp://192.168.0.111:1935/hls

# 环境
1. 操作系统：
2. apt-get更新或者安装某些包的时候可能需要翻墙

# CSI摄像头

## 安装摄像头并测试
1. 淘宝购买树莓派CSI摄像头，不用买官方正版，大约10多元
2. 摄像头自带PFC软排线，我们只需要把排线插入到树莓派摄像头CSI接口上（只有一个这种接口，看到排线就知道怎么插）
3. 启动树莓派并检查是否启动了摄像头

    命令行执行：
    ```
    sudo raspi-config
    ```
    以此选择"5 Interfacing options"-->"P1 Camera"-->"YES"

    之后会提示重新启动，重启完成后摄像头就可以使用了。

4. 测试摄像头是否正常使用

    命令行执行：
    ```
    raspistill -t 2000 -o image.jpg
    ```

    查看当前目录下image.jpg是否是正常画面

更多介绍可以参考[这里](https://blog.csdn.net/fhqlongteng/article/details/80433633)

## 摄像头实时监控
有以下要求：
1. 高帧率
2. 低延迟
3. 视频编码并RTP传输

### 调研结果
1. mjpg-stream - web可以直接访问，但是帧率太低，听说不支持CSI摄像头，只支持USB摄像头
2. vlc - 延迟高，大约2s-5s
3. raspivid - 延迟170ms左右，并h264编码，好像可以

    该工具已经默认集成到了树莓派之中
    ```
    raspivid -t 0 -w 1280 -h 720 -fps 20 -o - | nc -k -l 8090
    ```

    -t 表示延时；-o表示輸出；-fps 表示帧率；端口号为8090

    -w表示图像宽度;，-h 表示图像高度，此处设置的分辨率为1280*720；我们可以修改 -w 1920 -h 1080将分辨率设置为1920*1080

    该命令执行玩后不会出现任何打印信息即可

    在局域网内的linux主机上安装mplayer工具(sudo apt-get install mplayer)，然后执行命令
    
    ```
    mplayer -fps 200 -demuxer h264es ffmpeg://tcp://192.168.31.166:8090
    ```

    即会弹出一个显示树莓派实时视频流的窗口，而且延迟尚可，大概在200ms左右，基本上可以满足实时性的要求了。

4. [pistreaming](https://github.com/waveform80/pistreaming) - 性能也不错

    1. 安装依赖
        ```
        # 安装python3-picamera
        sudo apt-get install python3-picamera

        # 安装pip3
        sudo apt-get install python3-pip

        # 安装ws4py
        sudo pip3 install ws4py

        # 安装ffmpeg
        sudo apt-get install ffmpeg
        ```
    2. 下载源码
        ```
        git clone https://github.com/waveform80/pistreaming.git
        ```

    3. 测试效果
        ```
        # 进入源码目录
        cd pistreaming
        # 运行程序
        python3 server.py
        ```

        浏览器访问查看效果

        ```
        http://pi_ip:8082/index.html
        ```


5. [motion](https://motion-project.github.io/) - 卡顿很严重，延迟在30s+

6. [fswebcam](https://github.com/fsphil/fswebcam) - 采集摄像头数据保存为图片，用来做视频监控的话，性能和延迟都达不到要求

7. [Camkit](https://gitee.com/andyspider/Camkit) - 支持硬件编解码，比较小众，缺少维护

8. ffmpeg硬解码推流


### 参考文档
[树莓派上实现流媒体](https://blog.csdn.net/chiliaolm/article/details/51674691)

[树莓派摄像头推流的几种方式](https://blog.csdn.net/zz531987464/article/details/100087755)

[使用motion和mjpg做视频监控器](https://blog.csdn.net/u010900754/article/details/53097626/)

[Nginx部署RTMP流媒体服务器笔记](https://www.jianshu.com/p/f3ee62dc97bc)

[ubuntu+rtmp+ffmpeg(硬解码)+树莓派实现视频直播](https://blog.csdn.net/cin_ie/article/details/80008851)

[树莓派nginx+rtmp搭建直播流媒体服务](https://blog.csdn.net/weixin_33782386/article/details/91719249)

[树莓派使用nginx+rtmp搭建直播服务器](https://blog.csdn.net/zizi7/article/details/54347223)

[ffmpeg+nginx本地推流与html播放](https://www.jianshu.com/p/e51d3b2de59a)


# 参考文档

[基于树莓派搭建可视化可远程遥控网络监控——工程分析及前期准备](https://blog.csdn.net/deng_xj/article/details/98464826)


