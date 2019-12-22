# 获取绝对路径，保证其他目录执行此脚本依然正确
{
cd $(dirname "$0")
script_path=$(pwd)
cd -
} &> /dev/null # disable output

# 设置当前目录，cd的目录影响接下来执行程序的工作目录
old_cd=$(pwd)
cd $(dirname "$0")

echo
echo ---------------------------------------------------------------
echo clone x264
echo ---------------------------------------------------------------

x264_path=$script_path/x264
if [ ! -d $x264_path ];then
    git clone https://code.videolan.org/videolan/x264.git
else
    echo x264 exist
fi

if [ $? -ne 0 ]; then
    echo clone x264 failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo config x264
echo ---------------------------------------------------------------

cd x264
cp ../config_x264_rpi.sh ./
chmod +x config_x264_rpi.sh
./config_x264_rpi.sh

if [ $? -ne 0 ]; then
    echo config x264 failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo make x264
echo ---------------------------------------------------------------

make -j4

if [ $? -ne 0 ]; then
    echo make x264 failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo install x264
echo ---------------------------------------------------------------

sudo make install

if [ $? -ne 0 ]; then
    echo install x264 failed
    exit 1
fi

# 恢复工作目录
cd $old_cd

echo install x264 success