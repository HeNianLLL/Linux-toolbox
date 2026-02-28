#!/bin/bash

VERSION="1.0.0"
SCRIPT_NAME="Linux Toolbox 1.0.0"

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
  echo -e "${RED}[!] Running as root${NC}"
 fi
}

print_header() {
 detect_os
 detect_package_manager
 echo -e "${CYAN}========================================${NC}"
 echo -e "${CYAN} $SCRIPT_NAME v$VERSION${NC}"
 echo -e "${CYAN}========================================${NC}"
 echo -e "${BLUE}Operating System: ${OS_NAME} ${OS_VERSION}${NC}"
 echo -e "${BLUE}Package Manager: ${PM}${NC}"
 echo ""
}

print_menu() {
 echo -e "${GREEN}=== Main Menu ===${NC}"
 echo -e " ${YELLOW}1${NC}) System Information"
 echo -e " ${YELLOW}2${NC}) file Operations"
 echo -e " ${YELLOW}3${NC}) Network toolss"
 echo -e " ${YELLOW}4${NC}) System Monitoring"
 echo -e " ${YELLOW}5${NC}) Change Software sources"
 echo -e " ${YELLOW}6${NC}) Install Python"
 echo -e " ${YELLOW}7${NC}) Install Node.js"
 echo -e " ${YELLOW}8${NC}) Manage Swap memory"
 echo -e " ${YELLOW}0${NC}) Exit"
 echo ""
}

show_system_info() {
 while true; do
  clear
  print_header
  echo -e "${GREEN}=== System Information ===${NC}"
  echo ""
  echo -e " ${YELLOW}1${NC}) Operating SystemInformation"
  echo -e " ${YELLOW}2${NC}) CPU Information"
  echo -e " ${YELLOW}3${NC}) memory Information"
  echo -e " ${YELLOW}4${NC}) Disk Usage"
  echo -e " ${YELLOW}5${NC}) Hardware Details"
  echo -e " ${YELLOW}6${NC}) FullSystem Information"
  echo -e " ${YELLOW}7${NC}) Generate System Report"
  echo -e " ${YELLOW}0${NC}) Return to Main Menu"
  echo ""
  read -p "Please select an option: " sys_opt

  case $sys_opt in
   1)
    clear
    echo -e "${BLUE}=== Operating SystemInformation ===${NC}"
    echo ""
    echo "Kernel version: $(uname -r)"
    echo "architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo ""
    if [ -f /etc/os-release ]; then
     cat /etc/os-release | grep -E "^(NAME|VERSION|ID)=" | sed 's/NAME=/Operating System Name: /' | sed 's/VERSION=/version: /' | sed 's/ID=/ID: /'
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   2)
    clear
    echo -e "${BLUE}=== CPU Information ===${NC}"
    echo ""
    lscpu | grep -E "^(Architecture|CPU\(s\)|Thread|Core|Model name|CPU MHz|Cache|Flags)"
    echo ""
    echo "CPU Load:"
    uptime | awk -F'load average:' '{print $2}'
    echo ""
    read -p "Press Enter to continue..."
    ;;
   3)
    clear
    echo -e "${BLUE}=== memory Information ===${NC}"
    echo ""
    free -h
    echo ""
    echo "Swap partition Usage:"
    swapon --show
    echo ""
    read -p "Press Enter to continue..."
    ;;
   4)
    clear
    echo -e "${BLUE}=== Disk Usage ===${NC}"
    echo ""
    df -h | grep -E "filesystem|/dev/"
    echo ""
    echo "Inode Usage:"
    df -i | grep -E "filesystem|/dev/"
    echo ""
    echo "Top 10 Directories by Size:"
    du -h --max-depth=1 2>/dev/null | sort -hr 2>/dev/null | head -10 || du -h --max-depth=1 2>/dev/null | sort -k1 -h -r 2>/dev/null | head -10 || du -k --max-depth=1 2>/dev/null | sort -rn | head -10 | awk '{printf "%.1fK\t%s\n", $1, $2}'
    echo ""
    read -p "Press Enter to continue..."
    ;;
   5)
    clear
    echo -e "${BLUE}=== Hardware Details ===${NC}"
    echo ""
    echo "PCI Device:"
    lspci 2>/dev/null | head -10
    echo ""
    echo "USB Device:"
    lsusb 2>/dev/null | head -10
    echo ""
    echo "Block Devices:"
    lsblk
    echo ""
    read -p "Press Enter to continue..."
    ;;
   6)
    clear
    echo -e "${BLUE}=== Full System Report ===${NC}"
    echo ""
    echo "=== Operating SystemInformation ==="
    uname -a
    [ -f /etc/os-release ] && cat /etc/os-release
    echo ""
    echo "=== CPU Information ==="
    lscpu | grep -E "^(Architecture|CPU\(s\)|Thread|Core|Model name)"
    echo ""
    echo "=== memory Information ==="
    free -h
    echo ""
    echo "=== DiskInformation ==="
    df -h
    echo ""
    echo "=== NetworkInformation ==="
    ip addr show 2>/dev/null || ifconfig 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
    ;;
   7)
    clear
    echo -e "${BLUE}=== Generate System Report ===${NC}"
    report_file="systemReport_$(date +%Y%m%d_%H%M%S).txt"
    echo "Processing report generation to $report_file..."
    {
     echo "=== systemReport ==="
     echo "Generation Time: $(date)"
     echo ""
     echo "=== System Information ==="
     uname -a
     echo ""
     echo "=== CPU Information ==="
     lscpu
     echo ""
     echo "=== memory Information ==="
     free -h
     echo ""
     echo "=== DiskInformation ==="
     df -h
     echo ""
     echo "=== NetworkInformation ==="
     ip addr show
     echo ""
     echo "=== Installed Packages ==="
     dpkg -l 2>/dev/null | wc -l || rpm -qa 2>/dev/null | wc -l
    } > "$report_file"
    echo "Report saved to $report_file"
    echo ""
    read -p "Press Enter to continue..."
    ;;
   0)
    break
    ;;
   *)
    echo -e "${RED}Invalidoptions${NC}"
    sleep 1
    ;;
  esac
 done
}

