#!/bin/bash

VERSION="1.0.0"
SCRIPT_NAME="Linux 工具箱 1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION"
        OS_ID="$ID"
    elif [ -f /etc/redhat-release ]; then
        OS_NAME=$(cat /etc/redhat-release | cut -d' ' -f1)
        OS_VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
        OS_ID="rhel"
    elif [ -f /etc/debian_version ]; then
        OS_NAME="Debian"
        OS_VERSION=$(cat /etc/debian_version)
        OS_ID="debian"
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
        OS_ID="unknown"
    fi
}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PM="apt"
    elif command -v yum &> /dev/null; then
        PM="yum"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    elif command -v zypper &> /dev/null; then
        PM="zypper"
    else
        PM="unknown"
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}[!] 以 root 身份运行${NC}"
    fi
}

print_header() {
    detect_os
    detect_package_manager
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}    $SCRIPT_NAME v$VERSION${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "${BLUE}操作系统: ${OS_NAME} ${OS_VERSION}${NC}"
    echo -e "${BLUE}包管理器: ${PM}${NC}"
    echo ""
}

print_menu() {
    echo -e "${GREEN}=== 主菜单 ===${NC}"
    echo -e "  ${YELLOW}1${NC}) 系统信息"
    echo -e "  ${YELLOW}2${NC}) 文件操作"
    echo -e "  ${YELLOW}3${NC}) 网络工具"
    echo -e "  ${YELLOW}4${NC}) 系统监控"
    echo -e "  ${YELLOW}5${NC}) 更换软件源"
    echo -e "  ${YELLOW}6${NC}) 安装 Python"
    echo -e "  ${YELLOW}7${NC}) 安装 Node.js"
    echo -e "  ${YELLOW}8${NC}) 管理 swap 交换内存"
    echo -e "  ${YELLOW}0${NC}) 退出"
    echo ""
}

show_system_info() {
    while true; do
        clear
        print_header
        echo -e "${GREEN}=== 系统信息 ===${NC}"
        echo ""
        echo -e "  ${YELLOW}1${NC}) 操作系统信息"
        echo -e "  ${YELLOW}2${NC}) CPU 信息"
        echo -e "  ${YELLOW}3${NC}) 内存信息"
        echo -e "  ${YELLOW}4${NC}) 磁盘使用情况"
        echo -e "  ${YELLOW}5${NC}) 硬件详情"
        echo -e "  ${YELLOW}6${NC}) 完整系统信息"
        echo -e "  ${YELLOW}7${NC}) 生成系统报告"
        echo -e "  ${YELLOW}0${NC}) 返回主菜单"
        echo ""
        read -p "请选择选项: " sys_opt

        case $sys_opt in
            1)
                clear
                echo -e "${BLUE}=== 操作系统信息 ===${NC}"
                echo ""
                echo "内核版本: $(uname -r)"
                echo "架构: $(uname -m)"
                echo "主机名: $(hostname)"
                echo "运行时间: $(uptime -p)"
                echo ""
                if [ -f /etc/os-release ]; then
                    cat /etc/os-release | grep -E "^(NAME|VERSION|ID)=" | sed 's/NAME=/操作系统名称: /' | sed 's/VERSION=/版本: /' | sed 's/ID=/ID: /'
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            2)
                clear
                echo -e "${BLUE}=== CPU 信息 ===${NC}"
                echo ""
                lscpu | grep -E "^(Architecture|CPU\(s\)|Thread|Core|Model name|CPU MHz|Cache|Flags)"
                echo ""
                echo "CPU 负载:"
                uptime | awk -F'load average:' '{print $2}'
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            3)
                clear
                echo -e "${BLUE}=== 内存信息 ===${NC}"
                echo ""
                free -h
                echo ""
                echo "交换分区使用情况:"
                swapon --show
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            4)
                clear
                echo -e "${BLUE}=== 磁盘使用情况 ===${NC}"
                echo ""
                df -h | grep -E "Filesystem|/dev/"
                echo ""
                echo "Inode 使用情况:"
                df -i | grep -E "Filesystem|/dev/"
                echo ""
                echo "十大占用空间目录:"
                du -h --max-depth=1 2>/dev/null | sort -hr 2>/dev/null | head -10 || du -h --max-depth=1 2>/dev/null | sort -k1 -h -r 2>/dev/null | head -10 || du -k --max-depth=1 2>/dev/null | sort -rn | head -10 | awk '{printf "%.1fK\t%s\n", $1, $2}'
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            5)
                clear
                echo -e "${BLUE}=== 硬件详情 ===${NC}"
                echo ""
                echo "PCI 设备:"
                lspci 2>/dev/null | head -10
                echo ""
                echo "USB 设备:"
                lsusb 2>/dev/null | head -10
                echo ""
                echo "块设备:"
                lsblk
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            6)
                clear
                echo -e "${BLUE}=== 完整系统报告 ===${NC}"
                echo ""
                echo "=== 操作系统信息 ==="
                uname -a
                [ -f /etc/os-release ] && cat /etc/os-release
                echo ""
                echo "=== CPU 信息 ==="
                lscpu | grep -E "^(Architecture|CPU\(s\)|Thread|Core|Model name)"
                echo ""
                echo "=== 内存信息 ==="
                free -h
                echo ""
                echo "=== 磁盘信息 ==="
                df -h
                echo ""
                echo "=== 网络信息 ==="
                ip addr show 2>/dev/null || ifconfig 2>/dev/null
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            7)
                clear
                echo -e "${BLUE}=== 生成系统报告 ===${NC}"
                report_file="系统报告_$(date +%Y%m%d_%H%M%S).txt"
                echo "正在生成报告到 $report_file..."
                {
                    echo "=== 系统报告 ==="
                    echo "生成时间: $(date)"
                    echo ""
                    echo "=== 系统信息 ==="
                    uname -a
                    echo ""
                    echo "=== CPU 信息 ==="
                    lscpu
                    echo ""
                    echo "=== 内存信息 ==="
                    free -h
                    echo ""
                    echo "=== 磁盘信息 ==="
                    df -h
                    echo ""
                    echo "=== 网络信息 ==="
                    ip addr show
                    echo ""
                    echo "=== 已安装的软件包 ==="
                    dpkg -l 2>/dev/null | wc -l || rpm -qa 2>/dev/null | wc -l
                } > "$report_file"
                echo "报告已保存到 $report_file"
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                sleep 1
                ;;
        esac
    done
}

