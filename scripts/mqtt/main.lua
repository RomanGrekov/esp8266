gpio.mode(3, gpio.OUTPUT)
m = mqtt.Client("esp_"..wifi.sta.getmac(), 60)
id="esp_"..wifi.sta.getmac()

print("Connecting to MQTT server")
tmr.alarm(0, 5000, 0, function() node.restart() end)
m:connect("192.168.1.9", 1883, 0, function(conn)
tmr.stop(0)

m:subscribe("/myhome/"..id.."/light", 0, function(conn) print("Subscribe success")end)

m:on("message",function(conn,topic,data)
    print(topic .. ": "..data )
    if data ~= nil then
        if data == "ON" then
            gpio.write(3, gpio.LOW)
        end
        if data == "OFF" then
            gpio.write(3, gpio.HIGH)
        end
    end
end)

tmr.alarm(1, 20000, 1, function()
    dht22 = require("dht22")
    dht22.read(4)
    local t = dht22.getTemperature()
    local h = dht22.getHumidity()
    dht22=nil
    package.loaded["dht22"]=nil
    
    t = ((t-(t % 10)) / 10).."."..string.format("%.i",(t % 10))
    m:publish("/myhome/"..id.."/temperature",t,0,0, function()
        print("Sent temperature "..t)
        if h ~= nil then
            h = ((h -(h % 10)) / 10).."."..string.format("%.i",(h % 10))
            m:publish("/myhome/"..id.."/humidity",h,0,0, function()
                print("Sent humidity "..h)
            end)
        end
    end)
    collectgarbage()
end)
    
m:on("offline", function(con)
    print ("offline.Reconnecting")
    node.restart()
end)
end)
