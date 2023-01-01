#!/bin/bash

# 颜色代码
red='\033[0;31m'
redbg='\033[41m'
green='\033[0;32m'
greenbg='\033[42m'
plain='\033[0m'

centos7_status=`cat /etc/redhat-release | grep -E "7.[0-9]+" | wc -l`

ipv4_forward_botton(){
read -p "是否要修改状态 确认输入0，否则退出" ipv4_b
if [[ $ipv4_b == 0 ]];then
if [ $ipv4_f_c_n -eq 1 ];then
	sed -i "s/`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward"`/net.ipv4.ip_forward = 0/g" /etc/sysctl.conf
	if [ $? -eq 0 ];then
		echo -e "状态修改成功,状态为：${redbg}关闭${plain}"
	else
		echo "修改失败"
	fi
else
	sed -i "s/`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward"`/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
	if [ $? -eq 0 ];then
		echo -e "状态修改成功,状态为：${greenbg}开启中${plain}"
	else
		echo "修改失败"
	fi
fi
else
	echo -e "${greenbg} 没有修改哟 ${plain}"
fi
}

ipv4_forward(){
ipv4_f_c=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward" | wc -l`
if [ $ipv4_f_c -eq 1 ];then
	ipv4_f_c_n=`cat /etc/sysctl.conf | grep "net.ipv4.ip_forward" | cut -d'=' -f2 | sed 's/ //g'`
	if [ $ipv4_f_c_n -eq 1 ];then
		echo -e "该条转发存在,状态为：${greenbg}开启中${plain}"
		ipv4_forward_botton
	else
		echo -e "该条转发存在,状态为：${redbg}关闭${plain}"
		ipv4_forward_botton
	fi
fi
}

if [[ -f /etc/redhat-release && $centos7_status -eq 1 ]];then
echo -e "${greenbg}确保当前环境的用户为root${plain}

更新类：
1.更新系统以及更新所有软件
2.安装基础包和基础工具(vim groupinstall_base iftop htop nc等等常用工具)
3.安装开发包（Development Tools , Perl Support）
系统类:
11.开放ipv4转发功能
12.优化SSH连接缓慢的问题
"
read -p "
输入你需要用的选项：" centos7_shell
case $centos7_shell in
1)      yum -y update && yum -y upgrade;;
2)      yum -y makecache && yum -y install epel-release && yum -y groupinstall base && yum -y install vim iftop nc htop net-tools;;
3)	yum -y groupinstall "Development Tools" "Perl Support";;
11)	ipv4_forward;;
12)	echo "哒咩";;
*)      exit;;
esac
else
        echo "只支持centos7"
fi