file_operations() {
    while true; do
        clear
        print_header
        echo -e "${GREEN}=== 文件操作 ===${NC}"
        echo ""
        echo -e "  ${YELLOW}1${NC}) 查找大文件"
        echo -e "  ${YELLOW}2${NC}) 查找旧文件"
        echo -e "  ${YELLOW}3${NC}) 查找重复文件"
        echo -e "  ${YELLOW}4${NC}) 清理临时文件"
        echo -e "  ${YELLOW}5${NC}) 文件权限检查"
        echo -e "  ${YELLOW}6${NC}) 目录树视图"
        echo -e "  ${YELLOW}7${NC}) 按内容搜索文件"
        echo -e "  ${YELLOW}8${NC}) 文本统计"
        echo -e "  ${YELLOW}9${NC}) 文本替换"
        echo -e "  ${YELLOW}10${NC}) 比较文件"
        echo -e "  ${YELLOW}0${NC}) 返回主菜单"
        echo ""
        read -p "请选择选项: " file_opt

        case $file_opt in
            1)
                clear
                echo -e "${BLUE}=== 查找大文件 ===${NC}"
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                read -p "最小文件大小 (MB) (默认: 100): " min_size
                min_size=${min_size:-100}
                echo ""
                echo "正在查找 $dir_path 中大于 ${min_size}MB 的文件..."
                find "$dir_path" -type f -size +"${min_size}M" -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -hr 2>/dev/null || find "$dir_path" -type f -size +"${min_size}M" -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -k1 -h -r 2>/dev/null
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            2)
                clear
                echo -e "${BLUE}=== 查找旧文件 ===${NC}"
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                read -p "天数 (默认: 30):" days
                days=${days:-30}
                echo ""
                echo "正在查找 $dir_path 中超过 ${days} 天的文件..."
                find "$dir_path" -type f -mtime +"$days" -exec ls -lh {} \; 2>/dev/null
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            3)
                clear
                echo -e "${BLUE}=== 查找重复文件 ===${NC}"
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                echo ""
                echo "正在查找重复文件..."
                find "$dir_path" -type f -exec md5sum {} \; 2>/dev/null | sort | uniq -d -w 32 2>/dev/null || find "$dir_path" -type f -exec md5sum {} \; 2>/dev/null | sort | uniq -d
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            4)
                clear
                echo -e "${BLUE}=== 清理临时文件 ===${NC}"
                echo ""
                echo "清理 /tmp 目录..."
                sudo rm -rf /tmp/* 2>/dev/null && echo "已清理 /tmp"
                echo ""
                echo "清理缓存..."
                rm -rf ~/.cache/* 2>/dev/null && echo "已清理 ~/.cache"
                echo ""
                echo "清理缩略图..."
                rm -rf ~/.thumbnails/* 2>/dev/null && echo "已清理 ~/.thumbnails"
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            5)
                clear
                echo -e "${BLUE}=== 文件权限检查 ===${NC}"
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                echo ""
                echo "具有世界可写权限的文件:"
                find "$dir_path" -type f -perm -o+w 2>/dev/null
                echo ""
                echo "具有世界可写权限的目录:"
                find "$dir_path" -type d -perm -o+w 2>/dev/null
                echo ""
                echo "具有 SUID/SGID 位的文件:"
                find "$dir_path" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            6)
                clear
                echo -e "${BLUE}=== 目录树视图 ===${NC}"
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                read -p "最大深度 (默认: 2): " depth
                depth=${depth:-2}
                echo ""
                tree -L "$depth" "$dir_path" 2>/dev/null || find "$dir_path" -maxdepth "$depth" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            7)
                clear
                echo -e "${BLUE}=== 按内容搜索文件 ===${NC}"
                read -p "请输入搜索模式: " pattern
                read -p "请输入目录路径 (默认: 当前目录): " dir_path
                dir_path=${dir_path:-.}
                echo ""
                echo "正在 $dir_path 中搜索 '$pattern'..."
                grep -r "$pattern" "$dir_path" 2>/dev/null --color=always | head -50
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            8)
                clear
                echo -e "${BLUE}=== 文本统计 ===${NC}"
                default_file=$(ls -t *.txt 2>/dev/null | head -1)
                read -p "请输入文件路径 (默认: $default_file): " text_file
                text_file=${text_file:-$default_file}
                echo ""
                if [ -f "$text_file" ]; then
                    echo "文件: $text_file"
                    echo "行数: $(wc -l < "$text_file")"
                    echo "单词数: $(wc -w < "$text_file")"
                    echo "字符数: $(wc -m < "$text_file")"
                    echo "字节数: $(wc -c < "$text_file")"
                    echo ""
                    echo "最常用的单词:"
                    cat "$text_file" | tr -s '[:space:]' '\n' | sort | uniq -c | sort -rn | head -10
                else
                    echo "文件未找到"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            9)
                clear
                echo -e "${BLUE}=== 文本替换 ===${NC}"
                default_file=$(ls -t *.txt 2>/dev/null | head -1)
                read -p "请输入文件路径 (默认: $default_file): " text_file
                text_file=${text_file:-$default_file}
                read -p "请输入要查找的文本: " find_text
                read -p "请输入替换文本 (默认: 空字符串): " replace_text
                replace_text=${replace_text:-}
                echo ""
                if [ -f "$text_file" ]; then
                    sed -i "s/$find_text/$replace_text/g" "$text_file" && echo "替换完成" || echo "替换失败"
                else
                    echo "文件未找到"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            10)
                clear
                echo -e "${BLUE}=== 比较文件 ===${NC}"
                default_file1=$(ls -t *.txt 2>/dev/null | head -1)
                default_file2=$(ls -t *.txt 2>/dev/null | head -2 | tail -1)
                read -p "请输入第一个文件路径 (默认: $default_file1): " file1
                file1=${file1:-$default_file1}
                read -p "请输入第二个文件路径 (默认: $default_file2): " file2
                file2=${file2:-$default_file2}
                echo ""
                if [ -f "$file1" ] && [ -f "$file2" ]; then
                    echo "差异:"
                    diff "$file1" "$file2" || echo "文件相同"
                else
                    echo "一个或两个文件未找到"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                sleep 1
                ;;
        esac
    done
}

network_tools() {
    while true; do
        clear
        print_header
        echo -e "${GREEN}=== 网络工具 ===${NC}"
        echo ""
        echo -e "  ${YELLOW}1${NC}) 网络接口信息"
        echo -e "  ${YELLOW}2${NC}) 检查连接性"
        echo -e "  ${YELLOW}3${NC}) 端口扫描"
        echo -e "  ${YELLOW}4${NC}) 查看开放端口"
        echo -e "  ${YELLOW}5${NC}) 路由追踪"
        echo -e "  ${YELLOW}0${NC}) 返回主菜单"
        echo ""
        read -p "请选择选项: " net_opt

        case $net_opt in
            1)
                clear
                echo -e "${BLUE}=== 网络接口信息 ===${NC}"
                echo ""
                if command -v ip &> /dev/null; then
                    ip addr show
                    echo ""
                    echo "路由表:"
                    ip route show
                elif command -v ifconfig &> /dev/null; then
                    ifconfig
                    echo ""
                    echo "路由表:"
                    route -n
                else
                    echo "未找到网络配置命令"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            2)
                clear
                echo -e "${BLUE}=== 检查连接性 ===${NC}"
                echo ""
                read -p "请输入要 ping 的主机 (默认: google.com): " host
                host=${host:-google.com}
                echo "正在 ping $host..."
                if command -v ping &> /dev/null; then
                    ping -c 4 "$host"
                else
                    echo "未找到 ping 命令"
                fi
                echo ""
                echo "DNS 解析:"
                if command -v nslookup &> /dev/null; then
                    nslookup "$host"
                elif command -v host &> /dev/null; then
                    host "$host"
                else
                    echo "未找到 DNS 解析命令"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            3)
                clear
                echo -e "${BLUE}=== 端口扫描 ===${NC}"
                read -p "请输入目标主机/IP (默认: localhost): " target
                target=${target:-localhost}
                read -p "请输入端口范围 (例如: 1-1000, 默认: 1-100): " port_range
                port_range=${port_range:-1-100}
                echo ""
                echo "正在扫描 $target 的 $port_range 端口..."
                if command -v nmap &> /dev/null; then
                    nmap -p "$port_range" "$target"
                else
                    echo "未找到 nmap，使用 netcat..."
                    for port in $(seq $(echo $port_range | cut -d- -f1) $(echo $port_range | cut -d- -f2)); do
                        timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && echo "端口 $port: 开放" || :
                    done
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            4)
                clear
                echo -e "${BLUE}=== 查看开放端口 ===${NC}"
                echo ""
                echo "监听的 TCP 端口:"
                ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null
                echo ""
                echo "监听的 UDP 端口:"
                ss -ulnp 2>/dev/null || netstat -ulnp 2>/dev/null
                echo ""
                echo "已建立的连接:"
                ss -tn 2>/dev/null | head -20
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            5)
                clear
                echo -e "${BLUE}=== 路由追踪 ===${NC}"
                read -p "请输入目标主机 (默认: baidu.com): " target
                target=${target:-baidu.com}
                echo ""
                echo "正在追踪到 $target 的路由..."
                traceroute "$target" 2>/dev/null || tracepath "$target" 2>/dev/null
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                sleep 1
                ;;
        esac
    done
}

process_system_monitor() {
    while true; do
        clear
        print_header
        echo -e "${GREEN}=== 进程与系统监控 ===${NC}"
        echo ""
        echo -e "  ${YELLOW}1${NC}) 进程管理"
        echo -e "  ${YELLOW}2${NC}) 进程树"
        echo -e "  ${YELLOW}3${NC}) 系统资源"
        echo -e "  ${YELLOW}4${NC}) 实时监控 (htop)"
        echo -e "  ${YELLOW}5${NC}) 系统日志"
        echo -e "  ${YELLOW}6${NC}) 内核消息"
        echo -e "  ${YELLOW}7${NC}) 服务状态"
        echo -e "  ${YELLOW}8${NC}) 启动分析"
        echo -e "  ${YELLOW}0${NC}) 返回主菜单"
        echo ""
        read -p "请选择选项: " mon_opt

        case $mon_opt in
            1)
                clear
                echo -e "${BLUE}=== 进程管理 ===${NC}"
                echo ""
                echo -e "  ${YELLOW}1${NC}) 列出所有进程"
                echo -e "  ${YELLOW}2${NC}) 按名称查找进程"
                echo -e "  ${YELLOW}3${NC}) 终止进程"
                echo -e "  ${YELLOW}0${NC}) 返回"
                echo ""
                read -p "请选择: " proc_sub_opt
                
                case $proc_sub_opt in
                    1)
                        echo ""
                        echo "CPU 占用排行:"
                        ps aux --sort=-%cpu | head -15
                        echo ""
                        echo "内存占用排行:"
                        ps aux --sort=-%mem | head -15
                        echo ""
                        read -p "按 Enter 键继续..."
                        ;;
                    2)
                        read -p "请输入进程名称: " proc_name
                        echo ""
                        ps aux | grep -i "$proc_name" | grep -v grep
                        echo ""
                        read -p "按 Enter 键继续..."
                        ;;
                    3)
                        read -p "请输入进程名称或 PID: " proc_input
                        echo ""
                        if [[ "$proc_input" =~ ^[0-9]+$ ]]; then
                            echo "正在终止 PID $proc_input..."
                            sudo kill -9 "$proc_input" 2>/dev/null && echo "进程已终止" || echo "终止进程失败"
                        else
                            echo "正在查找匹配 '$proc_input' 的进程..."
                            ps aux | grep -i "$proc_input" | grep -v grep
                            read -p "请输入要终止的 PID: " pid
                            sudo kill -9 "$pid" 2>/dev/null && echo "进程已终止" || echo "终止进程失败"
                        fi
                        echo ""
                        read -p "按 Enter 键继续..."
                        ;;
                    0)
                        ;;
                    *)
                        echo -e "${RED}无效选项${NC}"
                        sleep 1
                        ;;
                esac
                ;;
            2)
                clear
                echo -e "${BLUE}=== 进程树 ===${NC}"
                echo ""
                pstree -p 2>/dev/null || ps auxf
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            3)
                clear
                echo -e "${BLUE}=== 系统资源 ===${NC}"
                echo ""
                echo "CPU 使用率:"
                top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
                echo ""
                echo "内存使用情况:"
                free -h
                echo ""
                echo "磁盘使用情况:"
                df -h
                echo ""
                echo "负载平均值:"
                uptime
                echo ""
                echo "运行中的进程数:"
                ps aux | wc -l
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            4)
                clear
                echo -e "${BLUE}=== 实时监控 ===${NC}"
                echo ""
                if command -v htop &> /dev/null; then
                    htop
                else
                    echo "未找到 htop，使用 top..."
                    top
                fi
                ;;
            5)
                clear
                echo -e "${BLUE}=== 系统日志 ===${NC}"
                echo ""
                echo -e "  ${YELLOW}1${NC}) 传统日志"
                echo -e "  ${YELLOW}2${NC}) Journal 日志"
                echo -e "  ${YELLOW}0${NC}) 返回"
                echo ""
                read -p "请选择: " log_opt
                
                case $log_opt in
                    1)
                        echo ""
                        echo "最近的系统日志:"
                        tail -50 /var/log/syslog 2>/dev/null || tail -50 /var/log/messages 2>/dev/null
                        echo ""
                        read -p "按 Enter 键继续..."
                        ;;
                    2)
                        echo ""
                        if command -v journalctl &> /dev/null; then
                            read -p "请输入 journalctl 过滤条件 (例如: -u ssh，留空查看最近日志): " filter
                            if [ -z "$filter" ]; then
                                journalctl -n 50 --no-pager
                            else
                                journalctl $filter --no-pager | tail -50
                            fi
                        else
                            echo "未找到 journalctl"
                        fi
                        echo ""
                        read -p "按 Enter 键继续..."
                        ;;
                    0)
                        ;;
                    *)
                        echo -e "${RED}无效选项${NC}"
                        sleep 1
                        ;;
                esac
                ;;
            6)
                clear
                echo -e "${BLUE}=== 内核消息 ===${NC}"
                echo ""
                echo "最近的内核消息:"
                dmesg | tail -50
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            7)
                clear
                echo -e "${BLUE}=== 服务状态 ===${NC}"
                echo ""
                read -p "请输入服务名称 (留空查看所有运行中服务): " service
                if command -v systemctl &> /dev/null; then
                    if [ -z "$service" ]; then
                        systemctl list-units --type=service --state=running
                    else
                        systemctl status "$service"
                    fi
                elif command -v service &> /dev/null; then
                    if [ -z "$service" ]; then
                        echo "使用 service 命令，无法列出所有运行中服务"
                        echo "请指定服务名称"
                    else
                        service "$service" status
                    fi
                else
                    echo "未找到服务管理命令"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            8)
                clear
                echo -e "${BLUE}=== 启动分析 ===${NC}"
                echo ""
                if command -v systemd-analyze &> /dev/null; then
                    systemd-analyze
                    echo ""
                    echo "服务启动时间:"
                    systemd-analyze blame | head -20
                else
                    echo "系统未使用 systemd，无法分析启动时间"
                    echo "启动时间: $(uptime -p)"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                sleep 1
                ;;
        esac
    done
}

change_apt_source() {
    while true; do
        clear
        print_header
        echo -e "${BLUE}=== 更换软件源 ===${NC}"
        echo ""
        
        # 检测系统信息
        local system_name=$(grep NAME /etc/os-release | head -1 | cut -d= -f2 | sed 's/\"//g')
        local system_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
        local system_version_major=${system_version%%.*}
        local arch=$(uname -m)
        local codename=""
        
        # 获取系统代号
        if [ -f /etc/os-release ]; then
            codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2 | sed 's/\"//g')
        fi
        
        echo "当前系统: $system_name $system_version ($arch)"
        if [ -n "$codename" ]; then
            echo "系统代号: $codename"
        fi
        echo ""
        echo "请选择要更换的镜像源:"
        echo -e "  ${YELLOW}1${NC}) 阿里云镜像"
        echo -e "  ${YELLOW}2${NC}) 腾讯云镜像"
        echo -e "  ${YELLOW}3${NC}) 华为云镜像"
        echo -e "  ${YELLOW}4${NC}) 清华大学镜像"
        echo -e "  ${YELLOW}5${NC}) 恢复默认源"
        echo -e "  ${YELLOW}0${NC}) 返回"
        echo ""
        read -p "请选择: " mirror_choice
        
        # 先创建备份文件，确保恢复默认源时能找到备份
        echo ""
        echo "正在备份当前源..."
        if [ -f /etc/apt/sources.list ]; then
            if [ ! -f /etc/apt/sources.list.backup ]; then
                sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
                echo "已备份到 /etc/apt/sources.list.backup"
            else
                echo "源备份文件已存在"
            fi
        fi
        
        # 备份 sources.list.d 目录下的文件
        if [ -d /etc/apt/sources.list.d ]; then
            if [ ! -d /etc/apt/sources.list.d.backup ]; then
                sudo mkdir -p /etc/apt/sources.list.d.backup
                sudo cp -r /etc/apt/sources.list.d/* /etc/apt/sources.list.d.backup/ 2>/dev/null
                echo "已备份 /etc/apt/sources.list.d 目录"
            else
                echo "sources.list.d 备份目录已存在"
            fi
        fi
        
        case $mirror_choice in
            1)
                MIRROR_URL="mirrors.aliyun.com"
                ;;
            2)
                MIRROR_URL="mirrors.tencent.com"
                ;;
            3)
                MIRROR_URL="mirrors.huaweicloud.com"
                ;;
            4)
                MIRROR_URL="mirrors.tuna.tsinghua.edu.cn"
                ;;
            5)
                echo ""
                echo "正在恢复默认源..."
                local restored=0
                if [ -f /etc/apt/sources.list.backup ]; then
                    sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
                    echo "已恢复默认源"
                    restored=1
                fi
                if [ -d /etc/apt/sources.list.d.backup ]; then
                    sudo rm -rf /etc/apt/sources.list.d/*
                    sudo cp -r /etc/apt/sources.list.d.backup/* /etc/apt/sources.list.d/ 2>/dev/null
                    echo "已恢复 sources.list.d 目录"
                    restored=1
                fi
                if [ $restored -eq 0 ]; then
                    echo "未找到备份文件，可能是首次运行"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                break
                ;;
            0)
                break
                ;;
            *)
                echo "无效选项"
                read -p "按 Enter 键继续..."
                continue
                ;;
        esac
        
        echo ""
        echo "正在更换为 $MIRROR_URL 镜像源..."
        
        # 根据不同的系统类型配置源
        if grep -q "Ubuntu" /etc/os-release; then
            echo "检测到 Ubuntu 系统"
            
            # Ubuntu 源配置
            local ubuntu_codename="$codename"
            
            # 创建新的 sources.list
            sudo bash -c "cat > /etc/apt/sources.list << EOF
# 阿里云 Ubuntu 镜像源
deb http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename} main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-security main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-updates main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-proposed main restricted universe multiverse
deb http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-backports main restricted universe multiverse
deb-src http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename} main restricted universe multiverse
deb-src http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-security main restricted universe multiverse
deb-src http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-updates main restricted universe multiverse
deb-src http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-proposed main restricted universe multiverse
deb-src http://${MIRROR_URL}/ubuntu/ ${ubuntu_codename}-backports main restricted universe multiverse
EOF"
            
            echo "已更新 Ubuntu 源"
            
        elif grep -q "Debian" /etc/os-release; then
            echo "检测到 Debian 系统"
            
            # Debian 源配置
            local debian_codename="$codename"
            
            sudo bash -c "cat > /etc/apt/sources.list << EOF
# 阿里云 Debian 镜像源
deb http://${MIRROR_URL}/debian/ ${debian_codename} main contrib non-free
deb http://${MIRROR_URL}/debian/ ${debian_codename}-updates main contrib non-free
deb http://${MIRROR_URL}/debian/ ${debian_codename}-backports main contrib non-free
deb http://${MIRROR_URL}/debian-security ${debian_codename}/updates main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename} main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename}-updates main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename}-backports main contrib non-free
deb-src http://${MIRROR_URL}/debian-security ${debian_codename}/updates main contrib non-free
EOF"
            
            echo "已更新 Debian 源"
            
        elif grep -q "Kali" /etc/os-release; then
            echo "检测到 Kali Linux 系统"
            
            sudo bash -c "cat > /etc/apt/sources.list << EOF
# 阿里云 Kali Linux 镜像源
deb http://${MIRROR_URL}/kali kali-rolling main non-free contrib
deb-src http://${MIRROR_URL}/kali kali-rolling main non-free contrib
EOF"
            
            echo "已更新 Kali Linux 源"
            
        else
            echo "未知的 Debian 系系统，使用通用配置"
            
            sudo bash -c "cat > /etc/apt/sources.list << EOF
# 阿里云通用镜像源
deb http://${MIRROR_URL}/debian/ ${codename} main contrib non-free
deb http://${MIRROR_URL}/debian/ ${codename}-updates main contrib non-free
deb http://${MIRROR_URL}/debian-security ${codename}/updates main contrib non-free
EOF"
            
            echo "已更新通用源"
        fi
        
        echo ""
        echo "软件源更换完成！"
        echo ""
        
        # 询问用户是否生成缓存
        while true; do
            read -p "是否生成软件源缓存？(默认: Y, 回车确认): " generate_cache
            generate_cache=${generate_cache:-Y}
            if [[ "$generate_cache" == [Yy]* || "$generate_cache" == [Nn]* ]]; then
                break
            else
                echo "无效输入，请输入 Y 或 N，回车默认 Y"
            fi
        done
        if [[ "$generate_cache" == [Yy]* ]]; then
            echo ""
            echo "正在清理缓存..."
            sudo apt clean
            
            echo ""
            echo "正在更新软件包列表..."
            sudo apt update
            echo "缓存生成完成！"
        fi
        
        echo ""
        read -p "按 Enter 键继续..."
        break
    done
}

change_yum_source() {
    while true; do
        clear
        print_header
        echo -e "${BLUE}=== 更换软件源 ===${NC}"
        echo ""
        if [ "$PM" = "apt" ]; then
            change_apt_source
            break
        fi
        
        if [ "$PM" != "yum" ] && [ "$PM" != "dnf" ]; then
            echo "当前系统不支持的包管理器: $PM"
            echo "此功能适用于 yum/dnf/apt 包管理器"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 检测系统信息
        local system_name=$(grep NAME /etc/os-release | head -1 | cut -d= -f2 | sed 's/\"//g')
        local system_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
        local system_version_major=${system_version%%.*}
        local arch=$(uname -m)
        
        echo "当前系统: $system_name $system_version ($arch)"
        echo ""
        echo "请选择要更换的镜像源:"
        echo -e "  ${YELLOW}1${NC}) 阿里云镜像"
        echo -e "  ${YELLOW}2${NC}) 腾讯云镜像"
        echo -e "  ${YELLOW}3${NC}) 华为云镜像"
        echo -e "  ${YELLOW}4${NC}) 恢复默认源"
        echo -e "  ${YELLOW}0${NC}) 返回"
        echo ""
        read -p "请选择: " mirror_choice
        
        # 先创建备份文件，确保恢复默认源时能找到备份
        echo ""
        echo "正在备份当前源..."
        if [ -f /etc/yum.repos.d/CentOS-Base.repo ]; then
            if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.backup ]; then
                sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
                echo "已备份到 /etc/yum.repos.d/CentOS-Base.repo.backup"
            else
                echo "CentOS 源备份文件已存在"
            fi
        fi
        if [ -f /etc/yum.repos.d/Rocky-BaseOS.repo ]; then
            if [ ! -f /etc/yum.repos.d/Rocky-BaseOS.repo.backup ]; then
                sudo cp /etc/yum.repos.d/Rocky-BaseOS.repo /etc/yum.repos.d/Rocky-BaseOS.repo.backup
                echo "已备份到 /etc/yum.repos.d/Rocky-BaseOS.repo.backup"
            else
                echo "Rocky Linux 源备份文件已存在"
            fi
        fi
        if [ -f /etc/yum.repos.d/almalinux-base.repo ]; then
            if [ ! -f /etc/yum.repos.d/almalinux-base.repo.backup ]; then
                sudo cp /etc/yum.repos.d/almalinux-base.repo /etc/yum.repos.d/almalinux-base.repo.backup
                echo "已备份到 /etc/yum.repos.d/almalinux-base.repo.backup"
            else
                echo "AlmaLinux 源备份文件已存在"
            fi
        fi
        if [ -f /etc/yum.repos.d/fedora.repo ]; then
            if [ ! -f /etc/yum.repos.d/fedora.repo.backup ]; then
                sudo cp /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.backup
                echo "已备份到 /etc/yum.repos.d/fedora.repo.backup"
            else
                echo "Fedora 源备份文件已存在"
            fi
        fi
        if [ -f /etc/yum.repos.d/redhat.repo ]; then
            if [ ! -f /etc/yum.repos.d/redhat.repo.backup ]; then
                sudo cp /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/redhat.repo.backup
                echo "已备份到 /etc/yum.repos.d/redhat.repo.backup"
            else
                echo "Red Hat 源备份文件已存在"
            fi
        fi
        
        case $mirror_choice in
            1)
                MIRROR_URL="mirrors.aliyun.com"
                ;;
            2)
                MIRROR_URL="mirrors.tencent.com"
                ;;
            3)
                MIRROR_URL="mirrors.huaweicloud.com"
                ;;
            4)
                echo ""
                echo "正在恢复默认源..."
                local restored=0
                if [ -f /etc/yum.repos.d/CentOS-Base.repo.backup ]; then
                    sudo cp /etc/yum.repos.d/CentOS-Base.repo.backup /etc/yum.repos.d/CentOS-Base.repo
                    echo "已恢复 CentOS 默认源"
                    restored=1
                fi
                if [ -f /etc/yum.repos.d/Rocky-BaseOS.repo.backup ]; then
                    sudo cp /etc/yum.repos.d/Rocky-BaseOS.repo.backup /etc/yum.repos.d/Rocky-BaseOS.repo
                    echo "已恢复 Rocky Linux 默认源"
                    restored=1
                fi
                if [ -f /etc/yum.repos.d/almalinux-base.repo.backup ]; then
                    sudo cp /etc/yum.repos.d/almalinux-base.repo.backup /etc/yum.repos.d/almalinux-base.repo
                    echo "已恢复 AlmaLinux 默认源"
                    restored=1
                fi
                if [ -f /etc/yum.repos.d/fedora.repo.backup ]; then
                    sudo cp /etc/yum.repos.d/fedora.repo.backup /etc/yum.repos.d/fedora.repo
                    echo "已恢复 Fedora 默认源"
                    restored=1
                fi
                if [ -f /etc/yum.repos.d/redhat.repo.backup ]; then
                    sudo cp /etc/yum.repos.d/redhat.repo.backup /etc/yum.repos.d/redhat.repo
                    echo "已恢复 Red Hat 默认源"
                    restored=1
                fi
                if [ $restored -eq 0 ]; then
                    echo "未找到备份文件，可能是首次运行"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                break
                ;;
            0)
                break
                ;;
            *)
                echo "无效选项"
                read -p "按 Enter 键继续..."
                continue
                ;;
        esac
        
        echo ""
        echo "正在更换为 $MIRROR_URL 镜像源..."
        
        # 定义变量
        local SOURCE="$MIRROR_URL"
        local WEB_PROTOCOL="http"
        local Dir_YumRepos="/etc/yum.repos.d"
        
        # 进入 repo 目录
        cd "$Dir_YumRepos"
        
        # 检测是否为 CentOS 系统
        if grep -q "CentOS" /etc/os-release; then
            # 检测 CentOS 版本
            local centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
            local centos_version_major=${centos_version%%.*}
            local SOURCE_BRANCH
            
            echo "检测到 CentOS $centos_version 系统"
            
            # 获取实际的架构
            local actual_arch=$(uname -m)
            echo "当前架构: $actual_arch"
            
            if [ "$actual_arch" == "x86_64" ]; then
                SOURCE_BRANCH="centos-vault"
            else
                SOURCE_BRANCH="centos-altarch"
            fi
            
            # 修改源文件
            sudo sed -e "s|^#baseurl=http|baseurl=${WEB_PROTOCOL}|g" \
                -e "s|^mirrorlist=|#mirrorlist=|g" \
                -i \
                CentOS-*
            
            if [ "$centos_version_major" == "8" ]; then
                # CentOS 8
                sudo sed -e "s|mirror.centos.org/\$contentdir|mirror.centos.org/${SOURCE_BRANCH}|g" \
                    -e "s|\$releasever|8.5.2111|g" \
                    -i \
                    CentOS-*
                sudo sed -e "s|vault.centos.org/\$contentdir|vault.centos.org/${SOURCE_BRANCH}|g" \
                    -i \
                    CentOS-Linux-Sources.repo
            elif [ "$centos_version_major" == "7" ]; then
                # CentOS 7
                sudo sed -e "s|mirror.centos.org/centos|mirror.centos.org/${SOURCE_BRANCH}|g" \
                    -e "s|\$releasever|7.9.2009|g" \
                    -i \
                    CentOS-*
                sudo sed -e "s|vault.centos.org/centos|vault.centos.org/${SOURCE_BRANCH}|g" \
                    -i \
                    CentOS-Sources.repo
            fi
            
            # 替换镜像源地址
            sudo sed -e "s|mirror.centos.org|${SOURCE}|g" \
                -e "s|vault.centos.org|${SOURCE}|g" \
                -i \
                CentOS-*
                
            echo "已更新 CentOS 源，使用 $SOURCE_BRANCH 分支"
        elif grep -q "Rocky" /etc/os-release; then
            echo "检测到 Rocky Linux 系统"
            local rocky_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
            local rocky_version_major=${rocky_version%%.*}
            local SOURCE_BRANCH="rocky"
            
            if [ "$rocky_version_major" == "9" ] || [ "$rocky_version_major" == "10" ]; then
                sudo sed -e "s|^#baseurl=http|baseurl=${WEB_PROTOCOL}|g" \
                    -e "s|^mirrorlist=|#mirrorlist=|g" \
                    -e "s|dl.rockylinux.org/\$contentdir|${SOURCE}/${SOURCE_BRANCH}|g" \
                    -i \
                    rocky.repo \
                    rocky-addons.repo \
                    rocky-devel.repo \
                    rocky-extras.repo
            elif [ "$rocky_version_major" == "8" ]; then
                sudo sed -e "s|^#baseurl=http|baseurl=${WEB_PROTOCOL}|g" \
                    -e "s|^mirrorlist=|#mirrorlist=|g" \
                    -e "s|dl.rockylinux.org/\$contentdir|${SOURCE}/${SOURCE_BRANCH}|g" \
                    -i \
                    Rocky-*
            fi
            
            echo "已更新 Rocky Linux 源"
        elif grep -q "AlmaLinux" /etc/os-release; then
            echo "检测到 AlmaLinux 系统"
            local almalinux_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
            local almalinux_version_major=${almalinux_version%%.*}
            local SOURCE_BRANCH="almalinux"
            
            if [ "$almalinux_version_major" == "10" ]; then
                sudo sed -e "s|^# baseurl=https|baseurl=${WEB_PROTOCOL}|g" \
                    -e "s|^mirrorlist=|#mirrorlist=|g" \
                    -e "s|vault.almalinux.org|${SOURCE}/${SOURCE_BRANCH}-vault|g" \
                    -e "s|repo.almalinux.org/almalinux|${SOURCE}/${SOURCE_BRANCH}|g" \
                    -i \
                    almalinux-appstream.repo \
                    almalinux-baseos.repo \
                    almalinux-crb.repo \
                    almalinux-extras.repo \
                    almalinux-highavailability.repo \
                    almalinux-nfv.repo \
                    almalinux-rt.repo \
                    almalinux-saphana.repo \
                    almalinux-sap.repo
            elif [ "$almalinux_version_major" == "9" ]; then
                sudo sed -e "s|^# baseurl=https|baseurl=${WEB_PROTOCOL}|g" \
                    -e "s|^mirrorlist=|#mirrorlist=|g" \
                    -e "s|repo.almalinux.org/vault|${SOURCE}/${SOURCE_BRANCH}-vault|g" \
                    -e "s|repo.almalinux.org/almalinux|${SOURCE}/${SOURCE_BRANCH}|g" \
                    -i \
                    almalinux-appstream.repo \
                    almalinux-baseos.repo \
                    almalinux-crb.repo \
                    almalinux-extras.repo \
                    almalinux-highavailability.repo \
                    almalinux-nfv.repo \
                    almalinux-plus.repo \
                    almalinux-resilientstorage.repo \
                    almalinux-rt.repo \
                    almalinux-sap.repo \
                    almalinux-saphana.repo
            elif [ "$almalinux_version_major" == "8" ]; then
                sudo sed -e "s|^mirrorlist=|#mirrorlist=|g" \
                    -e "s|^# baseurl=https|baseurl=${WEB_PROTOCOL}|g" \
                    -e "s|repo.almalinux.org/vault|${SOURCE}/${SOURCE_BRANCH}-vault|g" \
                    -e "s|repo.almalinux.org/almalinux|${SOURCE}/${SOURCE_BRANCH}|g" \
                    -i \
                    almalinux-ha.repo \
                    almalinux-nfv.repo \
                    almalinux-plus.repo \
                    almalinux-powertools.repo \
                    almalinux-resilientstorage.repo \
                    almalinux-rt.repo \
                    almalinux-sap.repo \
                    almalinux-saphana.repo \
                    almalinux.repo
            fi
            
            echo "已更新 AlmaLinux 源"
        elif grep -q "Fedora" /etc/os-release; then
            echo "检测到 Fedora 系统"
            local fedora_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
            local SOURCE_BRANCH="fedora"
            if [ "$fedora_version" -lt 39 ]; then
                SOURCE_BRANCH="fedora-archive"
            fi
            
            # 自 Fedora 39 起不再使用 modular 仓库
            local fedora_repo_files="fedora.repo fedora-updates.repo fedora-updates-testing.repo"
            if [ "$fedora_version" -lt 39 ]; then
                fedora_repo_files="${fedora_repo_files} fedora-modular.repo fedora-updates-modular.repo fedora-updates-testing-modular.repo"
            fi
            
            sudo sed -e "s|^metalink=|#metalink=|g" \
                -e "s|^#baseurl=http|baseurl=${WEB_PROTOCOL}|g" \
                -e "s|download.example/pub/fedora/linux|${SOURCE}/${SOURCE_BRANCH}|g" \
                -i \
                $fedora_repo_files
                
            echo "已更新 Fedora 源"
        elif [ -f /etc/yum.repos.d/redhat.repo ]; then
            echo "Red Hat 系统需要手动配置订阅"
            echo "请访问 https://access.redhat.com/ 进行订阅"
        else
            echo "未找到软件源配置文件"
        fi
        
        echo ""
        echo "软件源更换完成！"
        echo ""
        
        # 询问用户是否生成缓存
        while true; do
            read -p "是否生成软件源缓存？(默认: Y, 回车确认): " generate_cache
            generate_cache=${generate_cache:-Y}
            if [[ "$generate_cache" == [Yy]* || "$generate_cache" == [Nn]* ]]; then
                break
            else
                echo "无效输入，请输入 Y 或 N，回车默认 Y"
            fi
        done
        if [[ "$generate_cache" == [Yy]* ]]; then
            echo ""
            echo "正在清理缓存..."
            sudo yum clean all 2>/dev/null || sudo dnf clean all 2>/dev/null
            
            echo ""
            echo "正在生成新缓存..."
            sudo yum makecache 2>/dev/null || sudo dnf makecache 2>/dev/null
            echo "缓存生成完成！"
        fi
        
        # 询问用户是否安装额外的源拓展
        while true; do
            read -p "是否安装 EPEL 额外源拓展？(默认: Y, 回车确认): " install_epel
            install_epel=${install_epel:-Y}
            if [[ "$install_epel" == [Yy]* || "$install_epel" == [Nn]* ]]; then
                break
            else
                echo "无效输入，请输入 Y 或 N，回车默认 Y"
            fi
        done
        if [[ "$install_epel" == [Yy]* ]]; then
            echo ""
            echo "正在安装 EPEL 源..."
            
            # 定义变量
            local SOURCE="$MIRROR_URL"
            local WEB_PROTOCOL="http"
            local Dir_YumRepos="/etc/yum.repos.d"
            
            # 进入 repo 目录
            cd "$Dir_YumRepos"
            
            # 检测是否为 CentOS 系统
            if grep -q "CentOS" /etc/os-release; then
                local centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
                local centos_version_major=${centos_version%%.*}
                local EPEL_BRANCH
                
                echo "检测到 CentOS $centos_version 系统"
                
                # 获取实际的架构
                local actual_arch=$(uname -m)
                echo "当前架构: $actual_arch"
                
                # 统一使用 epel 分支，阿里云等镜像站的 EPEL 7 源路径不需要 archive
                EPEL_BRANCH="epel"
                
                # 安装 EPEL 源
                local epel_version="$centos_version_major"
                
                # 首先删除现有的 EPEL 源文件
                if [ -d "/etc/yum.repos.d" ]; then
                    ls /etc/yum.repos.d | grep epel -q
                    [ $? -eq 0 ] && sudo rm -rf /etc/yum.repos.d/epel*
                fi
                
                # 首先获取系统版本和架构
                local epel_version_major="$epel_version"
                local actual_arch=$(uname -m)
                
                # 下载 EPEL GPG 密钥
                echo "正在下载 EPEL GPG 密钥..."
                if [ "$epel_version" == "7" ]; then
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null || \
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null
                else
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null || \
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null
                fi
                
                # 生成 EPEL 源文件
                if [ "$epel_version" == "7" ]; then
                    # EPEL 7 源配置
                    sudo bash -c "cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - $actual_arch
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/$actual_arch
enabled=1
gpgcheck=0

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $actual_arch - Debug
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/$actual_arch/debug
enabled=0
gpgcheck=0

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $actual_arch - Source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/SRPMS
enabled=0
gpgcheck=0
EOF"
                else
                    # 其他版本 EPEL 源配置
                    sudo bash -c "cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/$actual_arch
enabled=1
gpgcheck=0
countme=1

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - Debug
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/$actual_arch/debug
enabled=0
gpgcheck=0

[epel-source]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - Source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/source/tree
enabled=0
gpgcheck=0
EOF"
                fi
            elif grep -q "Rocky" /etc/os-release || grep -q "AlmaLinux" /etc/os-release; then
                # Rocky Linux 或 AlmaLinux 系统
                local epel_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
                local epel_version_major=${epel_version%%.*}
                local epel_version="$epel_version_major"
                
                # 首先删除现有的 EPEL 源文件
                if [ -d "/etc/yum.repos.d" ]; then
                    ls /etc/yum.repos.d | grep epel -q
                    [ $? -eq 0 ] && sudo rm -rf /etc/yum.repos.d/epel*
                fi
                
                # 首先获取系统版本和架构
                local epel_version_major="$epel_version"
                local actual_arch=$(uname -m)
                
                # 下载 EPEL GPG 密钥
                echo "正在下载 EPEL GPG 密钥..."
                if [ "$epel_version" == "7" ]; then
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null || \
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null
                else
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null || \
                    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null
                fi
                
                # 生成 EPEL 源文件
                if [ "$epel_version" == "7" ]; then
                    # EPEL 7 源配置
                    sudo bash -c "cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - $actual_arch
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/$actual_arch
enabled=1
gpgcheck=0

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $actual_arch - Debug
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/$actual_arch/debug
enabled=0
gpgcheck=0

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $actual_arch - Source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/SRPMS
enabled=0
gpgcheck=0
EOF"
                else
                    # 其他版本 EPEL 源配置
                    sudo bash -c "cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/$actual_arch
enabled=1
gpgcheck=0
countme=1

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - Debug
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/$actual_arch/debug
enabled=0
gpgcheck=0

[epel-source]
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - Source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/source/tree
enabled=0
gpgcheck=0
EOF"
                fi
                
                # 启用所需的仓库（EPEL 需要结合 PowerTools / CRB 使用）
                if [ "$epel_version_major" -eq 9 ] || [ "$epel_version_major" -eq 10 ]; then
                    sudo dnf config-manager --set-enabled crb >/dev/null 2>&1
                elif [ "$epel_version_major" -eq 8 ]; then
                    sudo dnf config-manager --set-enabled powertools >/dev/null 2>&1
                fi
            elif grep -q "Fedora" /etc/os-release; then
                echo "Fedora 系统默认已包含 EPEL 兼容的源"
                echo "无需单独安装 EPEL 源"
            else
                echo "当前系统安装 EPEL 源的方法可能不同"
                echo "请参考系统文档进行安装"
            fi
            
            # 生成 EPEL 缓存
            if [[ "$generate_cache" == [Yy]* ]]; then
                echo ""
                echo "正在生成 EPEL 缓存..."
                if sudo yum makecache; then
                    echo "EPEL 缓存生成成功！"
                elif sudo dnf makecache; then
                    echo "EPEL 缓存生成成功！"
                else
                    echo "EPEL 缓存生成失败，请检查网络连接和源配置"
                fi
            fi
        fi
        
        echo ""
        read -p "按 Enter 键继续..."
    done
}

manage_swap() {
    while true; do
        clear
        print_header
        echo -e "${BLUE}=== 管理 swap 交换内存 ===${NC}"
        echo ""
        echo "当前 swap 状态:"
        free -h | grep -i swap
        echo ""
        echo "当前 swap 分区信息:"
        swapon --show
        echo ""
        swap_files=$(swapon --show --noheadings | grep -v "TYPE=partition" | awk '{print $1}')
        swap_partitions=$(swapon --show --noheadings | grep "TYPE=partition" | awk '{print $1}')
        
        if [ -n "$swap_files" ]; then
            echo "Swap 文件:"
            echo "$swap_files"
            echo ""
        fi
        
        if [ -n "$swap_partitions" ]; then
            echo "Swap 分区:"
            echo "$swap_partitions"
            echo ""
        fi
        
        echo "请选择操作:"
        echo -e "  ${YELLOW}1${NC}) 添加 swap 文件"
        echo -e "  ${YELLOW}2${NC}) 删除 swap 文件"
        echo -e "  ${YELLOW}3${NC}) 调整 swappiness 值"
        echo -e "  ${YELLOW}4${NC}) 查看 swappiness 值"
        echo -e "  ${YELLOW}0${NC}) 返回"
        echo ""
        read -p "请选择: " swap_opt
        
        case $swap_opt in
            1)
                clear
                echo -e "${BLUE}=== 添加 swap 文件 ===${NC}"
                echo ""
                
                # 显示当前内存信息
                echo "当前内存信息:"
                free -h | grep -E "Mem:|Swap:"
                echo ""
                
                # 获取内存大小（GB）
                local mem_total_gb=$(free -g | awk '/^Mem:/{print $2}')
                local mem_total_mb=$(free -m | awk '/^Mem:/{print $2}')
                
                # 计算两倍内存大小
                local double_mem=$((mem_total_gb * 2))
                if [ $double_mem -eq 0 ]; then
                    double_mem=$((mem_total_mb * 2 / 1024))
                fi
                if [ $double_mem -eq 0 ]; then
                    double_mem=2
                fi
                
                echo "请选择 swap 大小:"
                echo -e "  ${YELLOW}1${NC}) 两倍于内存大小 (${double_mem} GB)"
                echo -e "  ${YELLOW}2${NC}) 自定义大小"
                echo ""
                read -p "请选择 (默认: 1): " size_choice
                size_choice=${size_choice:-1}
                
                case $size_choice in
                    1)
                        swap_size=$double_mem
                        echo "将创建 ${swap_size} GB 的 swap 文件（两倍于内存）"
                        ;;
                    2)
                        read -p "请输入 swap 文件大小 (GB) (默认: 2): " swap_size
                        swap_size=${swap_size:-2}
                        ;;
                    *)
                        swap_size=$double_mem
                        ;;
                esac
                
                read -p "请输入 swap 文件路径 (默认: /swapfile): " swap_file
                swap_file=${swap_file:-/swapfile}
                
                echo ""
                echo "正在创建 $swap_size GB 的 swap 文件..."
                
                if [ -f "$swap_file" ]; then
                    echo "文件 $swap_file 已存在"
                    read -p "是否删除并重新创建? (y/N): " confirm
                    if [[ "$confirm" =~ ^[Yy]$ ]]; then
                        sudo swapoff "$swap_file" 2>/dev/null
                        sudo rm -f "$swap_file"
                    else
                        echo "操作已取消"
                        echo ""
                        read -p "按 Enter 键继续..."
                        break
                    fi
                fi
                
                sudo dd if=/dev/zero of="$swap_file" bs=1G count="$swap_size" status=progress 2>/dev/null || {
                    echo "创建 swap 文件失败"
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                }
                
                echo "正在设置权限..."
                sudo chmod 600 "$swap_file"
                
                echo "正在设置为 swap..."
                sudo mkswap "$swap_file"
                
                echo "正在启用 swap..."
                sudo swapon "$swap_file"
                
                echo ""
                echo "正在添加到 /etc/fstab..."
                if ! grep -q "$swap_file" /etc/fstab; then
                    echo "$swap_file none swap sw 0 0" | sudo tee -a /etc/fstab
                    echo "已添加到 /etc/fstab"
                else
                    echo "/etc/fstab 中已存在该配置"
                fi
                
                echo ""
                echo "swap 文件创建完成！"
                echo ""
                echo "当前 swap 状态:"
                free -h | grep -i swap
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            2)
                clear
                echo -e "${BLUE}=== 删除 swap 文件 ===${NC}"
                echo ""
                echo "当前 swap 配置:"
                swap_files=$(swapon --show --noheadings | grep -v "TYPE=partition" | awk '{print $1}')
                swap_partitions=$(swapon --show --noheadings | grep "TYPE=partition" | awk '{print $1}')
                
                if [ -z "$swap_files" ] && [ -z "$swap_partitions" ]; then
                    echo "未找到 swap 文件或分区"
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                fi
                
                if [ -n "$swap_files" ]; then
                    echo "Swap 文件:"
                    echo "$swap_files"
                fi
                
                if [ -n "$swap_partitions" ]; then
                    echo "Swap 分区:"
                    echo "$swap_partitions"
                    echo ""
                    echo -e "${YELLOW}注意: swap 分区无法通过此工具删除，只能禁用${NC}"
                    echo -e "${YELLOW}如需删除分区，请使用 fdisk 或 parted 等分区工具${NC}"
                fi
                echo ""
                
                if [ -z "$swap_files" ] && [ -n "$swap_partitions" ]; then
                    echo -e "${RED}当前系统只有 swap 分区，没有 swap 文件${NC}"
                    echo -e "${RED}swap 分区无法删除，只能禁用${NC}"
                    echo ""
                    read -p "是否要禁用 swap 分区? (y/N): " confirm_disable
                    if [[ "$confirm_disable" =~ ^[Yy]$ ]]; then
                        echo "正在禁用所有 swap..."
                        sudo swapoff -a 2>/dev/null || echo "禁用失败"
                        echo "swap 已禁用"
                        
                        echo ""
                        echo "注意: swap 分区仍然存在，只是被禁用了"
                        echo "如需永久删除分区，请使用 fdisk 或 parted 等分区工具"
                    else
                        echo "操作已取消"
                    fi
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                fi
                
                default_swap=$(echo "$swap_files" | head -1)
                read -p "请输入要删除的 swap 文件路径 (默认: $default_swap): " swap_file
                swap_file=${swap_file:-$default_swap}
                
                if [ -z "$swap_file" ]; then
                    echo "路径不能为空"
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                fi
                
                # 检查输入的是否是swap分区
                is_swap_partition=0
                if [ -n "$swap_partitions" ]; then
                    while IFS= read -r partition; do
                        if [ "$partition" = "$swap_file" ]; then
                            is_swap_partition=1
                            break
                        fi
                    done <<< "$swap_partitions"
                fi
                
                if [ $is_swap_partition -eq 1 ]; then
                    echo -e "${RED}错误: $swap_file 是 swap 分区，无法删除${NC}"
                    echo ""
                    echo -e "${YELLOW}swap 分区无法通过此工具删除，只能禁用${NC}"
                    echo ""
                    read -p "是否要禁用此 swap 分区? (y/N): " confirm_disable
                    if [[ "$confirm_disable" =~ ^[Yy]$ ]]; then
                        echo "正在禁用 swap 分区..."
                        sudo swapoff "$swap_file" 2>/dev/null || echo "禁用失败或未启用"
                        echo "swap 分区已禁用"
                        
                        echo ""
                        echo "注意: swap 分区仍然存在，只是被禁用了"
                        echo "如需永久删除分区，请使用 fdisk 或 parted 等分区工具"
                    else
                        echo "操作已取消"
                    fi
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                fi
                
                if [ ! -f "$swap_file" ]; then
                    echo "错误: $swap_file 不是有效的 swap 文件"
                    echo ""
                    read -p "按 Enter 键继续..."
                    break
                fi
                
                read -p "确认删除 $swap_file? (y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    echo "正在禁用 swap..."
                    sudo swapoff "$swap_file" 2>/dev/null || echo "禁用失败或未启用"
                    
                    echo "正在从 /etc/fstab 中删除..."
                    sudo sed -i "\|$swap_file|d" /etc/fstab
                    
                    echo "正在删除文件..."
                    sudo rm -f "$swap_file"
                    
                    echo ""
                    echo "swap 文件已删除"
                else
                    echo "操作已取消"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            3)
                clear
                echo -e "${BLUE}=== 调整 swappiness 值 ===${NC}"
                echo ""
                current_swappiness=$(cat /proc/sys/vm/swappiness)
                echo "当前 swappiness 值: $current_swappiness"
                echo ""
                echo "swappiness 值说明:"
                echo "  0-10: 尽量不使用 swap"
                echo "  60: 默认值，平衡使用"
                echo "  100: 积极使用 swap"
                echo ""
                read -p "请输入新的 swappiness 值 (0-100, 默认: 60): " new_swappiness
                new_swappiness=${new_swappiness:-60}
                
                if [[ "$new_swappiness" =~ ^[0-9]+$ ]] && [ "$new_swappiness" -ge 0 ] && [ "$new_swappiness" -le 100 ]; then
                    echo "正在设置 swappiness 为 $new_swappiness..."
                    sudo sysctl vm.swappiness="$new_swappiness"
                    
                    echo "正在写入 /etc/sysctl.conf..."
                    if grep -q "vm.swappiness" /etc/sysctl.conf; then
                        sudo sed -i "s/vm.swappiness=.*/vm.swappiness=$new_swappiness/" /etc/sysctl.conf
                    else
                        echo "vm.swappiness=$new_swappiness" | sudo tee -a /etc/sysctl.conf
                    fi
                    
                    echo ""
                    echo "swappiness 已设置为 $new_swappiness"
                    echo "新值: $(cat /proc/sys/vm/swappiness)"
                else
                    echo "无效的值，请输入 0-100 之间的数字"
                fi
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            4)
                clear
                echo -e "${BLUE}=== 查看 swappiness 值 ===${NC}"
                echo ""
                echo "当前 swappiness 值: $(cat /proc/sys/vm/swappiness)"
                echo ""
                echo "swappiness 值说明:"
                echo "  0-10: 尽量不使用 swap"
                echo "  60: 默认值，平衡使用"
                echo "  100: 积极使用 swap"
                echo ""
                echo "swap 使用情况:"
                free -h | grep -i swap
                echo ""
                echo "swap 详细信息:"
                swapon --show
                echo ""
                read -p "按 Enter 键继续..."
                ;;
            0)
                break
                ;;
            *)
                echo "无效选项"
                sleep 1
                ;;
        esac
    done
}

