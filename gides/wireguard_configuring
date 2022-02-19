проверяем, что модуль загружен:

# modprobe wireguard && lsmod | grep wireguard
wireguard 225280 0
ip6_udp_tunnel 16384 1 wireguard
udp_tunnel 16384 1 wireguard
Создаём открытый и закрытый ключи для сервера и для клиента. 

 mkdir ~/wireguard
 cd ~/wireguard
 umask 077
 wg genkey | tee server_private_key | wg pubkey > server_public_key
 wg genkey | tee client_private_key | wg pubkey > client_public_key
В результате, у нас будет создано четыре файла:

tail *

# nano /etc/sysctl.conf 
net.ipv4.ip_forward = 1
# sysctl -p
############################################3
#Создаём директорию /etc/wireguard, а в ней конфигурационный файл /etc/wireguard/wg0.conf со следующим содержимым:

nano /etc/wireguard/wg0.conf 

[Interface]
Address = 10.8.0.1/24
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
PrivateKey = SERVER_PRIVATE_KEY

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.8.0.2/32
#Разумеется, вместо SERVER_PRIVATE_KEY и CLIENT_PUBLIC_KEY мы прописываем ключи, из созданных ранее файлов. Далее, комментарии по конфигу:
#Address — адрес виртуального интерфейса wg0 на сервере.
#PostUp и PostDown — команды, которые будут выполнены при включении и отключении интерфейса.
#ListenPort — порт, на котором будет работать VPN.
#AllowedIPs — виртуальные IP клиентов, которые будут подключаться к нашему серверу.
#Сохраняем изменения, делаем файл доступным только для root, включаем и запускаем сервис:

# chmod 600 /etc/wireguard/wg0.conf
# systemctl enable wg-quick@wg0.service
# systemctl restart wg-quick@wg0.service

#Настройка wireguard клиента.
#Добавьте репозиторий Wireguard в ваш список источников. Затем Apt автоматически обновит кеш пакета.

sudo add-apt-repository ppa:wireguard/wireguard
Установите Wireguard. Пакет установит всю необходимую зависимость.

sudo apt install wireguard
#Переходим в директорию /etc/wireguard, а в ней создаем конфигурационный файл /etc/wireguard/wg0-client.conf со следующим содержимым:

# cd /etc/wireguard
# nano wg0-client.conf 
[Interface]
Address = 10.8.0.2/32
PrivateKey = CLIENT_PRIVATE_KEY
DNS = 8.8.8.8

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = SERVER_REAL_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
#В данном случае, вместо CLIENT_PRIVATE_KEY и SERVER_PUBLIC_KEY мы опять же, подставляем ключи, сгенерированные ранее, а вместо SERVER_REAL_IP прописываем IP адрес нашего сервера, на котором установлен VPN.

#Сохраняем файл, и пробуем подключиться командой wg-quick up wg0-client:

# wg-quick up wg0-client

[#] ip link add wg0-client type wireguard
[#] wg setconf wg0-client /dev/fd/63
[#] ip address add 10.8.0.2/32 dev wg0-client
[#] ip link set mtu 1420 dev wg0-client
[#] ip link set wg0-client up
[#] mount `8.8.8.8' /etc/resolv.conf
[#] wg set wg0-client fwmark 51820
[#] ip -4 route add 0.0.0.0/0 dev wg0-client table 51820
[#] ip -4 rule add not fwmark 51820 table 51820
[#] ip -4 rule add table main suppress_prefixlength 0
#Проверяем подключение, и если всё сделано верно, то весь наш трафик теперь будет проходить через VPN сервер.

#Для отключения от VPN просто выполняем команду wg-quick down wg0-client:

wg-quick down wg0-client

[#] ip -4 rule delete table 51820
[#] ip -4 rule delete table main suppress_prefixlength 0
[#] ip link delete dev wg0-client
[#] umount /etc/resolv.conf
#При необходимости, мы можем управлять сервисом через systemd:

systemctl restart wg-quick@wg0-client.service
#Для андроид можем скачать приложение Wireguard

qrencode -t ansiutf8 < wg0.conf