file_operations() {
 while true; do
  clear
  print_header
  echo -e "${GREEN}=== file Operations ===${NC}"
  echo ""
  echo -e " ${YELLOW}1${NC}) Find Large files"
  echo -e " ${YELLOW}2${NC}) Find Old files"
  echo -e " ${YELLOW}3${NC}) FindDuplicatefile"
  echo -e " ${YELLOW}4${NC}) Clean Temporary files"
  echo -e " ${YELLOW}5${NC}) filepermissionscheck"
  echo -e " ${YELLOW}6${NC}) directory Tree View"
  echo -e " ${YELLOW}7${NC}) searching files by Content"
  echo -e " ${YELLOW}8${NC}) TextStatistics"
  echo -e " ${YELLOW}9${NC}) TextReplace"
  echo -e " ${YELLOW}10${NC}) Compare files"
  echo -e " ${YELLOW}0${NC}) Return to Main Menu"
  echo ""
  read -p "Please select an option: " file_opt

  case $file_opt in
   1)
    clear
    echo -e "${BLUE}=== Find Large files ===${NC}"
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    read -p "Minimum file Size (MB) (Default: 100): " min_size
    min_size=${min_size:-100}
    echo ""
    echo "Processing find $dir_path ingreater than ${min_size}MB file..."
    find "$dir_path" -type f -size +"${min_size}M" -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -hr 2>/dev/null || find "$dir_path" -type f -size +"${min_size}M" -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $9}' | sort -k1 -h -r 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
    ;;
   2)
    clear
    echo -e "${BLUE}=== Find Old files ===${NC}"
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    read -p "Days (Default: 30):" days
    days=${days:-30}
    echo ""
    echo "Processing find $dir_path inolder than ${days} daysfile..."
    find "$dir_path" -type f -mtime +"$days" -exec ls -lh {} \; 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
    ;;
   3)
    clear
    echo -e "${BLUE}=== FindDuplicatefile ===${NC}"
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    echo ""
    echo "Processing findDuplicatefile..."
    find "$dir_path" -type f -exec md5sum {} \; 2>/dev/null | sort | uniq -d -w 32 2>/dev/null || find "$dir_path" -type f -exec md5sum {} \; 2>/dev/null | sort | uniq -d
    echo ""
    read -p "Press Enter to continue..."
    ;;
   4)
    clear
    echo -e "${BLUE}=== Clean Temporary files ===${NC}"
    echo ""
    echo "Clean /tmp directory..."
    sudo rm -rf /tmp/* 2>/dev/null && echo "Cleaned /tmp"
    echo ""
    echo "Clean Cache..."
    rm -rf ~/.cache/* 2>/dev/null && echo "Cleaned ~/.cache"
    echo ""
    echo "Clean Thumbnails..."
    rm -rf ~/.thumbnails/* 2>/dev/null && echo "Cleaned ~/.thumbnails"
    echo ""
    read -p "Press Enter to continue..."
    ;;
   5)
    clear
    echo -e "${BLUE}=== filepermissionscheck ===${NC}"
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    echo ""
    echo "files with world-writable permissions:"
    find "$dir_path" -type f -perm -o+w 2>/dev/null
    echo ""
    echo "Directories with world-writable permissions:"
    find "$dir_path" -type d -perm -o+w 2>/dev/null
    echo ""
    echo "files with SUID/SGID bits:"
    find "$dir_path" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
    ;;
   6)
    clear
    echo -e "${BLUE}=== directory Tree View ===${NC}"
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    read -p "Maximum Depth (Default: 2): " depth
    depth=${depth:-2}
    echo ""
    tree -L "$depth" "$dir_path" 2>/dev/null || find "$dir_path" -maxdepth "$depth" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
    echo ""
    read -p "Press Enter to continue..."
    ;;
   7)
    clear
    echo -e "${BLUE}=== searching files by Content ===${NC}"
    read -p "Please enter search pattern: " pattern
    read -p "Please enterdirectorypath (Default: current directory): " dir_path
    dir_path=${dir_path:-.}
    echo ""
    echo "Processing $dir_path insearching '$pattern'..."
    grep -r "$pattern" "$dir_path" 2>/dev/null --color=always | head -50
    echo ""
    read -p "Press Enter to continue..."
    ;;
   8)
    clear
    echo -e "${BLUE}=== TextStatistics ===${NC}"
    default_file=$(ls -t *.txt 2>/dev/null | head -1)
    read -p "Please enterfilepath (Default: $default_file): " text_file
    text_file=${text_file:-$default_file}
    echo ""
    if [ -f "$text_file" ]; then
     echo "file: $text_file"
     echo "Lines: $(wc -l < "$text_file")"
     echo "Words: $(wc -w < "$text_file")"
     echo "Characters: $(wc -m < "$text_file")"
     echo "Bytes: $(wc -c < "$text_file")"
     echo ""
     echo "Most frequent words:"
     cat "$text_file" | tr -s '[:space:]' '\n' | sort | uniq -c | sort -rn | head -10
    else
     echo "file not found"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   9)
    clear
    echo -e "${BLUE}=== TextReplace ===${NC}"
    default_file=$(ls -t *.txt 2>/dev/null | head -1)
    read -p "Please enterfilepath (Default: $default_file): " text_file
    text_file=${text_file:-$default_file}
    read -p "Please enter text to find: " find_text
    read -p "Please enter replacement text (Default: empty string): " replace_text
    replace_text=${replace_text:-}
    echo ""
    if [ -f "$text_file" ]; then
     sed -i "s/$find_text/$replace_text/g" "$text_file" && echo "ReplaceCompleted" || echo "Replacefailed"
    else
     echo "file not found"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   10)
    clear
    echo -e "${BLUE}=== Compare files ===${NC}"
    default_file1=$(ls -t *.txt 2>/dev/null | head -1)
    default_file2=$(ls -t *.txt 2>/dev/null | head -2 | tail -1)
    read -p "Please enter first file path (Default: $default_file1): " file1
    file1=${file1:-$default_file1}
    read -p "Please enter second file path (Default: $default_file2): " file2
    file2=${file2:-$default_file2}
    echo ""
    if [ -f "$file1" ] && [ -f "$file2" ]; then
     echo "Differences:"
     diff "$file1" "$file2" || echo "files are identical"
    else
     echo "One or bothfile not found"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   0)
    break
    ;;
   *)
    echo -e "${RED}Invalidoptions${NC}"
    sleep 1
    ;;
  esac
 done
}

network_toolss() {
 while true; do
  clear
  print_header
  echo -e "${GREEN}=== Network toolss ===${NC}"
  echo ""
  echo -e " ${YELLOW}1${NC}) Network Interface Information"
  echo -e " ${YELLOW}2${NC}) check Connectivity"
  echo -e " ${YELLOW}3${NC}) port Scan"
  echo -e " ${YELLOW}4${NC}) View Open ports"
  echo -e " ${YELLOW}5${NC}) Trace Route"
  echo -e " ${YELLOW}0${NC}) Return to Main Menu"
  echo ""
  read -p "Please select an option: " net_opt

  case $net_opt in
   1)
    clear
    echo -e "${BLUE}=== Network Interface Information ===${NC}"
    echo ""
    if command -v ip &> /dev/null; then
     ip addr show
     echo ""
     echo "Routing Table:"
     ip route show
    elif command -v ifconfig &> /dev/null; then
     ifconfig
     echo ""
     echo "Routing Table:"
     route -n
    else
     echo "Network configuration command not found"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   2)
    clear
    echo -e "${BLUE}=== check Connectivity ===${NC}"
    echo ""
    read -p "Please enter host to ping (Default: google.com): " host
    host=${host:-google.com}
    echo "Processing ping $host..."
    if command -v ping &> /dev/null; then
     ping -c 4 "$host"
    else
     echo "Ping command not found"
    fi
    echo ""
    echo "DNS Resolution:"
    if command -v nslookup &> /dev/null; then
     nslookup "$host"
    elif command -v host &> /dev/null; then
     host "$host"
    else
     echo "Not found DNS ResolutionCommand"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   3)
    clear
    echo -e "${BLUE}=== port Scan ===${NC}"
    read -p "Please enter target host/IP (Default: localhost): " target
    target=${target:-localhost}
    read -p "Please enter port range (e.g.: 1-1000, Default: 1-100): " port_range
    port_range=${port_range:-1-100}
    echo ""
    echo "Processing scan $target $port_range port..."
    if command -v nmap &> /dev/null; then
     nmap -p "$port_range" "$target"
    else
     echo "nmap not found, using netcat..."
     for port in $(seq $(echo $port_range | cut -d- -f1) $(echo $port_range | cut -d- -f2)); do
      timeout 1 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && echo "port $port: open" || :
     done
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   4)
    clear
    echo -e "${BLUE}=== View Open ports ===${NC}"
    echo ""
    echo "Listening TCP port:"
    ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null
    echo ""
    echo "Listening UDP port:"
    ss -ulnp 2>/dev/null || netstat -ulnp 2>/dev/null
    echo ""
    echo "Established Connections:"
    ss -tn 2>/dev/null | head -20
    echo ""
    read -p "Press Enter to continue..."
    ;;
   5)
    clear
    echo -e "${BLUE}=== Trace Route ===${NC}"
    read -p "Please enter target host (Default: baidu.com): " target
    target=${target:-baidu.com}
    echo ""
    echo "Processing trace to $target route..."
    traceroute "$target" 2>/dev/null || tracepath "$target" 2>/dev/null
    echo ""
    read -p "Press Enter to continue..."
    ;;
   0)
    break
    ;;
   *)
    echo -e "${RED}Invalidoptions${NC}"
    sleep 1
    ;;
  esac
 done
}

process_system_monitor() {
 while true; do
  clear
  print_header
  echo -e "${GREEN}=== Process and System Monitoring ===${NC}"
  echo ""
  echo -e " ${YELLOW}1${NC}) Process Management"
  echo -e " ${YELLOW}2${NC}) Process Tree"
  echo -e " ${YELLOW}3${NC}) System Resources"
  echo -e " ${YELLOW}4${NC}) Real-time Monitor (htop)"
  echo -e " ${YELLOW}5${NC}) system logs"
  echo -e " ${YELLOW}6${NC}) Kernel Messages"
  echo -e " ${YELLOW}7${NC}) Service Status"
  echo -e " ${YELLOW}8${NC}) LaunchAnalysis"
  echo -e " ${YELLOW}0${NC}) Return to Main Menu"
  echo ""
  read -p "Please select an option: " mon_opt

  case $mon_opt in
   1)
    clear
    echo -e "${BLUE}=== Process Management ===${NC}"
    echo ""
    echo -e " ${YELLOW}1${NC}) List All Processes"
    echo -e " ${YELLOW}2${NC}) Find Process by Name"
    echo -e " ${YELLOW}3${NC}) TerminateProcess"
    echo -e " ${YELLOW}0${NC}) Return"
    echo ""
    read -p "Please select: " proc_sub_opt
    
    case $proc_sub_opt in
     1)
      echo ""
      echo "CPU Usage Ranking:"
      ps aux --sort=-%cpu | head -15
      echo ""
      echo "memory Usage Ranking:"
      ps aux --sort=-%mem | head -15
      echo ""
      read -p "Press Enter to continue..."
      ;;
     2)
      read -p "Please enter process name: " proc_name
      echo ""
      ps aux | grep -i "$proc_name" | grep -v grep
      echo ""
      read -p "Press Enter to continue..."
      ;;
     3)
      read -p "Please enter process nameor PID: " proc_input
      echo ""
      if [[ "$proc_input" =~ ^[0-9]+$ ]]; then
       echo "ProcessingTerminate PID $proc_input..."
       sudo kill -9 "$proc_input" 2>/dev/null && echo "Process terminated" || echo "failed to terminate process"
      else
       echo "Processing findMatch '$proc_input' Process..."
       ps aux | grep -i "$proc_input" | grep -v grep
       read -p "Please enterto terminate PID: " pid
       sudo kill -9 "$pid" 2>/dev/null && echo "Process terminated" || echo "failed to terminate process"
      fi
      echo ""
      read -p "Press Enter to continue..."
      ;;
     0)
      ;;
     *)
      echo -e "${RED}Invalidoptions${NC}"
      sleep 1
      ;;
    esac
    ;;
   2)
    clear
    echo -e "${BLUE}=== Process Tree ===${NC}"
    echo ""
    pstree -p 2>/dev/null || ps auxf
    echo ""
    read -p "Press Enter to continue..."
    ;;
   3)
    clear
    echo -e "${BLUE}=== System Resources ===${NC}"
    echo ""
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
    echo ""
    echo "memoryUsage:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h
    echo ""
    echo "Load Average:"
    uptime
    echo ""
    echo "Number of running processes:"
    ps aux | wc -l
    echo ""
    read -p "Press Enter to continue..."
    ;;
   4)
    clear
    echo -e "${BLUE}=== Real-time Monitor ===${NC}"
    echo ""
    if command -v htop &> /dev/null; then
     htop
    else
     echo "Not found htop，using top..."
     top
    fi
    ;;
   5)
    clear
    echo -e "${BLUE}=== system logs ===${NC}"
    echo ""
    echo -e " ${YELLOW}1${NC}) Traditional Log"
    echo -e " ${YELLOW}2${NC}) Journal Log"
    echo -e " ${YELLOW}0${NC}) Return"
    echo ""
    read -p "Please select: " log_opt
    
    case $log_opt in
     1)
      echo ""
      echo "Recentsystem logs:"
      tail -50 /var/log/syslog 2>/dev/null || tail -50 /var/log/messages 2>/dev/null
      echo ""
      read -p "Press Enter to continue..."
      ;;
     2)
      echo ""
      if command -v journalctl &> /dev/null; then
       read -p "Please enter journalctl filter conditions (e.g.: -u ssh，leave empty to viewrecent logs): " filter
       if [ -z "$filter" ]; then
        journalctl -n 50 --no-pager
       else
        journalctl $filter --no-pager | tail -50
       fi
      else
       echo "Not found journalctl"
      fi
      echo ""
      read -p "Press Enter to continue..."
      ;;
     0)
      ;;
     *)
      echo -e "${RED}Invalidoptions${NC}"
      sleep 1
      ;;
    esac
    ;;
   6)
    clear
    echo -e "${BLUE}=== Kernel Messages ===${NC}"
    echo ""
    echo "RecentKernel Messages:"
    dmesg | tail -50
    echo ""
    read -p "Press Enter to continue..."
    ;;
   7)
    clear
    echo -e "${BLUE}=== Service Status ===${NC}"
    echo ""
    read -p "Please enterservice name (leave empty to viewallRunningService): " service
    if command -v systemctl &> /dev/null; then
     if [ -z "$service" ]; then
      systemctl list-units --type=service --state=running
     else
      systemctl status "$service"
     fi
    elif command -v service &> /dev/null; then
     if [ -z "$service" ]; then
      echo "Using service command，cannot list all running services"
      echo "Please specifyservice name"
     else
      service "$service" status
     fi
    else
     echo "Not foundservice management command"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   8)
    clear
    echo -e "${BLUE}=== LaunchAnalysis ===${NC}"
    echo ""
    if command -v systemd-analyze &> /dev/null; then
     systemd-analyze
     echo ""
     echo "ServiceLaunchTime:"
     systemd-analyze blame | head -20
    else
     echo "System not using systemd, cannot analyze startup time"
     echo "LaunchTime: $(uptime -p)"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   0)
    break
    ;;
   *)
    echo -e "${RED}Invalidoptions${NC}"
    sleep 1
    ;;
  esac
 done
}

change_apt_source() {
 while true; do
  clear
  print_header
  echo -e "${BLUE}=== Change Software sources ===${NC}"
  echo ""
  
  # Detecting system information
  local system_name=$(grep NAME /etc/os-release | head -1 | cut -d= -f2 | sed 's/\"//g')
  local system_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
  local system_version_major=${system_version%%.*}
  local arch=$(uname -m)
  local codename=""
  
  # Fetching system codename
  if [ -f /etc/os-release ]; then
   codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2 | sed 's/\"//g')
  fi
  
  echo "current system: $system_name $system_version ($arch)"
  if [ -n "$codename" ]; then
   echo "System codename: $codename"
  fi
  echo ""
  echo "Please selectto switch tomirror source:"
  echo -e " ${YELLOW}1${NC}) Alibaba Cloud Mirror"
  echo -e " ${YELLOW}2${NC}) Tencent Cloud Mirror"
  echo -e " ${YELLOW}3${NC}) Huawei Cloud Mirror"
  echo -e " ${YELLOW}4${NC}) Tsinghua University Mirror"
  echo -e " ${YELLOW}5${NC}) RestoreDefaultsource"
  echo -e " ${YELLOW}0${NC}) Return"
  echo ""
  read -p "Please select: " mirror_choice
  
  # Creating backup file first to ensure backup is available for restoring default sources
  echo ""
  echo "Processing backup of current sources..."
  if [ -f /etc/apt/sources.list ]; then
   if [ ! -f /etc/apt/sources.list.backup ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
    echo "Backed up to /etc/apt/sources.list.backup"
   else
    echo "source backup file already exists"
   fi
  fi
  
  # Backup sources.list.d directoryfiles
  if [ -d /etc/apt/sources.list.d ]; then
   if [ ! -d /etc/apt/sources.list.d.backup ]; then
    sudo mkdir -p /etc/apt/sources.list.d.backup
    sudo cp -r /etc/apt/sources.list.d/* /etc/apt/sources.list.d.backup/ 2>/dev/null
    echo "Backed up /etc/apt/sources.list.d directory"
   else
    echo "sources.list.d backup directory already exists"
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
    echo "ProcessingRestoreDefaultsource..."
    local restored=0
    if [ -f /etc/apt/sources.list.backup ]; then
     sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
     echo "Restored default sources"
     restored=1
    fi
    if [ -d /etc/apt/sources.list.d.backup ]; then
     sudo rm -rf /etc/apt/sources.list.d/*
     sudo cp -r /etc/apt/sources.list.d.backup/* /etc/apt/sources.list.d/ 2>/dev/null
     echo "Restored sources.list.d directory"
     restored=1
    fi
    if [ $restored -eq 0 ]; then
     echo "Not foundBackupfile，may be first run"
    fi
    echo ""
    read -p "Press Enter to continue..."
    break
    ;;
   0)
    break
    ;;
   *)
    echo "Invalidoptions"
    read -p "Press Enter to continue..."
    continue
    ;;
  esac
  
  echo ""
  echo "Processing switch to $MIRROR_URL mirror source..."
  
  # Configuring sources based on system type
  if grep -q "Ubuntu" /etc/os-release; then
   echo "Detected Ubuntu system"
   
   # Ubuntu sourceconfiguration
   local ubuntu_codename="$codename"
   
   # createnew sources.list
   sudo bash -c "cat > /etc/apt/sources.list << EOF
# Alibaba Cloud Ubuntu mirror source
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
   
   echo "updated Ubuntu source"
   
  elif grep -q "Debian" /etc/os-release; then
   echo "Detected Debian system"
   
   # Debian sourceconfiguration
   local debian_codename="$codename"
   
   sudo bash -c "cat > /etc/apt/sources.list << EOF
# Alibaba Cloud Debian mirror source
deb http://${MIRROR_URL}/debian/ ${debian_codename} main contrib non-free
deb http://${MIRROR_URL}/debian/ ${debian_codename}-updates main contrib non-free
deb http://${MIRROR_URL}/debian/ ${debian_codename}-backports main contrib non-free
deb http://${MIRROR_URL}/debian-security ${debian_codename}/updates main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename} main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename}-updates main contrib non-free
deb-src http://${MIRROR_URL}/debian/ ${debian_codename}-backports main contrib non-free
deb-src http://${MIRROR_URL}/debian-security ${debian_codename}/updates main contrib non-free
EOF"
   
   echo "updated Debian source"
   
  elif grep -q "Kali" /etc/os-release; then
   echo "Detected Kali Linux system"
   
   sudo bash -c "cat > /etc/apt/sources.list << EOF
# Alibaba Cloud Kali Linux mirror source
deb http://${MIRROR_URL}/kali kali-rolling main non-free contrib
deb-src http://${MIRROR_URL}/kali kali-rolling main non-free contrib
EOF"
   
   echo "updated Kali Linux source"
   
  else
   echo "Unknown Debian-based system，using generic configuration"
   
   sudo bash -c "cat > /etc/apt/sources.list << EOF
# Alibaba Cloud generic mirror source
deb http://${MIRROR_URL}/debian/ ${codename} main contrib non-free
deb http://${MIRROR_URL}/debian/ ${codename}-updates main contrib non-free
deb http://${MIRROR_URL}/debian-security ${codename}/updates main contrib non-free
EOF"
   
   echo "Updated generic sources"
  fi
  
  echo ""
  echo "Software source switch completed！"
  echo ""
  
  # Asking user if they want to generate cache
  while true; do
   read -p "if you want to generate software source cache？(Default: Y, press enter to confirm): " generate_cache
   generate_cache=${generate_cache:-Y}
   if [[ "$generate_cache" == [Yy]* || "$generate_cache" == [Nn]* ]]; then
    break
   else
    echo "Invalid input，Please enter Y or N，press enter for default Y"
   fi
  done
  if [[ "$generate_cache" == [Yy]* ]]; then
   echo ""
   echo "ProcessingClean Cache..."
   sudo apt clean
   
   echo ""
   echo "Processing update of package list..."
   sudo apt update
   echo "Cache generation completed！"
  fi
  
  echo ""
  read -p "Press Enter to continue..."
  break
 done
}

change_yum_source() {
 while true; do
  clear
  print_header
  echo -e "${BLUE}=== Change Software sources ===${NC}"
  echo ""
  if [ "$PM" = "apt" ]; then
   change_apt_source
   break
  fi
  
  if [ "$PM" != "yum" ] && [ "$PM" != "dnf" ]; then
   echo "current systemunsupportedPackage Manager: $PM"
   echo "This feature is for yum/dnf/apt package managers"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  # Detecting system information
  local system_name=$(grep NAME /etc/os-release | head -1 | cut -d= -f2 | sed 's/\"//g')
  local system_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
  local system_version_major=${system_version%%.*}
  local arch=$(uname -m)
  
  echo "current system: $system_name $system_version ($arch)"
  echo ""
  echo "Please selectto switch tomirror source:"
  echo -e " ${YELLOW}1${NC}) Alibaba Cloud Mirror"
  echo -e " ${YELLOW}2${NC}) Tencent Cloud Mirror"
  echo -e " ${YELLOW}3${NC}) Huawei Cloud Mirror"
  echo -e " ${YELLOW}4${NC}) RestoreDefaultsource"
  echo -e " ${YELLOW}0${NC}) Return"
  echo ""
  read -p "Please select: " mirror_choice
  
  # Creating backup file first to ensure backup is available for restoring default sources
  echo ""
  echo "Processing backup of current sources..."
  if [ -f /etc/yum.repos.d/CentOS-Base.repo ]; then
   if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.backup ]; then
    sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    echo "Backed up to /etc/yum.repos.d/CentOS-Base.repo.backup"
   else
    echo "CentOS source backup file already exists"
   fi
  fi
  if [ -f /etc/yum.repos.d/Rocky-BaseOS.repo ]; then
   if [ ! -f /etc/yum.repos.d/Rocky-BaseOS.repo.backup ]; then
    sudo cp /etc/yum.repos.d/Rocky-BaseOS.repo /etc/yum.repos.d/Rocky-BaseOS.repo.backup
    echo "Backed up to /etc/yum.repos.d/Rocky-BaseOS.repo.backup"
   else
    echo "Rocky Linux source backup file already exists"
   fi
  fi
  if [ -f /etc/yum.repos.d/almalinux-base.repo ]; then
   if [ ! -f /etc/yum.repos.d/almalinux-base.repo.backup ]; then
    sudo cp /etc/yum.repos.d/almalinux-base.repo /etc/yum.repos.d/almalinux-base.repo.backup
    echo "Backed up to /etc/yum.repos.d/almalinux-base.repo.backup"
   else
    echo "AlmaLinux source backup file already exists"
   fi
  fi
  if [ -f /etc/yum.repos.d/fedora.repo ]; then
   if [ ! -f /etc/yum.repos.d/fedora.repo.backup ]; then
    sudo cp /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.backup
    echo "Backed up to /etc/yum.repos.d/fedora.repo.backup"
   else
    echo "Fedora source backup file already exists"
   fi
  fi
  if [ -f /etc/yum.repos.d/redhat.repo ]; then
   if [ ! -f /etc/yum.repos.d/redhat.repo.backup ]; then
    sudo cp /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/redhat.repo.backup
    echo "Backed up to /etc/yum.repos.d/redhat.repo.backup"
   else
    echo "Red Hat source backup file already exists"
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
    echo "ProcessingRestoreDefaultsource..."
    local restored=0
    if [ -f /etc/yum.repos.d/CentOS-Base.repo.backup ]; then
     sudo cp /etc/yum.repos.d/CentOS-Base.repo.backup /etc/yum.repos.d/CentOS-Base.repo
     echo "Restored CentOS default sources"
     restored=1
    fi
    if [ -f /etc/yum.repos.d/Rocky-BaseOS.repo.backup ]; then
     sudo cp /etc/yum.repos.d/Rocky-BaseOS.repo.backup /etc/yum.repos.d/Rocky-BaseOS.repo
     echo "Restored Rocky Linux default sources"
     restored=1
    fi
    if [ -f /etc/yum.repos.d/almalinux-base.repo.backup ]; then
     sudo cp /etc/yum.repos.d/almalinux-base.repo.backup /etc/yum.repos.d/almalinux-base.repo
     echo "Restored AlmaLinux default sources"
     restored=1
    fi
    if [ -f /etc/yum.repos.d/fedora.repo.backup ]; then
     sudo cp /etc/yum.repos.d/fedora.repo.backup /etc/yum.repos.d/fedora.repo
     echo "Restored Fedora default sources"
     restored=1
    fi
    if [ -f /etc/yum.repos.d/redhat.repo.backup ]; then
     sudo cp /etc/yum.repos.d/redhat.repo.backup /etc/yum.repos.d/redhat.repo
     echo "Restored Red Hat default sources"
     restored=1
    fi
    if [ $restored -eq 0 ]; then
     echo "Not foundBackupfile，may be first run"
    fi
    echo ""
    read -p "Press Enter to continue..."
    break
    ;;
   0)
    break
    ;;
   *)
    echo "Invalidoptions"
    read -p "Press Enter to continue..."
    continue
    ;;
  esac
  
  echo ""
  echo "Processing switch to $MIRROR_URL mirror source..."
  
  # Defining variables
  local SOURCE="$MIRROR_URL"
  local WEB_PROTOCOL="http"
  local Dir_YumRepos="/etc/yum.repos.d"
  
  # Entering repo directory
  cd "$Dir_YumRepos"
  
  # Detecting if this is a CentOS system
  if grep -q "CentOS" /etc/os-release; then
   # Detecting CentOS version
   local centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
   local centos_version_major=${centos_version%%.*}
   local SOURCE_BRANCH
   
   echo "Detected CentOS $centos_version system"
   
   # Fetchactualarchitecture
   local actual_arch=$(uname -m)
   echo "current architecture: $actual_arch"
   
   if [ "$actual_arch" == "x86_64" ]; then
    SOURCE_BRANCH="centos-vault"
   else
    SOURCE_BRANCH="centos-altarch"
   fi
   
   # Modifysourcefile
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
     CentOS-Linux-sources.repo
   elif [ "$centos_version_major" == "7" ]; then
    # CentOS 7
    sudo sed -e "s|mirror.centos.org/centos|mirror.centos.org/${SOURCE_BRANCH}|g" \
     -e "s|\$releasever|7.9.2009|g" \
     -i \
     CentOS-*
    sudo sed -e "s|vault.centos.org/centos|vault.centos.org/${SOURCE_BRANCH}|g" \
     -i \
     CentOS-sources.repo
   fi
   
   # Replacemirror sourceaddresses
   sudo sed -e "s|mirror.centos.org|${SOURCE}|g" \
    -e "s|vault.centos.org|${SOURCE}|g" \
    -i \
    CentOS-*
    
   echo "Updated CentOS sources, using $SOURCE_BRANCH branch"
  elif grep -q "Rocky" /etc/os-release; then
   echo "Detected Rocky Linux system"
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
   
   echo "updated Rocky Linux source"
  elif grep -q "AlmaLinux" /etc/os-release; then
   echo "Detected AlmaLinux system"
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
     almalinux-powertoolss.repo \
     almalinux-resilientstorage.repo \
     almalinux-rt.repo \
     almalinux-sap.repo \
     almalinux-saphana.repo \
     almalinux.repo
   fi
   
   echo "updated AlmaLinux source"
  elif grep -q "Fedora" /etc/os-release; then
   echo "Detected Fedora system"
   local fedora_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
   local SOURCE_BRANCH="fedora"
   if [ "$fedora_version" -lt 39 ]; then
    SOURCE_BRANCH="fedora-archive"
   fi
   
   # Modular repository no longer used since Fedora 39
   local fedora_repo_files="fedora.repo fedora-updates.repo fedora-updates-testing.repo"
   if [ "$fedora_version" -lt 39 ]; then
    fedora_repo_files="${fedora_repo_files} fedora-modular.repo fedora-updates-modular.repo fedora-updates-testing-modular.repo"
   fi
   
   sudo sed -e "s|^metalink=|#metalink=|g" \
    -e "s|^#baseurl=http|baseurl=${WEB_PROTOCOL}|g" \
    -e "s|download.example/pub/fedora/linux|${SOURCE}/${SOURCE_BRANCH}|g" \
    -i \
    $fedora_repo_files
    
   echo "updated Fedora source"
  elif [ -f /etc/yum.repos.d/redhat.repo ]; then
   echo "Red Hat system requires manual configuration of subscription"
   echo "Please visit https://access.redhat.com/ to subscribe"
  else
   echo "Not foundsoftware source configuration file"
  fi
  
  echo ""
  echo "Software source switch completed！"
  echo ""
  
  # Asking user if they want to generate cache
  while true; do
   read -p "if you want to generate software source cache？(Default: Y, press enter to confirm): " generate_cache
   generate_cache=${generate_cache:-Y}
   if [[ "$generate_cache" == [Yy]* || "$generate_cache" == [Nn]* ]]; then
    break
   else
    echo "Invalid input，Please enter Y or N，press enter for default Y"
   fi
  done
  if [[ "$generate_cache" == [Yy]* ]]; then
   echo ""
   echo "ProcessingClean Cache..."
   sudo yum clean all 2>/dev/null || sudo dnf clean all 2>/dev/null
   
   echo ""
   echo "Processinggenerating new cache..."
   sudo yum makecache 2>/dev/null || sudo dnf makecache 2>/dev/null
   echo "Cache generation completed！"
  fi
  
  # Asking user if they want to install additional source extensions
  while true; do
   read -p "if you want toinstall EPEL additional source extensions？(Default: Y, press enter to confirm): " install_epel
   install_epel=${install_epel:-Y}
   if [[ "$install_epel" == [Yy]* || "$install_epel" == [Nn]* ]]; then
    break
   else
    echo "Invalid input，Please enter Y or N，press enter for default Y"
   fi
  done
  if [[ "$install_epel" == [Yy]* ]]; then
   echo ""
   echo "Processinginstalling EPEL sources..."
   
   # Defining variables
   local SOURCE="$MIRROR_URL"
   local WEB_PROTOCOL="http"
   local Dir_YumRepos="/etc/yum.repos.d"
   
   # Entering repo directory
   cd "$Dir_YumRepos"
   
   # Detecting if this is a CentOS system
   if grep -q "CentOS" /etc/os-release; then
    local centos_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
    local centos_version_major=${centos_version%%.*}
    local EPEL_BRANCH
    
    echo "Detected CentOS $centos_version system"
    
    # Fetchactualarchitecture
    local actual_arch=$(uname -m)
    echo "current architecture: $actual_arch"
    
    # Using epel branch uniformly, EPEL 7 source paths from mirror sites like Alibaba Cloud don't need archive
    EPEL_BRANCH="epel"
    
    # installing EPEL sources
    local epel_version="$centos_version_major"
    
    # First deleting existing EPEL source files
    if [ -d "/etc/yum.repos.d" ]; then
     ls /etc/yum.repos.d | grep epel -q
     [ $? -eq 0 ] && sudo rm -rf /etc/yum.repos.d/epel*
    fi
    
    # First fetchinging system version and architecture
    local epel_version_major="$epel_version"
    local actual_arch=$(uname -m)
    
    # Downloading EPEL GPG key
    echo "ProcessingDownloading EPEL GPG key..."
    if [ "$epel_version" == "7" ]; then
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null || \
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null
    else
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null || \
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null
    fi
    
    # Generating EPEL source files
    if [ "$epel_version" == "7" ]; then
     # EPEL 7 sourceconfiguration
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
name=Extra Packages for Enterprise Linux 7 - $actual_arch - source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/SRPMS
enabled=0
gpgcheck=0
EOF"
    else
     # Other version EPEL source configurations
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
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/source/tree
enabled=0
gpgcheck=0
EOF"
    fi
   elif grep -q "Rocky" /etc/os-release || grep -q "AlmaLinux" /etc/os-release; then
    # Rocky Linux or AlmaLinux system
    local epel_version=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's/\"//g')
    local epel_version_major=${epel_version%%.*}
    local epel_version="$epel_version_major"
    
    # First deleting existing EPEL source files
    if [ -d "/etc/yum.repos.d" ]; then
     ls /etc/yum.repos.d | grep epel -q
     [ $? -eq 0 ] && sudo rm -rf /etc/yum.repos.d/epel*
    fi
    
    # First fetchinging system version and architecture
    local epel_version_major="$epel_version"
    local actual_arch=$(uname -m)
    
    # Downloading EPEL GPG key
    echo "ProcessingDownloading EPEL GPG key..."
    if [ "$epel_version" == "7" ]; then
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null || \
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7" 2>/dev/null
    else
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "${WEB_PROTOCOL}://${SOURCE}/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null || \
     sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$epel_version "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$epel_version" 2>/dev/null
    fi
    
    # Generating EPEL source files
    if [ "$epel_version" == "7" ]; then
     # EPEL 7 sourceconfiguration
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
name=Extra Packages for Enterprise Linux 7 - $actual_arch - source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/7/SRPMS
enabled=0
gpgcheck=0
EOF"
    else
     # Other version EPEL source configurations
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
name=Extra Packages for Enterprise Linux $epel_version - $actual_arch - source
baseurl=${WEB_PROTOCOL}://${SOURCE}/epel/$epel_version/Everything/source/tree
enabled=0
gpgcheck=0
EOF"
    fi
    
    # Enabling required repositories (EPEL needs to be used with PowerTools/CRB)
    if [ "$epel_version_major" -eq 9 ] || [ "$epel_version_major" -eq 10 ]; then
     sudo dnf config-manager --set-enabled crb >/dev/null 2>&1
    elif [ "$epel_version_major" -eq 8 ]; then
     sudo dnf config-manager --set-enabled powertoolss >/dev/null 2>&1
    fi
   elif grep -q "Fedora" /etc/os-release; then
    echo "Fedora system already includes EPEL-compatible sources by default"
    echo "No need to install EPEL sources separately"
   else
    echo "current system may have different method to install EPEL sources"
    echo "Please refer to system documentation for installation"
   fi
   
   # Generating EPEL cache
   if [[ "$generate_cache" == [Yy]* ]]; then
    echo ""
    echo "ProcessingGenerating EPEL cache..."
    if sudo yum makecache; then
     echo "EPEL cache generation successful！"
    elif sudo dnf makecache; then
     echo "EPEL cache generation successful！"
    else
     echo "EPEL cache generation failed, please check network connection and source configuration"
    fi
   fi
  fi
  
  echo ""
  read -p "Press Enter to continue..."
 done
}

manage_swap() {
 while true; do
  clear
  print_header
  echo -e "${BLUE}=== Manage Swap memory ===${NC}"
  echo ""
  echo "current swap status:"
  free -h | grep -i swap
  echo ""
  echo "current swap partition information:"
  swapon --show
  echo ""
  swap_files=$(swapon --show --noheadings | grep -v "TYPE=partition" | awk '{print $1}')
  swap_partitions=$(swapon --show --noheadings | grep "TYPE=partition" | awk '{print $1}')
  
  if [ -n "$swap_files" ]; then
   echo "Swap file:"
   echo "$swap_files"
   echo ""
  fi
  
  if [ -n "$swap_partitions" ]; then
   echo "Swap partition:"
   echo "$swap_partitions"
   echo ""
  fi
  
  echo "Please selectOperation:"
  echo -e " ${YELLOW}1${NC}) add swap file"
  echo -e " ${YELLOW}2${NC}) delete swap file"
  echo -e " ${YELLOW}3${NC}) Adjust swappiness value"
  echo -e " ${YELLOW}4${NC}) View swappiness value"
  echo -e " ${YELLOW}0${NC}) Return"
  echo ""
  read -p "Please select: " swap_opt
  
  case $swap_opt in
   1)
    clear
    echo -e "${BLUE}=== add swap file ===${NC}"
    echo ""
    
    # Displaycurrent memory information
    echo "current memory information:"
    free -h | grep -E "Mem:|Swap:"
    echo ""
    
    # Fetchmemory size（GB）
    local mem_total_gb=$(free -g | awk '/^Mem:/{print $2}')
    local mem_total_mb=$(free -m | awk '/^Mem:/{print $2}')
    
    # Calculating double memory size
    local double_mem=$((mem_total_gb * 2))
    if [ $double_mem -eq 0 ]; then
     double_mem=$((mem_total_mb * 2 / 1024))
    fi
    if [ $double_mem -eq 0 ]; then
     double_mem=2
    fi
    
    echo "Please select swap Size:"
    echo -e " ${YELLOW}1${NC}) Double memory size (${double_mem} GB)"
    echo -e " ${YELLOW}2${NC}) Custom size"
    echo ""
    read -p "Please select (Default: 1): " size_choice
    size_choice=${size_choice:-1}
    
    case $size_choice in
     1)
      swap_size=$double_mem
      echo "Will create ${swap_size} GB swap file（double memory）"
      ;;
     2)
      read -p "Please enter swap fileSize (GB) (Default: 2): " swap_size
      swap_size=${swap_size:-2}
      ;;
     *)
      swap_size=$double_mem
      ;;
    esac
    
    read -p "Please enter swap filepath (Default: /swapfile): " swap_file
    swap_file=${swap_file:-/swapfile}
    
    echo ""
    echo "Processingcreate $swap_size GB swap file..."
    
    if [ -f "$swap_file" ]; then
     echo "file $swap_file already exists"
     read -p "if you want todelete and recreate? (y/N): " confirm
     if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo swapoff "$swap_file" 2>/dev/null
      sudo rm -f "$swap_file"
     else
      echo "Operation cancelled"
      echo ""
      read -p "Press Enter to continue..."
      break
     fi
    fi
    
    sudo dd if=/dev/zero of="$swap_file" bs=1G count="$swap_size" status=progress 2>/dev/null || {
     echo "create swap filefailed"
     echo ""
     read -p "Press Enter to continue..."
     break
    }
    
    echo "Processing settingpermissions..."
    sudo chmod 600 "$swap_file"
    
    echo "Processing setting up as swap..."
    sudo mkswap "$swap_file"
    
    echo "Processingenable swap..."
    sudo swapon "$swap_file"
    
    echo ""
    echo "Processingadding to /etc/fstab..."
    if ! grep -q "$swap_file" /etc/fstab; then
     echo "$swap_file none swap sw 0 0" | sudo tee -a /etc/fstab
     echo "Added to /etc/fstab"
    else
     echo "/etc/fstab already has this configuration"
    fi
    
    echo ""
    echo "swap filecreateCompleted！"
    echo ""
    echo "current swap status:"
    free -h | grep -i swap
    echo ""
    read -p "Press Enter to continue..."
    ;;
   2)
    clear
    echo -e "${BLUE}=== delete swap file ===${NC}"
    echo ""
    echo "current swap configuration:"
    swap_files=$(swapon --show --noheadings | grep -v "TYPE=partition" | awk '{print $1}')
    swap_partitions=$(swapon --show --noheadings | grep "TYPE=partition" | awk '{print $1}')
    
    if [ -z "$swap_files" ] && [ -z "$swap_partitions" ]; then
     echo "Not found swap fileorpartition"
     echo ""
     read -p "Press Enter to continue..."
     break
    fi
    
    if [ -n "$swap_files" ]; then
     echo "Swap file:"
     echo "$swap_files"
    fi
    
    if [ -n "$swap_partitions" ]; then
     echo "Swap partition:"
     echo "$swap_partitions"
     echo ""
     echo -e "${YELLOW}Note: Swap partitions cannot be deleted with this tools, only disabled${NC}"
     echo -e "${YELLOW}To delete partitions, please use partition toolss like fdisk or parted${NC}"
    fi
    echo ""
    
    if [ -z "$swap_files" ] && [ -n "$swap_partitions" ]; then
     echo -e "${RED}current system only has swap partition, no swap file${NC}"
     echo -e "${RED}Swap partitions cannot be deleted, only disabled${NC}"
     echo ""
     read -p "if you want toto disable swap partition? (y/N): " confirm_disable
     if [[ "$confirm_disable" =~ ^[Yy]$ ]]; then
      echo "Processingdisableall swap..."
      sudo swapoff -a 2>/dev/null || echo "disablefailed"
      echo "Swap disabled"
      
      echo ""
      echo "Note: Swap partition still exists, it's just disabled"
      echo "To permanently delete partitions, please use partition toolss like fdisk or parted"
     else
      echo "Operation cancelled"
     fi
     echo ""
     read -p "Press Enter to continue..."
     break
    fi
    
    default_swap=$(echo "$swap_files" | head -1)
    read -p "Please enterswap file path to delete (Default: $default_swap): " swap_file
    swap_file=${swap_file:-$default_swap}
    
    if [ -z "$swap_file" ]; then
     echo "path cannot is empty"
     echo ""
     read -p "Press Enter to continue..."
     break
    fi
    
    # checking if input is a swap partition
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
     echo -e "${RED}Error: $swap_file is a swap partition, cannot delete${NC}"
     echo ""
     echo -e "${YELLOW}Swap partitions cannot be deleted with this tools, only disabled${NC}"
     echo ""
     read -p "if you want toto disable this swap partition? (y/N): " confirm_disable
     if [[ "$confirm_disable" =~ ^[Yy]$ ]]; then
      echo "Processingdisable swap partition..."
      sudo swapoff "$swap_file" 2>/dev/null || echo "disable failed or not enabled"
      echo "Swap partition disabled"
      
      echo ""
      echo "Note: Swap partition still exists, it's just disabled"
      echo "To permanently delete partitions, please use partition toolss like fdisk or parted"
     else
      echo "Operation cancelled"
     fi
     echo ""
     read -p "Press Enter to continue..."
     break
    fi
    
    if [ ! -f "$swap_file" ]; then
     echo "Error: $swap_file is not a valid swap file"
     echo ""
     read -p "Press Enter to continue..."
     break
    fi
    
    read -p "Confirmdelete $swap_file? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
     echo "Processingdisable swap..."
     sudo swapoff "$swap_file" 2>/dev/null || echo "disable failed or not enabled"
     
     echo "Processingfrom /etc/fstab..."
     sudo sed -i "\|$swap_file|d" /etc/fstab
     
     echo "Processingdeletefile..."
     sudo rm -f "$swap_file"
     
     echo ""
     echo "swap filedeleted"
    else
     echo "Operation cancelled"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   3)
    clear
    echo -e "${BLUE}=== Adjust swappiness value ===${NC}"
    echo ""
    current_swappiness=$(cat /proc/sys/vm/swappiness)
    echo "current swappiness value: $current_swappiness"
    echo ""
    echo "Swappiness value explanation:"
    echo " 0-10: Try not to use swap"
    echo " 60: Default value, balanced usage"
    echo " 100: Actively use swap"
    echo ""
    read -p "Please enter new swappiness value (0-100, Default: 60): " new_swappiness
    new_swappiness=${new_swappiness:-60}
    
    if [[ "$new_swappiness" =~ ^[0-9]+$ ]] && [ "$new_swappiness" -ge 0 ] && [ "$new_swappiness" -le 100 ]; then
     echo "Processing setting swappiness to $new_swappiness..."
     sudo sysctl vm.swappiness="$new_swappiness"
     
     echo "Processing writing to /etc/sysctl.conf..."
     if grep -q "vm.swappiness" /etc/sysctl.conf; then
      sudo sed -i "s/vm.swappiness=.*/vm.swappiness=$new_swappiness/" /etc/sysctl.conf
     else
      echo "vm.swappiness=$new_swappiness" | sudo tee -a /etc/sysctl.conf
     fi
     
     echo ""
     echo "Swappiness set to $new_swappiness"
     echo "New value: $(cat /proc/sys/vm/swappiness)"
    else
     echo "Invalid value，Please enter a number between 0-100"
    fi
    echo ""
    read -p "Press Enter to continue..."
    ;;
   4)
    clear
    echo -e "${BLUE}=== View swappiness value ===${NC}"
    echo ""
    echo "current swappiness value: $(cat /proc/sys/vm/swappiness)"
    echo ""
    echo "Swappiness value explanation:"
    echo " 0-10: Try not to use swap"
    echo " 60: Default value, balanced usage"
    echo " 100: Actively use swap"
    echo ""
    echo "swap Usage:"
    free -h | grep -i swap
    echo ""
    echo "swap Detailed information:"
    swapon --show
    echo ""
    read -p "Press Enter to continue..."
    ;;
   0)
    break
    ;;
   *)
    echo "Invalidoptions"
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
  echo "Trying to download from mirror: $mirror"
  if command -v wget &> /dev/null; then
   if wget -q --show-progress -O "$output" "$mirror" 2>/dev/null; then
    if [ -f "$output" ]; then
     if [ -s "$output" ]; then
      file_type=$(file "$output" 2>/dev/null)
      echo "File type: $file_type"
      if echo "$file_type" | grep -i "xz\|gzip\|tar\|compressed\|archive" &>/dev/null; then
       echo "Download successful!"
       return 0
      else
       echo "Downloaded file format incorrect，Trying next mirror..."
       rm -f "$output"
      fi
     else
      echo "Downloaded file is empty，Trying next mirror..."
      rm -f "$output"
     fi
    else
     echo "Downloaded file does not exist，Trying next mirror..."
    fi
   else
    echo "Download failed，Trying next mirror..."
   fi
  elif command -v curl &> /dev/null; then
   if curl -L -o "$output" --progress-bar "$mirror" 2>/dev/null; then
    if [ -f "$output" ]; then
     if [ -s "$output" ]; then
      file_type=$(file "$output" 2>/dev/null)
      echo "File type: $file_type"
      if echo "$file_type" | grep -i "xz\|gzip\|tar\|compressed\|archive" &>/dev/null; then
       echo "Download successful!"
       return 0
      else
       echo "Downloaded file format incorrect，Trying next mirror..."
       rm -f "$output"
      fi
     else
      echo "Downloaded file is empty，Trying next mirror..."
      rm -f "$output"
     fi
    else
     echo "Downloaded file does not exist，Trying next mirror..."
    fi
   else
    echo "Download failed，Trying next mirror..."
   fi
  fi
  echo "Download failed，Trying next mirror..."
 done
 
 echo "All mirror sourcesDownload failed"
 return 1
}



