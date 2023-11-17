import socket
import yaml

# UDP client socket
udp = socket.socket(type=socket.SOCK_DGRAM)
udp.bind(("", 17707))

while True:
    msg = udp.recv(1024)
    telemetry = yaml.safe_load(msg.decode())
    print(telemetry)