download_with_mirrors() {
    local url=$1
    local output=$2
    local mirrors=(
        "https://mirrors.aliyun.com/${url#*://}"
    )
    
    for mirror in "${mirrors[@]}"; do
        echo "尝试从镜像下载: $mirror"
        if command -v wget &> /dev/null; then
            if wget -q --show-progress -O "$output" "$mirror" 2>/dev/null; then
                if [ -f "$output" ]; then
                    if [ -s "$output" ]; then
                        file_type=$(file "$output" 2>/dev/null)
                        echo "文件类型: $file_type"
                        if echo "$file_type" | grep -i "xz\|gzip\|tar\|compressed\|archive" &>/dev/null; then
                            echo "下载成功!"
                            return 0
                        else
                            echo "下载的文件格式不正确，尝试下一个镜像..."
                            rm -f "$output"
                        fi
                    else
                        echo "下载的文件为空，尝试下一个镜像..."
                        rm -f "$output"
                    fi
                else
                    echo "下载的文件不存在，尝试下一个镜像..."
                fi
            else
                echo "下载失败，尝试下一个镜像..."
            fi
        elif command -v curl &> /dev/null; then
            if curl -L -o "$output" --progress-bar "$mirror" 2>/dev/null; then
                if [ -f "$output" ]; then
                    if [ -s "$output" ]; then
                        file_type=$(file "$output" 2>/dev/null)
                        echo "文件类型: $file_type"
                        if echo "$file_type" | grep -i "xz\|gzip\|tar\|compressed\|archive" &>/dev/null; then
                            echo "下载成功!"
                            return 0
                        else
                            echo "下载的文件格式不正确，尝试下一个镜像..."
                            rm -f "$output"
                        fi
                    else
                        echo "下载的文件为空，尝试下一个镜像..."
                        rm -f "$output"
                    fi
                else
                    echo "下载的文件不存在，尝试下一个镜像..."
                fi
            else
                echo "下载失败，尝试下一个镜像..."
            fi
        fi
        echo "下载失败，尝试下一个镜像..."
    done
    
    echo "所有镜像源下载失败"
    return 1
}



