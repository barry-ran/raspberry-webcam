# raspberry-webcam
树莓派网络摄像头监控

# 环境
1. 操作系统：Raspbian Buster Lite
2. apt-get更新或者安装某些包的时候可能需要翻墙

# CSI摄像头

## 安装摄像头并测试
1. 淘宝购买[树莓派CSI摄像头](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.28be2e8dSHCHDw&id=589954896868&_u=nncaoqo9af4)，不用买官方正版，大约10多元
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
1. mjpg-stream - web可以直接访问，但是帧率太低，[参考](https://blog.csdn.net/m0_38106923/article/details/86562451)
2. vlc - 延迟高，大约2s-5s
3. raspivid - 延迟170ms左右，并支持h264硬件编码，好像可以 [参考这里](https://blog.csdn.net/qq_39492932/article/details/84585152)

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

4. [pistreaming](https://github.com/waveform80/pistreaming) - 性能不错，延迟低，作为最终采用方案

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

8. ffmpeg硬解码推流 - 支持硬件编解码，但是延迟很高（不知道是推流原因还是播放原因），画质很差

    流程比较复杂，整理成脚本保存在ffmpeg目录中

    1. 安装x264硬件编码 install_x264.sh
    2. 安装ffmpeg install_ffmpeg.sh
    3. 安装运行nginx install_nginx.sh
    4. 启动推流（注意192.168.0.111替换为你的ip地址）
        ```
        /usr/local/bin/ffmpeg -ss 0 -pix_fmt yuv420p -i /dev/video0 -c:v h264_omx -f flv rtmp://192.168.0.111:1935/live/camera
        ```
    5. potplayer播放url rtmp://192.168.0.111:1935/live/camera

9. [webrtc](https://github.com/kclyu/rpi-webrtc-streamer) - 看视频貌似效果很好，工作量太大，后期验证
    
[编译webrtc for raspberry](https://antmedia.io/building-and-cross-compiling-webrtc-for-raspberry/)

[编译webrtc for raspberry 2](https://ipop-project.org/wiki/Build-WebRTC-Libraries-for-Raspberry-Pi-3-(Cross-compile-on-Ubuntu))


### 参考文档
[树莓派上实现流媒体](https://blog.csdn.net/chiliaolm/article/details/51674691)

[树莓派摄像头推流的几种方式](https://blog.csdn.net/zz531987464/article/details/100087755)

[使用motion和mjpg做视频监控器](https://blog.csdn.net/u010900754/article/details/53097626/)

[Nginx部署RTMP流媒体服务器笔记](https://www.jianshu.com/p/f3ee62dc97bc)

[ubuntu+rtmp+ffmpeg(硬解码)+树莓派实现视频直播](https://blog.csdn.net/cin_ie/article/details/80008851)

[树莓派nginx+rtmp搭建直播流媒体服务](https://blog.csdn.net/weixin_33782386/article/details/91719249)

[树莓派使用nginx+rtmp搭建直播服务器](https://blog.csdn.net/zizi7/article/details/54347223)

[ffmpeg+nginx本地推流与html播放](https://www.jianshu.com/p/e51d3b2de59a)

# 舵机控制

## 所需材料
零件都在淘宝同一家店铺购买，总共约50元左右
1. [MG90S舵机 x2](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.28be2e8dSHCHDw&id=588678162231&_u=nncaoqo5cf4) 用于控制摄像头转动，一个控制水平方向，一个控制垂直方向
2. [舵机云台 x1](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.28be2e8dSHCHDw&id=588325796727&_u=nncaoqo5745) 用来搭载、固定舵机
3. [舵机驱动板](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.28be2e8dSHCHDw&id=598065941803&_u=nncaoqo3716) 用来控制多个舵机
5. [公对母杜邦线若干](https://item.taobao.com/item.htm?spm=a1z09.2.0.0.28be2e8dSHCHDw&id=590291046862&_u=nncaoqob44e) 用来连接舵机驱动板和树莓派
6. 树莓派

## 舵机驱动板连接
参考[这里](https://zhuanlan.zhihu.com/p/22805173)连线

树莓派和舵机驱动板按照教程分别连接对应GND,SDA.0,SCL0,VCC,V+即可(由于我的树莓派6号GND的针脚被我的风扇占用了，所以我把GND连接到了9号的GND)

注意是SDA.0,SCL.0,不要连成了SDA.1,SCL.1

舵机直接插上即可，我插在了0，15两个位置

## python控制舵机
1. 树莓派开启I2C
```
sudo raspi-config -> 5.Interfacing Options -> P5 I2C　设置enable，然后重启树莓派
```
2. i2c-tools测试舵机连接状态
```
sudo apt-get install i2c-tools
sudo i2cdetect -y 1
```
3. 使用PCA9685 python库控制舵机

例子源码[在这里](https://github.com/adafruit/Adafruit_Python_PCA9685.git)(example目录下)

```
sudo pip3 install adafruit-pca9685
python3 ./simpletest.py
```
可以看到舵机来回转动

## 参考文档
[树莓派3B+ PCA9685舵机驱动板控制舵机](https://blog.csdn.net/zz531987464/article/details/100391715)

[树莓派搭建简易远程监控（利用舵机制作可旋转的摄像头）](https://zhuanlan.zhihu.com/p/22805173)

# 参考文档

[基于树莓派搭建可视化可远程遥控网络监控——工程分析及前期准备](https://blog.csdn.net/deng_xj/article/details/98464826)


