import socket
import yaml

# UDP client socket
udp = socket.socket(type=socket.SOCK_DGRAM)
udp.bind(("", 17707))

total_ammo_last = 0
doors_open_last = 0

while True:
    msg = udp.recv(1024)
    telemetry = yaml.safe_load(msg.decode())
    # print(telemetry)

    # process ammo - simply watch for changes in count
    total_ammo = sum(telemetry['ammo'])
    total_ammo_change = total_ammo - total_ammo_last
    if total_ammo_change != 0:
        total_ammo_last = total_ammo
        print(f"ammo count changed to: %d" % total_ammo)
        if total_ammo_change > 0:
            print(f"loaded %d more ammo." % total_ammo_change)
        else:
            print(f"used %d ammo." % -total_ammo_change)

    # process doors - everything >0 counts as open
    doors_open = sum(map(lambda x: x > 0, telemetry['doors']))
    doors_open_change = doors_open - doors_open_last
    if doors_open_change != 0:
        doors_open_last = doors_open
        if doors_open_change > 0:
            print(f"%d doors opened." % doors_open_change)  # small bump
        else:
            print(f"%d doors closed." % -doors_open_change)  # big bump
