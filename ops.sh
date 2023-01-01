#!/bin/bash

# 颜色代码
red='\033[0;31m'
redbg='\033[41m'
green='\033[0;32m'
greenbg='\033[42m'
plain='\033[0m'

# Ubuntu系统简单检测
get_ubuntu_os=`uname -a | grep -Ei "ubunt(u)" | wc -l`

if [ $get_ubuntu_os -eq 1 ];then
	timeout --foreground 2s sudo ls
	if [ $? -ne 0 ];then
		clear && read -sp "请输入当前账户的sudo密码,并等待验证(密码不显示): " ubuntu_sudo_password
		echo "$ubuntu_sudo_password" | sudo -S ls
			if [ $? -eq 0 ];then
				clear
				echo -e "$greenbg 验证通过 $plain";
			else
				clear
				echo -e "$redbg 密码错误,请重新执行脚本 $plain"
				exit
			fi
	else
		clear
                echo -e "$greenbg 密码验证通过 $plain";
	fi
fi

# 安装wget和curl
get_curlwget=`ls /usr/bin | grep -E "^curl|^wget" | wc -l`

if [ $get_curlwget -ne 2 ];then
        yum -y install wget curl || sudo apt-get install -y wget curl
	clear
	echo -e "$greenbg Centos的Curl和Wget安装完成!!! $plain"
else
	echo -e "$greenbg 系统已安装curl和wget $plain"
fi

# 脚本界面
menu(){
echo -e "$greenbg 脚本基本兼容Centos7.9,部分兼容Ubuntu20.04,其他暂时不支持 $plain
========== ops shell ==========
1.检查服务器配置(联网查询版)
2.检查服务器配置(离线版)
3.Linux系统工具箱

q. 关闭脚本
========== ops shell ==========
"
}

menu

read -p "请输入对应的数值:" num
case $num in
1)	bash <(curl -sL https://raw.githubusercontent.com/limitrinno/ops/master/1_systeminfo_online.sh);;
2)	echo -e "$redbg 在做了在做了！！！$plain";;
3)	bash <(curl -sL https://raw.githubusercontent.com/limitrinno/ops/master/3_systemtools.sh);;
q)	exit;;
*)	echo "数值有误,重新执行." && bash <(curl -sL https://raw.githubusercontent.com/limitrinno/shell/master/ops.sh);;
esac
