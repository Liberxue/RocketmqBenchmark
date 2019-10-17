mkfs.ext4 /dev/vdb
mount /dev/vdb /data
echo 'mount /dev/vdb /data'>>/etc/rc.d/rc.local

echo export JAVA_HOME=/usr/lib/jvm/java >> ~/.bashrc
source ~/.bashrc
echo export NAMESRV_ADDR=${namesvr}:9876 >> ~/.bashrc