install_python() {
    while true; do
        clear
        print_header
        echo -e "${BLUE}=== 安装 Python ===${NC}"
        echo ""
        echo "可用版本:"
        echo "  1) Python 3.8.20"
        echo "  2) Python 3.9.21"
        echo "  3) Python 3.10.19"
        echo "  4) Python 3.11.14"
        echo "  5) Python 3.12.12"
        echo "  6) 安装其他版本"
        echo ""
        read -p "请选择版本 (默认: 3.12): " python_version
        python_version=${python_version:-5}
        
        case $python_version in
            1) python_ver="3.8.20" ;; 
            2) python_ver="3.9.21" ;; 
            3) python_ver="3.10.19" ;; 
            4) python_ver="3.11.14" ;; 
            5) python_ver="3.12.12" ;; 
            6) 
                read -p "请输入要安装的 Python 版本 (例如: 3.7.10): " python_ver
                while [ -z "$python_ver" ]; do
                    read -p "版本号不能为空，请重新输入: " python_ver
                done
                ;; 
            *) python_ver="3.12.12" ;; 
        esac
        
        read -p "请输入安装目录 (默认: /usr/local/python3): " install_dir
        install_dir=${install_dir:-/usr/local/python3}
        
        echo ""
        echo "正在下载 Python $python_ver..."
        cd "$install_dir" 2>/dev/null || { sudo mkdir -p "$install_dir" && cd "$install_dir"; }
        
        # 检查并自动安装编译依赖
        echo "检查并自动安装编译依赖..."
        local dependencies_installed=1
        
        if [ "$PM" = "apt" ]; then
            echo "使用 apt 包管理器安装依赖..."
            if sudo apt update && sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget curl libbz2-dev; then
                echo "✓ 依赖安装成功"
            else
                echo "✗ 依赖安装失败"
                dependencies_installed=0
            fi
        elif [ "$PM" = "yum" ]; then
            echo "使用 yum 包管理器安装依赖..."
            if sudo yum groupinstall -y 'Development Tools' && sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel; then
                echo "✓ 依赖安装成功"
            else
                echo "✗ 依赖安装失败"
                dependencies_installed=0
            fi
        elif [ "$PM" = "dnf" ]; then
            echo "使用 dnf 包管理器安装依赖..."
            if sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel; then
                echo "✓ 依赖安装成功"
            else
                echo "✗ 依赖安装失败"
                dependencies_installed=0
            fi
        else
            echo "检查基本编译工具..."
            if command -v gcc &> /dev/null && command -v make &> /dev/null; then
                echo "✓ 基本编译工具已安装"
            else
                echo "✗ 缺少编译工具"
                echo "请手动安装编译依赖后重试"
                dependencies_installed=0
            fi
        fi
        
        if [ $dependencies_installed -eq 0 ]; then
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        # Python 专用镜像源
        local python_mirrors=(
            "https://mirrors.aliyun.com/python-release/source/Python-${python_ver}.tar.xz"
        )
        
        local downloaded=0
        for mirror in "${python_mirrors[@]}"; do
            echo "尝试从 Python 镜像下载: $mirror"
            if command -v wget &> /dev/null; then
                if wget -q --show-progress -O "Python-${python_ver}.tar.xz" "$mirror" 2>/dev/null; then
                    if [ -f "Python-${python_ver}.tar.xz" ] && [ -s "Python-${python_ver}.tar.xz" ]; then
                        echo "Python 镜像下载成功!"
                        downloaded=1
                        break
                    else
                        echo "Python 镜像下载失败，尝试下一个..."
                        rm -f "Python-${python_ver}.tar.xz"
                    fi
                else
                    echo "Python 镜像下载失败，尝试下一个..."
                fi
            elif command -v curl &> /dev/null; then
                if curl -L -o "Python-${python_ver}.tar.xz" --progress-bar "$mirror" 2>/dev/null; then
                    if [ -f "Python-${python_ver}.tar.xz" ] && [ -s "Python-${python_ver}.tar.xz" ]; then
                        echo "Python 镜像下载成功!"
                        downloaded=1
                        break
                    else
                        echo "Python 镜像下载失败，尝试下一个..."
                        rm -f "Python-${python_ver}.tar.xz"
                    fi
                else
                    echo "Python 镜像下载失败，尝试下一个..."
                fi
            fi
        done
        
        if [ $downloaded -eq 0 ]; then
            echo "Python 专用镜像下载失败，尝试通用镜像..."
            download_with_mirrors "https://www.python.org/ftp/python/${python_ver%.*}/Python-${python_ver}.tar.xz" "Python-${python_ver}.tar.xz" || {
                echo ""
                read -p "按 Enter 键继续..."
                break
            }
        fi
        
        if [ ! -f "Python-${python_ver}.tar.xz" ]; then
            echo "下载的文件不存在"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        if [ ! -s "Python-${python_ver}.tar.xz" ]; then
            echo "下载的文件为空"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        if ! tar -tf "Python-${python_ver}.tar.xz" &>/dev/null; then
            echo "下载的文件损坏，请删除后重试"
            rm -f "Python-${python_ver}.tar.xz"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 转换为绝对路径
        install_dir=$(realpath "$install_dir")
        echo "使用绝对安装目录: $install_dir"
        
        # 解压文件
        if [ -f "Python-${python_ver}.tar.xz" ]; then
            echo "正在解压 Python-${python_ver}.tar.xz..."
            tar -xf Python-${python_ver}.tar.xz
        else
            echo "Python 压缩文件不存在"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 查找解压后的目录
        local extract_dir=$(find . -name "Python-*" -type d | grep -E "Python-${python_ver%.*}" | head -1)
        if [ -z "$extract_dir" ]; then
            local extract_dir=$(find . -name "*Python*" -type d | grep -E "${python_ver%.*}" | head -1)
        fi
        
        if [ -z "$extract_dir" ]; then
            echo "无法找到解压后的 Python 目录"
            echo "请手动检查当前目录: $(pwd)"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        echo "找到解压目录: $extract_dir"
        cd "$extract_dir"
        
        # 检查系统内存
        echo "检查系统内存..."
        local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        if [ "$mem_total" -lt 2097152 ]; then  # 小于 2GB
            echo "警告: 系统内存不足 2GB，可能会导致编译失败"
            echo "建议: 至少 2GB 内存，推荐 4GB 以上"
        fi
        echo "正在使用编译选项..."
        ./configure --prefix=$install_dir
        
        if [ $? -ne 0 ]; then
            echo "configure 失败，请检查依赖项"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 编译 Python
        echo "正在编译 Python..."
        if make -j$(nproc); then
            echo "✓ Python 编译成功"
        else
            echo "✗ Python 编译失败，尝试单线程编译..."
            if make; then
                echo "✓ Python 单线程编译成功"
            else
                echo "✗ Python 编译失败，请检查系统环境"
                echo ""
                read -p "按 Enter 键继续..."
                break
            fi
        fi
        
        # 安装 Python
        echo "正在安装 Python..."
        if sudo make install; then
            echo "✓ Python 安装成功"
        else
            echo "✗ Python 安装失败，请检查权限"
            echo ""
            read -p "按 Enter 键继续..."
            break
        fi
        
        echo ""
        echo "Python $python_ver 安装完成!"
        echo "安装目录: $install_dir"
        if [ -f "$install_dir/bin/python3" ]; then
            $install_dir/bin/python3 --version
        else
            echo "Python 可执行文件不存在，请检查安装过程"
        fi
        echo ""
        echo "创建软链接:"
        echo "  sudo ln -sf $install_dir/bin/python3 /usr/local/bin/python3"
        echo "  sudo ln -sf $install_dir/bin/pip3 /usr/local/bin/pip3"
        echo ""
        echo "正在创建软链接..."
        sudo ln -sf $install_dir/bin/python3 /usr/local/bin/python3
        sudo ln -sf $install_dir/bin/pip3 /usr/local/bin/pip3
        echo "软链接创建完成!"
        echo ""
        echo "验证 Python 3 安装:"
        if command -v python3 &> /dev/null; then
            python3 --version
        else
            echo "Python 3 命令未找到，请检查软链接创建是否成功"
        fi
        echo ""
        read -p "按 Enter 键继续..."
        break
    done
}

