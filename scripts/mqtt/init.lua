wifi.setmode(wifi.STATION)
wifi.sta.config("Visonic","tar14072014")
wifi.sta.connect()

print('MAC: ',wifi.sta.getmac())
print('heap: ',node.heap())

print("Starting...")
function init_restart()
    if wifi.sta.status() ~= 5 then node.restart()
    else
        print('IP address: ',wifi.sta.getip())  
        dofile('main.lua')  
    end
end

function init_main()
    if wifi.sta.status() ~= 5 then tmr.alarm(0, 3000, 0, function() init_restart() end)
    else
        print('IP address: ',wifi.sta.getip())
        dofile('main.lua')
    end
end

init_main()