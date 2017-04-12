#!/bin/bash
#
# Used to perform some simple routine IP lookup/info tasks.

function my_ip() {
  echo "**Using OpenDNS**"
  echo Getting your public IP...
  ip=`dig +short myip.opendns.com @resolver1.opendns.com`
  echo $ip
}

function who_is() {
  if hash whois 2>/dev/null; then
    echo "Input the domain to lookup:"
    read domain
    whois "$domain"
  else
    echo "Please install the program 'whois' to use this."
    echo "Example: sudo apt-get install whois"
  fi
}

function get_ip() {
  echo "Input domain to convert:"
  read domain
  host "$domain" | awk '/has address/ { print $4 ; exit }'
}

function is_valid_ip() {
  local ip=$1
  local stat=1
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

function geo_lookup() {
  PS3="Choose an option (1-2): "
  options=("ipinfo.io" "freegeoip.net")
  select option in "${options[@]}"
  do
    case $option in
      "ipinfo.io")
        echo "**Using IPInfo.io API**"
        echo 'Input the IP to lookup:'
        read ipinput
        if is_valid_ip $ipinput; then stat="valid"; else stat="invalid"; fi
        if [ "$stat" == "valid" ]; then
          curl ipinfo.io/$ipinput
        else
          echo That IP is invalid. Returning to menu.
        fi
        echo " "
        break
        ;;
      "freegeoip.net")
        echo "**Using FreeGeoIP API**"
        echo 'Input the IP to lookup:'
        read ipinput
        if is_valid_ip $ipinput; then stat="valid"; else stat="invalid"; fi
        if [ "$stat" == "valid" ]; then
          curl freegeoip.net/xml/$ipinput
        else
          echo That IP is invalid. Returning to menu.
        fi
        break
        ;;
      *)
        echo "Invalid option."
        ;;
    esac
  done
}

scan() {
  if [[ -z $1 || -z $2 ]]; then
    echo "Invalid port range defined."
    return
  fi

  local host=$1
  local ports=()
  case $2 in
    *-*)
      IFS=- read start end <<< "$2"
      for ((port=start; port <= end; port++)); do
        ports+=($port)
      done
      ;;
    *,*)
      IFS=, read -ra ports <<< "$2"
      ;;
    *)
      ports+=($2)
      ;;
  esac

  for port in "${ports[@]}"; do
    timeout $3 bash -c "echo >/dev/tcp/$host/$port" &&
      echo "port $port is open" ||
      echo "port $port is closed"
  done
}

function scan_ports() {
  echo "Input host to scan:"
  read host
  echo "Input port range to scan (ex. 80-120):"
  read ports
  echo "Input timeout delay in seconds:"
  read timeout
  scan $host $ports $timeout
}

function scan_all() {
  echo "Input host to scan:"
  read host
  ports="1-65535"
  echo "Input timeout delay in seconds:"
  read timeout
  scan $host $ports $timeout
}

function get_headers() {
  echo "**Using hackertarget API**"
  echo "Input URL:"
  read url
  curl https://api.hackertarget.com/httpheaders/?q=$url
}

function dump_links() {
  echo "**Using hackertarget API**"
  echo "Input URL:"
  read url
  curl https://api.hackertarget.com/pagelinks/?q=$url
}

function prompt() {
  echo " "
  PS3="Choose an option (1-11): "
   options=("QUIT" "MYIP" "WHOIS" "GETIP" "IFCONFIG" "GEOIP" "PORTSCAN" "SCANALL" "GETHEADERS" "DUMPLINKS" "OPENLOG")
  select option in "${options[@]}"
  do
    case $option in
      "QUIT")
        echo " "
        echo "Have a good day! :)"
        exit
        ;;
      "MYIP")
        echo " "
        echo "==============================="
        my_ip
        echo "==============================="
        prompt
        ;;
      "WHOIS")
        echo " "
        echo "==============================="
        who_is
        echo "==============================="
        prompt
        ;;
      "GETIP")
        echo " "
        echo "==============================="
        get_ip
        echo "==============================="
        prompt
        ;;     
      "IFCONFIG")
        echo " "
        echo "==============================="
        ifconfig
        echo "==============================="
        prompt
        ;;
      "GEOIP")
        echo " "
        echo "==============================="
        geo_lookup
        echo "==============================="
        prompt
        ;;
      "PORTSCAN")
        echo " "
        echo "==============================="
        scan_ports
        echo "==============================="
        prompt
        ;;
      "SCANALL")
        echo " "
        echo "==============================="
        scan_all
        echo "==============================="
        prompt
        ;;
      "GETHEADERS")
        echo " "
        echo "==============================="
        get_headers
        echo "==============================="
        prompt
        ;;
      "DUMPLINKS")
        echo " "
        echo "==============================="
        dump_links
        echo " "
        echo "==============================="
        prompt
        ;;
      "OPENLOG")
        nano ./"$LOG"
        echo " "
        echo "==============================="
        prompt
        ;;
      *)
        echo " "
        echo "Invalid option"
        prompt
        ;;
    esac
  done
}

function main() {
  if [ -z "$LOC" ]; then
    echo "Unable to get write permissions for current directory. Exiting.."
    exit 1
  fi

  echo " "
  echo "IPTool [死]"
  prompt
}

RELATIVE="`dirname \"$0\"`" 
LOC="`( cd \"$RELATIVE\" && pwd )`"
echo "Running at $LOC"
# TODO(oshcon): Copy stdout and stderr to a logfile in the relative directory.
main "$@"
