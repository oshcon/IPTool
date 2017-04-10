#!/bin/bash

function my_ip()
{
    echo Getting your public IP...
    ip=`dig +short myip.opendns.com @resolver1.opendns.com`
    echo $ip
}

function who_is()
{
    if hash whois 2>/dev/null; then
        echo 'Input the domain to lookup:'
    	read domain
    	whois "$domain"
    	else
    	    echo "Please install the program 'whois' to use this."
    fi
}

function valid_ip()
{
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

function geo_lookup()
{
    local ipinput=$1
    if valid_ip $ipinput; then stat='valid'; else stat='invalid'; fi
    if [ "$stat" == "valid" ]; then
        curl ipinfo.io/$ipinput
    else
        echo That IP is invalid. Returning to menu.
    fi
}

function scan_port()
{
    local host=$1
    local port=$2
    timeout 2 bash -c "echo >/dev/tcp/$host/$port" &&
        echo "Port TCP:$port is open for host $host" ||
        echo "Port TCP:$port is closed for host $host"
    timeout 2 bash -c "echo >/dev/udp/$host/$port" &&
        echo "Port UDP:$port is open for host $host" ||
        echo "Port UDP:$port is closed for host $host"
}

function main() 
{
    echo IPTool by Conor - ヤホー!
    PS3='> '
    options=("QUIT" "MYIP" "WHOIS" "IFCONFIG" "GEOIP" "PORTSCAN")
    select option in "${options[@]}"
    do
        case $option in
            "QUIT")
                echo "Have a good day! :)"
                break
                ;;
            "MYIP")
                my_ip
                ;;
            "WHOIS")
                who_is
                ;;
            "IFCONFIG")
                ifconfig
                ;;
            "GEOIP")
                echo 'Input the IP the lookup:'
                read ipinput
                geo_lookup $ipinput
                ;;
            "PORTSCAN")
                echo 'Input host to scan:'
                read host
                echo 'Input port to scan:'
                read port
                scan_port $host $port
                ;;
            *) echo Invalid option;;
        esac
    done
}

main