install_python() {
 while true; do
  clear
  print_header
  echo -e "${BLUE}=== Install Python ===${NC}"
  echo ""
  echo "Available versions:"
  echo " 1) Python 3.8.20"
  echo " 2) Python 3.9.21"
  echo " 3) Python 3.10.19"
  echo " 4) Python 3.11.14"
  echo " 5) Python 3.12.12"
  echo " 6) Install other version"
  echo ""
  read -p "Please selectversion (Default: 3.12): " python_version
  python_version=${python_version:-5}
  
  case $python_version in
   1) python_ver="3.8.20" ;; 
   2) python_ver="3.9.21" ;; 
   3) python_ver="3.10.19" ;; 
   4) python_ver="3.11.14" ;; 
   5) python_ver="3.12.12" ;; 
   6) 
    read -p "Please enter Python version to install (e.g.: 3.7.10): " python_ver
    while [ -z "$python_ver" ]; do
     read -p "version number cannot is empty，Please re-enter: " python_ver
    done
    ;; 
   *) python_ver="3.12.12" ;; 
  esac
  
  read -p "Please enter installation directory (Default: /usr/local/python3): " install_dir
  install_dir=${install_dir:-/usr/local/python3}
  
  echo ""
  echo "Processing download of Python $python_ver..."
  cd "$install_dir" 2>/dev/null || { sudo mkdir -p "$install_dir" && cd "$install_dir"; }
  
  # Checking and automatically installing compilation dependencies
  echo "Checking and automatically installing compilation dependencies..."
  local dependencies_installed=1
  
  if [ "$PM" = "apt" ]; then
   echo "Using apt package manager to install dependencies..."
   if sudo apt update && sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget curl libbz2-dev; then
    echo "✓ Dependencies installed successfully"
   else
    echo "✗ failed to install dependencies"
    dependencies_installed=0
   fi
  elif [ "$PM" = "yum" ]; then
   echo "Using yum package manager to install dependencies..."
   if sudo yum groupinstall -y 'Development toolss' && sudo yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel; then
    echo "✓ Dependencies installed successfully"
   else
    echo "✗ failed to install dependencies"
    dependencies_installed=0
   fi
  elif [ "$PM" = "dnf" ]; then
   echo "Using dnf package manager to install dependencies..."
   if sudo dnf groupinstall -y 'Development toolss' && sudo dnf install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel; then
    echo "✓ Dependencies installed successfully"
   else
    echo "✗ failed to install dependencies"
    dependencies_installed=0
   fi
  else
   echo "Checking basic compilation toolss..."
   if command -v gcc &> /dev/null && command -v make &> /dev/null; then
    echo "✓ Basic compilation toolss installed"
   else
    echo "✗ Missing compilation toolss"
    echo "Please manually install compilation dependencies and retry"
    dependencies_installed=0
   fi
  fi
  
  if [ $dependencies_installed -eq 0 ]; then
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  # Python-specific mirror source
  local python_mirrors=(
   "https://mirrors.aliyun.com/python-release/source/Python-${python_ver}.tar.xz"
  )
  
  local downloaded=0
  for mirror in "${python_mirrors[@]}"; do
   echo "Trying to download from Python mirror: $mirror"
   if command -v wget &> /dev/null; then
    if wget -q --show-progress -O "Python-${python_ver}.tar.xz" "$mirror" 2>/dev/null; then
     if [ -f "Python-${python_ver}.tar.xz" ] && [ -s "Python-${python_ver}.tar.xz" ]; then
      echo "Python MirrorDownload successful!"
      downloaded=1
      break
     else
      echo "Python MirrorDownload failed，Trying next..."
      rm -f "Python-${python_ver}.tar.xz"
     fi
    else
     echo "Python MirrorDownload failed，Trying next..."
    fi
   elif command -v curl &> /dev/null; then
    if curl -L -o "Python-${python_ver}.tar.xz" --progress-bar "$mirror" 2>/dev/null; then
     if [ -f "Python-${python_ver}.tar.xz" ] && [ -s "Python-${python_ver}.tar.xz" ]; then
      echo "Python MirrorDownload successful!"
      downloaded=1
      break
     else
      echo "Python MirrorDownload failed，Trying next..."
      rm -f "Python-${python_ver}.tar.xz"
     fi
    else
     echo "Python MirrorDownload failed，Trying next..."
    fi
   fi
  done
  
  if [ $downloaded -eq 0 ]; then
   echo "Python-specificMirrorDownload failed，Trying generic mirror..."
   download_with_mirrors "https://www.python.org/ftp/python/${python_ver%.*}/Python-${python_ver}.tar.xz" "Python-${python_ver}.tar.xz" || {
    echo ""
    read -p "Press Enter to continue..."
    break
   }
  fi
  
  if [ ! -f "Python-${python_ver}.tar.xz" ]; then
   echo "Downloaded file does not exist"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  if [ ! -s "Python-${python_ver}.tar.xz" ]; then
   echo "Downloaded file is empty"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  if ! tar -tf "Python-${python_ver}.tar.xz" &>/dev/null; then
   echo "Downloaded file is corrupted，Please delete and retry"
   rm -f "Python-${python_ver}.tar.xz"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  # Converting to absolute path
  install_dir=$(realpath "$install_dir")
  echo "Using absolute installation directory: $install_dir"
  
  # extractedfile
  if [ -f "Python-${python_ver}.tar.xz" ]; then
   echo "Processingextracted Python-${python_ver}.tar.xz..."
   tar -xf Python-${python_ver}.tar.xz
  else
   echo "Python Compressfiledoes not exist"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  # Finding extracted directory
  local extract_dir=$(find . -name "Python-*" -type d | grep -E "Python-${python_ver%.*}" | head -1)
  if [ -z "$extract_dir" ]; then
   local extract_dir=$(find . -name "*Python*" -type d | grep -E "${python_ver%.*}" | head -1)
  fi
  
  if [ -z "$extract_dir" ]; then
   echo "Cannot find extracted Python directory"
   echo "Please manually check current directory: $(pwd)"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  echo "Found extracted directory: $extract_dir"
  cd "$extract_dir"
  
  # checksystemmemory
  echo "checksystemmemory..."
  local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  if [ "$mem_total" -lt 2097152 ]; then # Less Than 2GB
   echo "Warning: System memory less than 2GB, compilation may fail"
   echo "Suggestionion: At least 2GB memory, 4GB or more recommended"
  fi
  echo "Processing compilation options..."
  ./Configure --prefix=$install_dir
  
  if [ $? -ne 0 ]; then
   echo "Configure failed, please check dependencies"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  # compilation Python
  echo "Processing Python compilation..."
  if make -j$(nproc); then
   echo "✓ Python compilation successful"
  else
   echo "✗ Python compilation failed, trying single-threaded compilation..."
   if make; then
    echo "✓ Python single-threaded compilation successful"
   else
    echo "✗ Python compilation failed, please check system environment"
    echo ""
    read -p "Press Enter to continue..."
    break
   fi
  fi
  
  # Install Python
  echo "ProcessingInstall Python..."
  if sudo make install; then
   echo "✓ Python installation successful"
  else
   echo "✗ Python installation failed, please check permissions"
   echo ""
   read -p "Press Enter to continue..."
   break
  fi
  
  echo ""
  echo "Python $python_ver installation completed!"
  echo "Installation directory: $install_dir"
  if [ -f "$install_dir/bin/python3" ]; then
   $install_dir/bin/python3 --version
  else
   echo "Python executable does not exist, please check installation process"
  fi
  echo ""
  echo "createSymbolic Link:"
  echo " sudo ln -sf $install_dir/bin/python3 /usr/local/bin/python3"
  echo " sudo ln -sf $install_dir/bin/pip3 /usr/local/bin/pip3"
  echo ""
  echo "ProcessingcreateSymbolic Link..."
  sudo ln -sf $install_dir/bin/python3 /usr/local/bin/python3
  sudo ln -sf $install_dir/bin/pip3 /usr/local/bin/pip3
  echo "Symbolic LinkcreateCompleted!"
  echo ""
  echo "Verifying Python 3 installation:"
  if command -v python3 &> /dev/null; then
   python3 --version
  else
   echo "Python 3 command not found, please check if symbolic link creation was successful"
  fi
  echo ""
  read -p "Press Enter to continue..."
  break
 done
}

