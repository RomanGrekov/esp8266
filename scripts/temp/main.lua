m = mqtt.Client("esp_"..wifi.sta.getmac(), 60)
id="esp_"..wifi.sta.getmac()

function connect()
print("Connecting to MQTT server")
tmr.alarm(0, 5000, 0, function() connect() end)
m:connect("192.168.1.9", 1883, 0, function(conn)
tmr.stop(0)
print("Connected")
end)
end

connect()