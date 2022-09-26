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

# 检测服务器配置
check_vps_info(){
check_os_lshw=`ls /usr/*bin/lshw | wc -l`
if [ $check_os_lshw -ne 1 ];then
	yum -y install lshw || sudo apt-get install -y lshw
fi
check_os_lsscsi=`ls /usr/bin/lsscsi | wc -l`
if [ $check_os_lsscsi -ne 1 ];then
	yum -y install lsscsi || sudo apt-get install -y lsscsi
fi

get_freq=`awk -F'[ :]' '/cpu MHz/ {print $4;exit}' /proc/cpuinfo`
get_cpucache=`awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'`
get_tram=`LANG=C; free -mh | awk '/Mem/ {print $2}'`
get_uram=`LANG=C; free -mh | awk '/Mem/ {print $3}'`
get_swap=`LANG=C; free -mh | awk '/Swap/ {print $2}'`
get_uswap=`LANG=C; free -mh | awk '/Swap/ {print $3}'`
get_up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
get_cpunumber=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
get_cpucores=`cat /proc/cpuinfo| grep "cpu cores"| uniq | awk '{ print $4}'`
get_processor=`cat /proc/cpuinfo| grep "processor" | wc -l`
get_networkinfo=`ip addr | awk '{if($0 ~ /^[0-9]\:(.*)$/){print $2}}' | cut -d ":" -f 1 | awk '{print " | "$0}'`
get_networkipaddress=`ip addr | grep -E 'inet\b' | awk '{print $2}' | cut -d "/" -f 1 | awk '{print " | "$0}'`
# 内存总容量
Memoryzongrongliang=`sudo lsmem |grep "Total\ online\ memory" | cut -d':' -f 2 | sed 's/ //g'`
# 内存条数量
Memoryshuliang=`sudo dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v Range |grep -v "No Module Installed" |wc -l`
# 单内存条容量
Memorydanrongliang=`sudo dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v Range |grep -v "No Module Installed" |head -1 | cut -d':' -f 2 | sed 's/ //g'`
# 内存频率
Memorypinlv=`sudo dmidecode|grep -P -A20 "Memory\s+Device"|grep Speed |grep -v "Configured" |sort -n |uniq | grep -v "Unknown" | cut -d':' -f 2 | sed 's/ //g' | sed '2,999 d'`
# 内存品牌
Memorypinpai=`sudo dmidecode|grep -P -A20 "Memory\s+Device"|grep Manufacturer |grep -vE "Not Specified|Unknown" |sort -n |uniq | grep -v "NO DIMM" | cut -d':' -f 2 | sed 's/ //g'`
# 内存值转换
if [ $Memorydanrongliang == '16384MB' ];then
	Memorydanrongliang="16GB"
fi
# 检测系统盘
systemdisk=`df -h | grep -vE "tmpfs|mapper|loop|udev" | grep /dev/ | grep boot | sed '2,999d' | awk '{print $1}' | cut -d'/' -f 3`
systemdisk_nvme=`df -h | grep -vE "tmpfs|mapper|loop|udev" | grep /dev/ | grep boot | sed '2,999d' | awk '{print $1}' | cut -d'/' -f 3 | grep nvme | wc -l`
if [ $systemdisk_nvme == 1 ];then
        systemdisk=`echo $systemdisk | grep -Eo "nvme[0-9]n[0-9]"`
else
        systemdisk=`echo $systemdisk | sed 's/[0-9]//g'`
fi

# 硬盘数量统计
# 系统总盘数
systemdisktotal=`lsblk | grep -Eio "nvme[0-9]+n|[a-Z]d[a-Z]+" | uniq | wc -l`
# 系统盘
systemdiskname=`df -h | grep -vE "tmpfs|mapper|loop|udev" | grep /dev/ | grep boot | sed '2,999d' | awk '{print $1}' | cut -d'/' -f 3 | sed "s/[0-9]*//g"`
# 系统盘大小
systemdisksize=`lsscsi -s | grep -wo "$systemdiskname.*" | awk '{print $2}'`
# 数据盘个数
datadisknum=`lsscsi -s | grep -Eo "[0-9]+\.[0-9]+TB" | wc -l`
# 数据盘大小
datadisksize=`lsscsi -s | grep -Eo "[0-9]+\.[0-9+]TB" | uniq`
# NVME盘
nvmedisknum=`lsblk | grep '^nvme' | wc -l`
# NVME盘大小
nvmedisksize=`lsblk | grep "^nvme" | grep -v "$systemdiskname.*" | grep -Eo "[0-9]+.[0-9]+[G|T]" | uniq`
# 显卡个数
server_gpu_number=`lspci | grep -i vga | grep -v "Graphics"`
server_gpt_name=`lspci | grep -i vga | grep -v "Graphics" | grep -Eo "GeForce [R|G]TX [0-9]+ [a-Z]+" | uniq`
if [[ $server_gpu_number -ne 0 && $server_gpt_name == "" ]];then
        echo -e "${greenbg}系统显卡为十六进制，开始进行网络查询，确保网络可用！${plain}"
        server_gpt_nameid=`lspci | grep -i vga | grep -v Graphics | grep -Eio "NVIDIA Corporation Device [0-9]+" | grep -oE "[0-9]+" | uniq | sed '2,999d'`
        server_gpt_name=`curl -s http://pci-ids.ucw.cz/mods/PC/10de/$server_gpt_nameid | grep -Eio "nvidia+ g[a-z]+ [R|G][a-z]+ [0-9]+ [a-z]* [a-z]*"`
fi

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

check_virt(){
    _exists "dmesg" && virtualx="$(dmesg 2>/dev/null)"
    if _exists "dmidecode"; then
        sys_manu="$(dmidecode -s system-manufacturer 2>/dev/null)"
        sys_product="$(dmidecode -s system-product-name 2>/dev/null)"
        sys_ver="$(dmidecode -s system-version 2>/dev/null)"
    else
        sys_manu=""
        sys_product=""
        sys_ver=""
    fi
    if   grep -qa docker /proc/1/cgroup; then
        virt="Docker"
    elif grep -qa lxc /proc/1/cgroup; then
        virt="LXC"
    elif grep -qa container=lxc /proc/1/environ; then
        virt="LXC"
    elif [[ -f /proc/user_beancounters ]]; then
        virt="OpenVZ"
    elif [[ "${virtualx}" == *kvm-clock* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *KVM* ]]; then
        virt="KVM"
    elif [[ "${cname}" == *QEMU* ]]; then
        virt="KVM"
    elif [[ "${virtualx}" == *"VMware Virtual Platform"* ]]; then
        virt="VMware"
    elif [[ "${virtualx}" == *"Parallels Software International"* ]]; then
        virt="Parallels"
    elif [[ "${virtualx}" == *VirtualBox* ]]; then
        virt="VirtualBox"
    elif [[ -e /proc/xen ]]; then
        virt="Xen"
    elif [[ "${sys_manu}" == *"Microsoft Corporation"* ]]; then
        if [[ "${sys_product}" == *"Virtual Machine"* ]]; then
            if [[ "${sys_ver}" == *"7.0"* || "${sys_ver}" == *"Hyper-V" ]]; then
                virt="Hyper-V"
            else
                virt="Microsoft Virtual Machine"
            fi
        fi
    else
        virt="Dedicated"
    fi
}

check_virt && clear

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|udev|docker' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|udev|docker' | awk '{print $3}' ))
disk_total_size=$( calc_disk "${disk_size1[@]}" )
disk_used_size=$( calc_disk "${disk_size2[@]}" )

