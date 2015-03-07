dht22 = require("dht22")
gpio.mode(3, gpio.OUTPUT)

m = mqtt.Client("esp_18-FE-34-9D-60-F0", 60)

-- Handler subscribe function
function MQTT_On()
    -- subscribe topic with qos = 0
    m:subscribe("/myhome/esp_18-FE-34-9D-60-F0/light", 0, function(conn) print("Subscribe success")end)

    tmr.alarm(1, 20000, 1, function()
        dht22.read(4)
        local t = dht22.getTemperature()
        t = ((t-(t % 10)) / 10).."."..string.format("%.i",(t % 10))
        m:publish("/myhome/esp_18-FE-34-9D-60-F0/temperature",t,0,0, function()
            print("Sent temperature "..t)
            local h = dht22.getHumidity()
            if h ~= nil then
                h = ((h -(h % 10)) / 10).."."..string.format("%.i",(h % 10))
                m:publish("/myhome/esp_18-FE-34-9D-60-F0/humidity",h,0,0, function()
                    print("Sent humidity "..h)
                end)
            end
        end)
    end)
    
    m:on("offline", function(con)
        print ("offline.Reconnecting")
        node.restart()
    end)

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
end

function MQTT_Connect()
    print("Connecting to MQTT server")
    tmr.alarm(0, 5000, 0, function() node.restart() end)
    m:connect("192.168.1.9", 1883, 0, function(conn)
        tmr.stop(0)
        print("Connected. Subscriber id: esp_18-FE-34-9D-60-F0")
        MQTT_On()
    end)
end

m:lwt("/lwt", "offline", 0, 0)
MQTT_Connect()