install_node() {
 while true; do
  clear
  print_header
  echo -e "${BLUE}=== Install Node.js ===${NC}"
  echo ""
  
  echo "Available versions:"
  echo " 1) Node.js 16.20.0 (Stable version)"
  echo " 2) Node.js 18.19.1 (LTS)"
  echo " 3) Node.js 24.11.1 (Latest version)"
  echo " 4) Install other version"
  echo ""
  read -p "Please selectversion (Default: 18.19.1): " node_version
  node_version=${node_version:-2}
  
  case $node_version in
   1) node_ver="16.20.0" ;;
   2) node_ver="18.19.1" ;;
   3) node_ver="24.11.1" ;;
   4) 
    read -p "Please enter Node.js version (e.g.: 16.18.0): " node_ver
    while [ -z "$node_ver" ]; do
     read -p "version number cannot is empty，Please re-enter: " node_ver
    done
    ;;
   *) 
    # Checking if input is valid version number format (e.g., 20.11.1)
    if [[ "$node_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
     node_ver="$node_version"
    else
     node_ver="18.19.1"
    fi
    ;;
  esac
  
  # Detecting system version, giving warning for older systems
  local os_version=""
  if [ -f /etc/redhat-release ]; then
   os_version=$(cat /etc/redhat-release)
  elif [ -f /etc/os-release ]; then
   os_version=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
  fi
  
  # Detecting if this is an older system (e.g., CentOS 7)
  local is_old_system=0
  if [[ "$os_version" =~ CentOS[[:space:]]7 ]] || [[ "$os_version" =~ CentOS[[:space:]]6 ]]; then
   is_old_system=1
  fi
  
  # extracteding Node.js major version
  local node_major_version=$(echo "$node_ver" | cut -d'.' -f1)
  
  # If this is an older system and installing Node.js 18+ version, giving warning
  if [ $is_old_system -eq 1 ] && [ $node_major_version -ge 18 ]; then
   echo ""
   echo -e "${YELLOW}Warning: Detected your system is an older version${NC}"
   echo -e "${YELLOW}Installing Node.js $node_ver may encounter compatibility issues${NC}"
   echo -e "${YELLOW}Suggestion installing Node.js 16.x version for better compatibility${NC}"
   echo ""
   read -p "Do you want to continue installation $node_ver? (y/n): " confirm_install
   if [[ ! "$confirm_install" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled"
    read -p "Press Enter to continue..."
    break
   fi
  fi
  
  read -p "Please enter installation directory (Default: /usr/local/node): " install_dir
  install_dir=${install_dir:-/usr/local/node}
  
  echo ""
  echo "Processing download of Node.js $node_ver..."
  cd "$install_dir" 2>/dev/null || { sudo mkdir -p "$install_dir" && cd "$install_dir"; }
  
  # checksystemarchitecture
  local arch=$(uname -m)
  if [ "$arch" = "x86_64" ]; then
   arch="x64"
  elif [ "$arch" = "aarch64" ]; then
   arch="arm64"
  else
   echo "unsupportedarchitecture: $arch"
   read -p "Press Enter to continue..."
   break
  fi
  
  echo "current architecture: $arch"
  
  # Node.js download link (using glibc-217 version, compatible with all systems)
  local node_url="https://r.cnpmjs.org/-/binary/node-unofficial-builds/v${node_ver}/node-v${node_ver}-linux-${arch}-glibc-217.tar.xz"
  local node_file="node-v${node_ver}-linux-${arch}-glibc-217.tar.xz"
  
  echo "Download link: $node_url"
  
  # Downloading Node.js
  local downloaded=0
  if command -v wget &> /dev/null; then
   if wget -q --show-progress -O "$node_file" "$node_url" 2>/dev/null; then
    if [ -f "$node_file" ] && [ -s "$node_file" ]; then
     echo "Node.js Download successful!"
     downloaded=1
    else
     echo "Node.js Download failed"
     rm -f "$node_file"
    fi
   else
    echo "Node.js Download failed"
   fi
  elif command -v curl &> /dev/null; then
   if curl -L -o "$node_file" --progress-bar "$node_url" 2>/dev/null; then
    if [ -f "$node_file" ] && [ -s "$node_file" ]; then
     echo "Node.js Download successful!"
     downloaded=1
    else
     echo "Node.js Download failed"
     rm -f "$node_file"
    fi
   else
    echo "Node.js Download failed"
   fi
  else
   echo "Download tools not found, please install wget or curl"
   read -p "Press Enter to continue..."
   break
  fi
  
  if [ $downloaded -eq 0 ]; then
   echo "Download failed, please check network connection"
   read -p "Press Enter to continue..."
   break
  fi
  
  # checkDownloaded file
  if [ ! -f "$node_file" ]; then
   echo "Downloaded file does not exist"
   read -p "Press Enter to continue..."
   break
  fi
  
  if [ ! -s "$node_file" ]; then
   echo "Downloaded file is empty"
   read -p "Press Enter to continue..."
   break
  fi
  
  if ! tar -tf "$node_file" &>/dev/null; then
   echo "Downloaded file is corrupted，Please delete and retry"
   rm -f "$node_file"
   read -p "Press Enter to continue..."
   break
  fi
  
  # Converting to absolute path
  install_dir=$(realpath "$install_dir")
  echo "Using absolute installation directory: $install_dir"
  
  # extractedfile
  echo "Processingextracted $node_file..."
  tar -xf "$node_file"
  
  # Finding extracted directory
  local extract_dir=$(find . -name "node-v*" -type d | grep -E "node-v${node_ver}" | head -1)
  if [ -z "$extract_dir" ]; then
   echo "Cannot find extracted Node.js directory"
   echo "Please manually check current directory: $(pwd)"
   read -p "Press Enter to continue..."
   break
  fi
  
  echo "Found extracted directory: $extract_dir"
  
  # Renamedirectory
  local node_install_dir="$install_dir/node-${node_ver}"
  if [ -d "$node_install_dir" ]; then
   echo "Directory $node_install_dir already exists, will be overwritten"
   sudo rm -rf "$node_install_dir"
  fi
  
  sudo mv "$extract_dir" "$node_install_dir"
  echo "Moved to: $node_install_dir"
  
  # createSymbolic Link
  echo ""
  echo "Node.js $node_ver installation completed!"
  echo "Installation directory: $node_install_dir"
  
  # Verifying installation
  if [ -f "$node_install_dir/bin/node" ]; then
   $node_install_dir/bin/node --version
   $node_install_dir/bin/npm --version
  else
   echo "Node.js executable does not exist, please check installation process"
   read -p "Press Enter to continue..."
   break
  fi
  
  echo ""
  echo "createSymbolic Link:"
  echo " sudo ln -sf $node_install_dir/bin/node /usr/local/bin/node"
  echo " sudo ln -sf $node_install_dir/bin/npm /usr/local/bin/npm"
  echo " sudo ln -sf $node_install_dir/bin/npx /usr/local/bin/npx"
  echo ""
  echo "ProcessingcreateSymbolic Link..."
  sudo ln -sf $node_install_dir/bin/node /usr/local/bin/node
  sudo ln -sf $node_install_dir/bin/npm /usr/local/bin/npm
  sudo ln -sf $node_install_dir/bin/npx /usr/local/bin/npx
  echo "Symbolic LinkcreateCompleted!"
  echo ""
  echo "Verifying Node.js installation:"
  if command -v node &> /dev/null; then
   node --version
   npm --version
  else
   echo "Node.js command not found, please check if symbolic link creation was successful"
  fi
  echo ""
  read -p "Press Enter to continue..."
  break
 done
}

main() {
 check_root
 while true; do
  clear
  print_header
  print_menu
  read -p "Please select an option: " choice

  case $choice in
   1)
    show_system_info
    ;;
   2)
    file_operations
    ;;
   3)
    network_toolss
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
    echo -e "${GREEN}Thank you for using $SCRIPT_NAME！${NC}"
    echo ""
    exit 0
    ;;
   *)
    echo -e "${RED}Invalid option, please retry。${NC}"
    sleep 1
    ;;
  esac
 done
}

main
