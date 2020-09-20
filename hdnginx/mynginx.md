yum -y install wget
yum -y install unzip
yum -y install gcc-c++
yum -y install gcc automake autoconf libtool make


cd /root
 
wget http://nginx.org/download/nginx-1.8.0.tar.gz
tar zxvf nginx-1.8.0.tar.gz
 
wget  http://www.zlib.net/zlib-1.2.11.tar.gz
tar zxvf zlib-1.2.11.tar.gz
 
wget https://ftp.pcre.org/pub/pcre/pcre-8.37.tar.gz
tar zxvf pcre-8.37.tar.gz
 
wget https://www.openssl.org/source/openssl-1.0.1q.tar.gz
tar zxvf openssl-1.0.1q.tar.gz
 
wget -O ngx_http_substitutions_filter_module-master.zip https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/master.zip
unzip ngx_http_substitutions_filter_module-master.zip




cd /root/nginx-1.8.0
./configure --sbin-path=/root/nginx-1.8.0/nginx --conf-path=/root/nginx-1.8.0/nginx.conf --pid-path=/root/nginx-1.8.0/nginx.pid --with-http_ssl_module --with-pcre=/root/pcre-8.37 --with-zlib=/root/zlib-1.2.11 --with-openssl=/root/openssl-1.0.1q   --with-http_stub_status_module  --add-module=/root/ngx_http_substitutions_filter_module-master/   --prefix=/root/nginx-1.8.0
make
# make CFLAGS='-Wno-implicit-fallthrough'
make install