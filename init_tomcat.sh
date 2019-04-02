#! /bin/bash
#centos7.4 jdk1.8.0_144+apache-tomcat-9.0.14-windows-x64.zip以root用户运行安装脚本
#tomcat下载地址：http://archive.apache.org/dist/tomcat
sourceinstall=/usr/local/src/tomcat
chmod -R 777 /usr/local/src/tomcat
##时间时区同步，修改主机名
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ntpdate ntp1.aliyun.com
hwclock -w
echo "*/30 * * * * root ntpdate -s ntp1.aliyun.com" >> /etc/crontab
crontab /etc/crontab

#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
#setenforce 0 && systemctl stop firewalld && systemctl disable firewalld 

rm -rf /var/run/yum.pid 
rm -rf /var/run/yum.pid

#安装jdk1.8.0_144
mkdir /usr/local/java
cd $sourceinstall
tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local/java/
chmod +x /usr/local/java/jdk1.8.0_144
cat > /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=/usr/local/java/jdk1.8.0_144/
export JRE_HOME=/usr/local/java/jdk1.8.0_144/jre
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
EOF
cd
source /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version

#安装apache-tomcat-9.0.14-windows-x64.zip
groupadd tomcat
useradd -g tomcat -s /sbin/nologin tomcat
cd $sourceinstall
unzip apache-tomcat-9.0.14-windows-x64.zip -d /usr/local
#ln -s /usr/loca/apache-tomcat-9.0.14 /usr/local/tomcat

chmod +x /usr/local/apache-tomcat-9.0.14/bin/*.sh
chown -R tomcat:tomcat /usr/local/apache-tomcat-9.0.14

cat > /usr/lib/systemd/system/tomcat.service <<EOF
[Unit]
Description=Tomcat
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Group=tomcat
User=tomcat
Type=oneshot
ExecStart=/usr/local/apache-tomcat-9.0.14/bin/startup.sh
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/usr/local/apache-tomcat-9.0.14/bin/shutdown.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

#日志修改：/home/tomcat/conf/server.xml ==>> pattern="%h %l %u %t &quot;%r&quot; %s %{User-Agent}i %b" />
systemctl daemon-reload 
systemctl enable tomcat.service 
systemctl stop tomcat.service 
systemctl start tomcat.service 

cd
rm -rf /usr/local/src/tomcat
java -version
ps aux |grep tomcat

firewall-cmd --permanent --zone=public --add-port=8080/tcp --permanent
firewall-cmd --permanent --query-port=8080/tcp
firewall-cmd --reload


#注释80行和144行    sed -i '80,144 s|^|#|g' /usr/local/tomcat/init_tomcat.sh
#去掉注释80行和144行sed -i '80,144 s|#||g' /usr/local/tomcat/init_tomcat.sh

#tomcat内存溢出,查看tomcat进程内存使用率（当O项到达100%就说明内存溢出了）
#jps -v 
#jstat -gcutil 29692


##! /bin/bash
##centos7.4 jdk1.8.0_144+apache-tomcat-9.0.13以tomcat用户运行安装脚本

#sourceinstall=/usr/local/src/tomcat
#chmod -R 777 /usr/local/src/tomcat
#时间时区同步，修改主机名
#ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#ntpdate cn.pool.ntp.org
#hwclock --systohc
#echo "*/30 * * * * root ntpdate -s 3.cn.poop.ntp.org" >> /etc/crontab

#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
#sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
#sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
#setenforce 0 && systemctl stop firewalld && systemctl disable firewalld 

#rm -rf /var/run/yum.pid 
#rm -rf /var/run/yum.pid

##安装jdk1.8.0_144
#mkdir /usr/local/java
#cd $sourceinstall
#tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local/java/
#chmod +x /usr/local/java/jdk1.8.0_144
#cat > /etc/profile.d/jdk.sh <<EOF
#export JAVA_HOME=/usr/local/java/jdk1.8.0_144/
#export JRE_HOME=/usr/local/java/jdk1.8.0_144/jre
#export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
#export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
#EOF
#cd
#source /etc/profile.d/jdk.sh
#source /etc/profile.d/jdk.sh
#java -version

##安装apache-tomcat-9.0.13
#useradd tomcat -s /sbin/nologin
#cd $sourceinstall
#unzip apache-tomcat-9.0.13-windows-x64.zip -d /usr/local/
#ln -s /usr/local/apache-tomcat-9.0.13 /usr/local/tomcat
#chmod +x /usr/local/apache-tomcat-9.0.13/bin/*.sh
#cd /usr/local/tomcat/bin/
#yum -y install gcc
#tar -zxvf commons-daemon-native.tar.gz 
#cd /usr/local/apache-tomcat-9.0.13/bin/commons-daemon-1.0.15-native-src/unix/
#./configure 
#make
#cp -rpf /usr/local/apache-tomcat-9.0.13/bin/commons-daemon-1.0.15-native-src/unix/jsvc /usr/local/apache-tomcat-9.0.13/bin/
#sed -i 's|# JAVA_HOME=/opt/jdk-1.6.0.22|JAVA_HOME=/usr/local/java/jdk1.8.0_144/|' /usr/local/apache-tomcat-9.0.13/bin/daemon.sh
#sed -i 's|JAVA_OPTS=|JAVA_OPTS="-server -Xms800m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=1024m -XX:MaxNewSize=1024m"|' /usr/local/apache-tomcat-9.0.13/bin/daemon.sh

#cat > /usr/lib/systemd/system/tomcat.service <<EOF
#[Unit]
#Description=Tomcat
#After=syslog.target network.target remote-fs.target nss-lookup.target

#[Service]
#User=tomcat
#Type=forking
#PIDFile=/usr/local/tomcat/logs/catalina-daemon.pid
#ExecStart=/usr/local/tomcat/bin/daemon.sh start
#ExecStop=/usr/local/tomcat/bin/daemon.sh stop
#PrivateTmp=true

#[Install]
#WantedBy=multi-user.target
#EOF
#chown -Rf tomcat:tomcat /usr/local/tomcat
#systemctl daemon-reload 
#systemctl enable tomcat.service 
#systemctl stop tomcat.service 
#systemctl start tomcat.service 

#cd
#rm -rf /usr/local/src/tomcat
#java -version
#ps aux |grep tomcat