ipv4_info() {
    local org="$(wget -q -T10 -O- ipinfo.io/org)"
    local city="$(wget -q -T10 -O- ipinfo.io/city)"
    local country="$(wget -q -T10 -O- ipinfo.io/country)"
    local region="$(wget -q -T10 -O- ipinfo.io/region)"
    [[ -n "$org" ]] && echo -ne " ${blue}Organization${plain}	: " && echo "$org"
    [[ -n "$city" && -n "country" ]] && echo -ne " ${blue}Location${plain}	:" && echo " $city $country"
    [[ -n "$region" ]] && echo -ne " ${blue}Region${plain}		:" && echo " $region"
}

echo -e "----------------------------------------------------------------------------"
echo -ne "${blue} OS Name ${plain}	:" && echo -ne " " && get_opsy
echo -ne "${blue} OS type ${plain}	:" && echo -ne " " && uname -o | awk '{ print $0 }'
echo -ne "${blue} OS Arch ${plain}	:" && echo -ne " " && uname -o | uname -m | awk '{ print $0 }'
echo -ne "${blue} OS Kernel ${plain}	:" && echo -ne " " && uname -r | awk '{ print $0 }'
echo -ne "${blue} OS uptime ${plain}	:" && echo -ne " " && echo "$get_up"
echo -ne "${blue} Hostname ${plain}	:" && echo -ne " " && hostname | awk '{ print $0 }'
echo -ne "${blue} CPU Model ${plain}	:" && cat /proc/cpuinfo| grep "model name" | cut -d':' -f 2 | uniq
echo -ne "${blue} CPU Frequency ${plain}	:" && echo " $get_freq MHz"
echo -ne "${blue} CPU Cache ${plain}	:" && echo " $get_cpucache"
echo -ne "${blue} CPU Number ${plain}	:" && echo -e " $get_cpunumber vCPU"
echo -ne "${blue} CPU Cores ${plain}	:" && echo -e " $get_cpucores Cores"
echo -ne "${blue} CPU Processor ${plain}	:" && echo -e " $get_processor Processor"
echo -ne "${blue} Mem Name ${plain}	:" && echo -e " $Memorypinpai"
echo -ne "${blue} Mem Total ${plain}	:" && echo -e " $Memoryzongrongliang"
echo -ne "${blue} Mem Number ${plain}	:" && echo -e " $Memoryshuliang 根"
echo -ne "${blue} Mem Single ${plain}	:" && echo -e " 单根容量 $Memorydanrongliang"
echo -ne "${blue} Mem Mhz${plain}	:" && echo -e " $Memorypinlv"
echo -ne "${blue} Disk Number ${plain}  :" && echo -e " 系统总盘数: $systemdisktotal"
echo -ne "${blue} Disk OSname ${plain}  :" && echo -e " 系统盘名: $systemdiskname,系统盘大小: $systemdisksize"
echo -ne "${blue} Data Disk ${plain}    :" && echo -e " 数据盘个数: $datadisknum,数据盘大小: $datadisksize"
echo -ne "${blue} Data Nvme ${plain}    :" && echo -e " NVME盘个数: $nvmedisknum,数据盘大小: $nvmedisksize"
echo -ne "${blue} GPU Number ${plain}   :" && echo -e " $server_gpu_number 个"
echo -ne "${blue} GPU Name ${plain}     :" && echo -e " $server_gpt_name"
echo -ne "${blue} Total Disk ${plain}	:" && echo -ne " " && echo "$disk_total_size GB ($disk_used_size GB Used)"
echo -ne "${blue} Total Memory ${plain}	:" && echo -ne " " && echo "$get_tram MB ($get_uram MB Used))"
echo -ne "${blue} Total Swap ${plain}	:" && echo -ne " " && echo "$get_swap MB ($get_uswap MB Used))"
echo -ne "${blue} Virtualization ${plain}:" && echo -ne " " && echo "$virt"
echo -ne "${blue} Product number ${plain}:" && echo -ne " " && sudo dmidecode -s system-product-name
echo -ne "${blue} Product Serial ${plain}:" && echo -ne " " && sudo dmidecode -s system-serial-number

