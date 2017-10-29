#!/bin/bash

set -u

TMPFILE="$(mktemp -t "$(basename $0).XXXXX")"
trap "[ -d \"${TMPFILE}\" ] && rm -rf \"${TMPFILE}\" " EXIT

AUTH_LOGIN="${AUTH_LOGIN:-your@email.here}"
AUTH_TOKEN="${AUTH_TOKEN:-6b*66...*hB**xU*8a**4A**Fn...Xx1}"
UKRAINE_ID="${UKRAINE_ID:-NNNNNNN}"
DOMAIN="${DOMAIN:-DOMAIN.YOUR}"

ADM_URL='https://adm.tools/api.php'

## setting ip through pipe are available ( -i OPT )
IP=
if [ ! -t 0  ]; then
  IP=$(cat -)
fi

CHECK=
PRINT_PARAMS=
CONF_FILE='/etc/ukraine.sh.conf'
SILENT=

function usage {
  cat << EOC 

  ukraine.sh - setter IP address for hoster 'ukraine.com.ua'
               through API

    -h|--help         - show this help
    -d|--domain       - set domain (DOMAIN var)
    -l|--login        - set login (AUTH_LOGIN var)
    --check           - check before update
    -p|--print-params - print parameters/credentials end exit
    -i|--ip           - IP address to set for domain name

    --config       - path to config file
        This file may contain variables

          AUTH_LOGIN='your@email.here' # --login option
          AUTH_TOKEN="6b*66*5c*hBBC9**...'
          UKRAINE_ID="NNNNNNN"
          DOMAIN="DOMAIN.YOUR"         # --domain option

          Default path: $CONF_FILE

  Usage:
    ukraine.sh [OPTIONS] IP_address 
  or
    echo IP_address | ukraine.sh 

EOC

}

while [ $# -gt 0 ]; do
  case "$1" in

    --help|-h|-\?)
      usage
      exit 0
      ;;
    
    -i|--ip)
      IP=$2
      shift 2
      ;;

    -d|--domain)
      DOMAIN=$2
      shift 2
      ;;

    -l|--login)
      AUTH_LOGIN=$2
      shift 2
      ;;

    -c|--check)
      CHECK=1
      shift
      ;;

    --config)
      CONF_FILE=$2
      shift 2
      ;;

    -p|--print-params)
      PRINT_PARAMS=1
      shift
      ;;

    -s|--silent)
      SILENT=1
      shift
      ;;

    --)
      # Rest of command line arguments are non option arguments
      shift # Discard separator from list of arguments
      continue
      ;;

    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;

    *) 
      IP=$1
      shift
      ;;

  esac
done

function curl_call {
  local MODE=${1:-gag}
  local DATA=${2:-}

  local METHOD=info
  [ "x${DATA}" != 'x' ] && METHOD=edit

  echo '{' > $TMPFILE
  echo "\"auth_login\": \"$AUTH_LOGIN\"," >> $TMPFILE
  echo "\"auth_token\": \"$AUTH_TOKEN\"," >> $TMPFILE
  echo "\"class\": \"dns_record\","       >> $TMPFILE
  echo "\"domain\": \"${DOMAIN}\","       >> $TMPFILE
  echo "\"method\": \"$METHOD\""          >> $TMPFILE

  [ "x${DATA}" != "x" ] && \
    echo ",$DATA"                         >> $TMPFILE
  echo '}' >> $TMPFILE

  local CMD=()
  CMD+=( curl --silent --request POST )
  CMD+=( --header "Content-Type: application/json" )
  CMD+=( --data @${TMPFILE} )
  CMD+=( $ADM_URL )
  CMD+=( "| jq '.data[] | select(.id == \"${UKRAINE_ID}\")" )
  if [ "${MODE}" == 'print_ip' ]; then
    CMD+=( " | .data '  | sed -e 's/\"//g' " )
  else
    CMD+=( "'" )
  fi

  eval ${CMD[@]}
}

##
## Body
##
if [ -f "${CONF_FILE}" ]; then
  source "${CONF_FILE}"
fi

if [ -n "${PRINT_PARAMS}" ]; then
  echo "# Parameters/credentials"
  echo "AUTH_LOGIN=$AUTH_LOGIN"
  echo "AUTH_TOKEN=$AUTH_TOKEN"
  echo "UKRAINE_ID=$UKRAINE_ID"
  echo "DOMAIN=$DOMAIN"
  exit 0
fi

if [ -n "${CHECK}" -a -z "${IP}" ]; then
  echo 'Incompatible mode. --check applicable only with IP'
  exit 1
fi

if [ -n "${IP}" ]; then

  DATA_TO_SET="\"stack\":[{\"id\":\"${UKRAINE_ID}\",\"data\":\"${IP}\"}]"

  if [ -n "${CHECK}" ]; then
    CUR_IP="$(curl_call 'print_ip' )"
    if [ "${CUR_IP}" != "$IP" ]; then
      [ -z "${SILENT}" ] && \
        echo "Previous IP '${CUR_IP}'; need to set '$IP'"
      curl_call 'set_ip' "${DATA_TO_SET}"
    else
      [ -z "${SILENT}" ] && \
      echo "Current and requeset to set IP is identical: '${CUR_IP}'"
    fi

  else
    [ -z "${SILENT}" ] && \
      echo "Set IP '${IP}' without check"
    curl_call 'set_ip' "${DATA_TO_SET}"
  fi

fi

[ -z "${SILENT}" ] && \
  curl_call 


