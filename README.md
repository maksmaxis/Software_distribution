# Software_distribution

```
Cборка пакетов из исходников
OTUS home work nginx src
CentOS Linux release Stream 
rpmbuilder - vagrant vm
```

Загружаем виртуальную машину (rpmbuilder) Vagrant и вводим команду:
```
$ vagrant up
```
В Vagrantfile присутствует Shell Script для скачивания инструментов для сборки RPM пакета из Source файла NGINX который будет также загружен с помощью команды wget:

```
rpm.vm.provision "shell", path: "provision.sh"
```
Ниже описание команд:

```
yum install -y wget
yum install -y epel-release

# install yum pkg

yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc

# Download source of NGINX

wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm

# Copy file to root directory

sudo cp nginx-1.20.2-1.el8.ngx.src.rpm /root/

# Package nginx
# When a package is installed in the home directory, a directory tree is created for the build

sudo rpm -i nginx-1.20*

# Download source file openssl and unzip

wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip

unzip OpenSSL*.zip

# Copy to root directory

sudo cp -r openssl-OpenSSL_1_1_1-stable/ /root/

# Add path to openssl in /root/rpmbuild/SPECS/nginx.spec
sed -i 's/--with-debug/--with-openssl=\/root\/openssl-OpenSSL_1_1_1-stable/' /root/rpmbuild/SPECS/nginx.spec

# Install dependencies

yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

# Now we can start building the RPM package:

rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec

# Install pkg nginx

yum localinstall -y \
/root/rpmbuild/RPMS/x86_64/nginx-1.20*

# Start nginx

systemctl start nginx

# Make directory 

mkdir /usr/share/nginx/html/repo

# Copy our build rpm pkg

cp rpmbuild/RPMS/x86_64/nginx-1.20* /usr/share/nginx/html/repo/

# Download Percona-Server

wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm

# Initialize the repository with the command:

createrepo /usr/share/nginx/html/repo/

# В location / в файле /etc/nginx/conf.d/default.conf добавим директиву autoindex on.

N=10; sed -e $N"s/^/        autoindex on;\n/" -i /etc/nginx/conf.d/default.conf

# Reload NGINX 

nginx -s reload

# Let's add it to /etc/yum.repos.d

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

# Install percona-release

yum install percona-orchestrator.x86_64 -y


```

Проверяем виртульную машину

```
$ vagrant status
```
Otput:

```
Current machine states:
rpmbuilder                running (virtualbox)
```

Заходим в виртульную машину:
```
$ vagrant ssh
```
Получаем рут права:
```
$ sudo -i
```
Проверяем наш созданный rpm пакет:

```
ll rpmbuild/RPMS/x86_64/
```
Otput:

```
[root@rpmbuilder ~]# ll rpmbuild/RPMS/x86_64/
total 4456
-rw-r--r--. 1 root root 2060476 Nov 28 16:16 nginx-1.20.2-1.el8.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2495636 Nov 28 16:16 nginx-debuginfo-1.20.2-1.el8.ngx.x86_64.rpm

```
Проверяем статус nginx запущен ли он:

```
systemctl status nginx
```
Otput:

```
[root@rpmbuilder ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2022-11-28 16:16:52 UTC; 43s ago
     Docs: http://nginx.org/en/docs/
  Process: 47574 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 47576 (nginx)
    Tasks: 2 (limit: 12426)
   Memory: 1.9M
   CGroup: /system.slice/nginx.service
           ├─47576 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─47579 nginx: worker process

Nov 28 16:16:52 rpmbuilder systemd[1]: Starting nginx - high performance web server...
Nov 28 16:16:52 rpmbuilder systemd[1]: nginx.service: Can't open PID file /var/run/nginx.pid (yet?) after start: No such file or directory
Nov 28 16:16:52 rpmbuilder systemd[1]: Started nginx - high performance web server.

```