echo -e "----------------------------------------------------------------------------"
ipv4_info
echo -ne "${blue} IP Address ${plain}	:" && echo -ne " " && curl -s cip.cc | grep IP | cut -f 2 -d :
echo -e "${blue}-------------------------------Memory Info----------------------------------${plain}"
sudo lshw -short -C memory | grep GiB
echo -e "${blue}------------------------------- Disk Info ----------------------------------${plain}"
sudo lshw -short -C disk
echo -e "${blue}------------------------------- Raid Info ----------------------------------${plain}"
sudo lspci -v | grep -i Infiniband
echo -e "${blue}--------------------------------- Network Card -----------------------------${plain}"
echo -ne "${blue} Network Card Information ${plain}" && echo -e " " && echo "$get_networkinfo"
echo -ne "${blue} Network Card IP Address ${plain}" && echo -e " " && echo "$get_networkipaddress"
echo -e "${blue}----------------------------------------------------------------------------${plain}"
}
# 脚本界面
menu(){
echo -e "$greenbg 脚本基本兼容Centos7.9,部分兼容Ubuntu20.04,其他暂时不支持 $plain
========== ops shell ==========
1.检查服务器配置(需要联网加载相关组件)

q. 关闭脚本
========== ops shell ==========
"
}

menu

read -p "请输入对应的数值:" num
case $num in
1)	check_vps_info;;
q)	exit;;
*)	echo "数值有误,重新执行." && exit ;;
esac
