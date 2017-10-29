
# ukraine.sh 
IP address setter for hosting company [ukraine.com.ua] (https://ukraine.com.ua)

How to run

    Options:

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

          Default path: /etc/ukraine.sh.conf

    Usage:
      ukraine.sh [OPTIONS] [OPTIONS] IP_address
    or
      echo IP_address | [OPTIONS] ukraine.sh


Example

    $ echo "127.0.0.$(date +%S)" | ./ukraine.sh --check
    Previous IP '127.0.0.37'; need to set '127.0.0.52'
    {
      "id": "NNNNNNN",
      "record": "SUB.DOMAIN.org.",
      "type": "A",
      "priority": "",
      "data": "127.0.0.52"
}


Enjoy :)
