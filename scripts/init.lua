print('init.lua ver 1.2')
wifi.setmode(wifi.STATION)
wifi.sleeptype(wifi.NONE_SLEEP)
wifi.sta.autoconnect(1)
print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
-- wifi config start
wifi.sta.config("Visonic","tar14072014")
wifi.sta.connect()
wifi.sta.setip({ip="192.168.1.10",netmask="255.255.255.0",gateway="192.168.1.1"})

dofile("main.lua")

