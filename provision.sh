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

sudo cp nginx-1.20.2-1.el8.ngx.src.rpm /root/

# Package nginx

sudo rpm -i nginx-1.20*

# Download source file openssl and unzip and install

wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip

unzip OpenSSL*.zip

# Copy ro root directory

sudo cp -r openssl-OpenSSL_1_1_1-stable/ /root/

# Add path to openssl
sed -i 's/--with-debug/--with-openssl=\/root\/openssl-OpenSSL_1_1_1-stable/' /root/rpmbuild/SPECS/nginx.spec

# Install dependencies

yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

# Now we can start building the RPM package

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


