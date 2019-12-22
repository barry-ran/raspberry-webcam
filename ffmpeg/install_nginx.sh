# 获取绝对路径，保证其他目录执行此脚本依然正确
{
cd $(dirname "$0")
script_path=$(pwd)
cd -
} &> /dev/null # disable output

# 设置当前目录，cd的目录影响接下来执行程序的工作目录
old_cd=$(pwd)
cd $(dirname "$0")

nginx_version=1.16.1
nginx_gz=nginx-$nginx_version.tar.gz
nginx_dir=$script_path/nginx-$nginx_version
nginx_rtmp_dir=$script_path/nginx-rtmp-module
nginx_install_dir=/usr/local/nginx

echo
echo ---------------------------------------------------------------
echo install depends
echo ---------------------------------------------------------------

sudo apt-get -y install build-essential libpcre3 libpcre3-dev libssl-dev

if [ $? -ne 0 ]; then
    echo install depends failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo download $nginx_gz
echo ---------------------------------------------------------------

if [ ! -f $nginx_gz ];then
    wget wget http://nginx.org/download/$nginx_gz
else
    echo $nginx_gz exist
fi

if [ $? -ne 0 ]; then
    echo download $nginx_gz failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo tar $nginx_gz
echo ---------------------------------------------------------------

if [ ! -d $nginx_dir ];then
    tar zxvf $nginx_gz
else
    echo $nginx_dir exist
fi

if [ $? -ne 0 ]; then
    echo tar $nginx_dir failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo clone nginx-rtmp-module
echo ---------------------------------------------------------------

if [ ! -d $nginx_rtmp_dir ];then
    git clone https://github.com/arut/nginx-rtmp-module.git
else
    echo $nginx_rtmp_dir exist
fi

if [ $? -ne 0 ]; then
    echo clone nginx-rtmp-module failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo config $nginx_dir
echo ---------------------------------------------------------------

cd $nginx_dir
./configure --prefix=$nginx_install_dir --add-module=../nginx-rtmp-module --with-http_ssl_module

if [ $? -ne 0 ]; then
    echo config $nginx_dir failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo make $nginx_dir
echo ---------------------------------------------------------------

make -j4 CFLAGS='-Wno-implicit-fallthrough'

if [ $? -ne 0 ]; then
    echo make $nginx_dir failed
    exit 1
fi

# 如果存在则先尝试stop
if [ -f $nginx_install_dir/sbin/nginx ];then
    sudo $nginx_install_dir/sbin/nginx -s stop
fi

echo
echo ---------------------------------------------------------------
echo install $nginx_dir
echo ---------------------------------------------------------------

sudo make install

if [ $? -ne 0 ]; then
    echo install $nginx_dir failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo update nginx.conf
echo ---------------------------------------------------------------

sudo cp -f ../nginx.conf $nginx_install_dir/conf/nginx.conf

if [ $? -ne 0 ]; then
    echo update nginx.conf failed
    exit 1
fi

echo
echo ---------------------------------------------------------------
echo start nginx
echo ---------------------------------------------------------------

cd $nginx_install_dir/sbin
sudo ./nginx

if [ $? -ne 0 ]; then
    echo start nginx failed
    exit 1
fi

# 恢复工作目录
cd $old_cd

echo install $nginx_dir success