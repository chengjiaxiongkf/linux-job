#bin/bash
yum -y install wget
wget https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -zxvf apache-maven-3.3.9-bin.tar.gz
echo ">>manual steps<<"
echo "vim /etc/profile"
echo "export MAVEN_HOME=/var/local/apache-maven-3.3.9"
echo "export MAVEN_HOME"
echo "export PATH=MAVEN_HOME/bin"
echo "source /etc/profile"