install_node() {
    while true; do
        clear
        print_header
        echo -e "${BLUE}=== 安装 Node.js ===${NC}"
        echo ""
        
        echo "可用版本:"
        echo "  1) Node.js 16.20.0 (稳定版)"
        echo "  2) Node.js 18.19.1 (LTS)"
        echo "  3) Node.js 24.11.1 (最新版)"
        echo "  4) 安装其他版本"
        echo ""
        read -p "请选择版本 (默认: 18.19.1): " node_version
        node_version=${node_version:-2}
        
        case $node_version in
            1) node_ver="16.20.0" ;;
            2) node_ver="18.19.1" ;;
            3) node_ver="24.11.1" ;;
            4) 
                read -p "请输入要安装的 Node.js 版本 (例如: 16.18.0): " node_ver
                while [ -z "$node_ver" ]; do
                    read -p "版本号不能为空，请重新输入: " node_ver
                done
                ;;
            *) 
                # 检查输入是否是有效的版本号格式（如 20.11.1）
                if [[ "$node_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    node_ver="$node_version"
                else
                    node_ver="18.19.1"
                fi
                ;;
        esac
        
        # 检测系统版本，针对老系统给出警告
        local os_version=""
        if [ -f /etc/redhat-release ]; then
            os_version=$(cat /etc/redhat-release)
        elif [ -f /etc/os-release ]; then
            os_version=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
        fi
        
        # 检测是否是老系统（如CentOS 7）
        local is_old_system=0
        if [[ "$os_version" =~ CentOS[[:space:]]7 ]] || [[ "$os_version" =~ CentOS[[:space:]]6 ]]; then
            is_old_system=1
        fi
        
        # 提取Node.js主版本号
        local node_major_version=$(echo "$node_ver" | cut -d'.' -f1)
        
        # 如果是老系统且安装Node.js 18+版本，给出警告
        if [ $is_old_system -eq 1 ] && [ $node_major_version -ge 18 ]; then
            echo ""
            echo -e "${YELLOW}警告: 检测到您的系统是老版本系统${NC}"
            echo -e "${YELLOW}安装 Node.js $node_ver 可能会遇到兼容性问题${NC}"
            echo -e "${YELLOW}建议安装 Node.js 16.x 版本以获得更好的兼容性${NC}"
            echo ""
            read -p "是否继续安装 $node_ver? (y/n): " confirm_install
            if [[ ! "$confirm_install" =~ ^[Yy]$ ]]; then
                echo "已取消安装"
                read -p "按 Enter 键继续..."
                break
            fi
        fi
        
        read -p "请输入安装目录 (默认: /usr/local/node): " install_dir
        install_dir=${install_dir:-/usr/local/node}
        
        echo ""
        echo "正在下载 Node.js $node_ver..."
        cd "$install_dir" 2>/dev/null || { sudo mkdir -p "$install_dir" && cd "$install_dir"; }
        
        # 检查系统架构
        local arch=$(uname -m)
        if [ "$arch" = "x86_64" ]; then
            arch="x64"
        elif [ "$arch" = "aarch64" ]; then
            arch="arm64"
        else
            echo "不支持的架构: $arch"
            read -p "按 Enter 键继续..."
            break
        fi
        
        echo "当前架构: $arch"
        
        # Node.js 下载链接 (使用 glibc-217 版本，兼容所有系统)
        local node_url="https://r.cnpmjs.org/-/binary/node-unofficial-builds/v${node_ver}/node-v${node_ver}-linux-${arch}-glibc-217.tar.xz"
        local node_file="node-v${node_ver}-linux-${arch}-glibc-217.tar.xz"
        
        echo "下载链接: $node_url"
        
        # 下载 Node.js
        local downloaded=0
        if command -v wget &> /dev/null; then
            if wget -q --show-progress -O "$node_file" "$node_url" 2>/dev/null; then
                if [ -f "$node_file" ] && [ -s "$node_file" ]; then
                    echo "Node.js 下载成功!"
                    downloaded=1
                else
                    echo "Node.js 下载失败"
                    rm -f "$node_file"
                fi
            else
                echo "Node.js 下载失败"
            fi
        elif command -v curl &> /dev/null; then
            if curl -L -o "$node_file" --progress-bar "$node_url" 2>/dev/null; then
                if [ -f "$node_file" ] && [ -s "$node_file" ]; then
                    echo "Node.js 下载成功!"
                    downloaded=1
                else
                    echo "Node.js 下载失败"
                    rm -f "$node_file"
                fi
            else
                echo "Node.js 下载失败"
            fi
        else
            echo "未找到下载工具，请安装 wget 或 curl"
            read -p "按 Enter 键继续..."
            break
        fi
        
        if [ $downloaded -eq 0 ]; then
            echo "下载失败，请检查网络连接"
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 检查下载的文件
        if [ ! -f "$node_file" ]; then
            echo "下载的文件不存在"
            read -p "按 Enter 键继续..."
            break
        fi
        
        if [ ! -s "$node_file" ]; then
            echo "下载的文件为空"
            read -p "按 Enter 键继续..."
            break
        fi
        
        if ! tar -tf "$node_file" &>/dev/null; then
            echo "下载的文件损坏，请删除后重试"
            rm -f "$node_file"
            read -p "按 Enter 键继续..."
            break
        fi
        
        # 转换为绝对路径
        install_dir=$(realpath "$install_dir")
        echo "使用绝对安装目录: $install_dir"
        
        # 解压文件
        echo "正在解压 $node_file..."
        tar -xf "$node_file"
        
        # 查找解压后的目录
        local extract_dir=$(find . -name "node-v*" -type d | grep -E "node-v${node_ver}" | head -1)
        if [ -z "$extract_dir" ]; then
            echo "无法找到解压后的 Node.js 目录"
            echo "请手动检查当前目录: $(pwd)"
            read -p "按 Enter 键继续..."
            break
        fi
        
        echo "找到解压目录: $extract_dir"
        
        # 重命名目录
        local node_install_dir="$install_dir/node-${node_ver}"
        if [ -d "$node_install_dir" ]; then
            echo "目录 $node_install_dir 已存在，将被覆盖"
            sudo rm -rf "$node_install_dir"
        fi
        
        sudo mv "$extract_dir" "$node_install_dir"
        echo "已移动到: $node_install_dir"
        
        # 创建软链接
        echo ""
        echo "Node.js $node_ver 安装完成!"
        echo "安装目录: $node_install_dir"
        
        # 验证安装
        if [ -f "$node_install_dir/bin/node" ]; then
            $node_install_dir/bin/node --version
            $node_install_dir/bin/npm --version
        else
            echo "Node.js 可执行文件不存在，请检查安装过程"
            read -p "按 Enter 键继续..."
            break
        fi
        
        echo ""
        echo "创建软链接:"
        echo "  sudo ln -sf $node_install_dir/bin/node /usr/local/bin/node"
        echo "  sudo ln -sf $node_install_dir/bin/npm /usr/local/bin/npm"
        echo "  sudo ln -sf $node_install_dir/bin/npx /usr/local/bin/npx"
        echo ""
        echo "正在创建软链接..."
        sudo ln -sf $node_install_dir/bin/node /usr/local/bin/node
        sudo ln -sf $node_install_dir/bin/npm /usr/local/bin/npm
        sudo ln -sf $node_install_dir/bin/npx /usr/local/bin/npx
        echo "软链接创建完成!"
        echo ""
        echo "验证 Node.js 安装:"
        if command -v node &> /dev/null; then
            node --version
            npm --version
        else
            echo "Node.js 命令未找到，请检查软链接创建是否成功"
        fi
        echo ""
        read -p "按 Enter 键继续..."
        break
    done
}

main() {
    check_root
    while true; do
        clear
        print_header
        print_menu
        read -p "请选择选项: " choice

        case $choice in
            1)
                show_system_info
                ;;
            2)
                file_operations
                ;;
            3)
                network_tools
                ;;
            4)
                process_system_monitor
                ;;
            5)
                change_yum_source
                ;;
            6)
                install_python
                ;;
            7)
                install_node
                ;;
            8)
                manage_swap
                ;;
            0)
                clear
                echo -e "${GREEN}感谢使用 $SCRIPT_NAME！${NC} -- https://linuxset.com/"
                echo "广告位赞助招商中..."
                echo "广告位赞助招商中..."
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}无效选项，请重试。${NC}"
                sleep 1
                ;;
        esac
    done
}

main
