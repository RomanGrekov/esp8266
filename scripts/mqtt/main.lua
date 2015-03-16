function subscribe()
     m:subscribe("/myhome/"..id.."/light",0,function(conn)print("Subscribe success")end)  
     m:on("message",function(conn,topic,data)
          print(topic .. ": "..data )
          if data=="ON"then gpio.write(3, gpio.LOW)end
          if data=="OFF"then gpio.write(3, gpio.HIGH)end
     end)
end

function dht22_get_data()
     dht22=require("dht22")
     dht22.read(4)
     local t=dht22.getTemperature()
     local h=dht22.getHumidity()
     if t~=nil then
          t=((t-(t % 10))/10).."."..string.format("%.i",(t % 10))
     else t=nil
     end
     if h~=nil then
          h=((h-(h % 10))/10).."."..string.format("%.i",(h % 10))
     else h=nil
     end
     dht22=nil
     package.loaded["dht22"]=nil
     collectgarbage()
     return t, h  
end

function post_data()
     t, h = dht22_get_data()
     if t ~= nil then
          m:publish("/myhome/"..id.."/temperature",t,0,0, function()
               print("Temperature "..t)
               if h ~= nil then
                    m:publish("/myhome/"..id.."/humidity",h,0,0, function()print("Humidity "..h)end)
               end
          end)
     end
end

function init_network()
     collectgarbage()
     print(id)
     if wifi.sta.status() ~= 5 then
          print("Reconnecting WIFI")
          wifi.setmode(wifi.STATION)
          wifi.sta.config("Visonic","tar14072014")
          wifi.sta.connect()
          tmr.alarm(0,5000,0,function()init_network()end)
     else
          print("IP: "..wifi.sta.getip())
          print("Connecting to MQTT server")
          tmr.alarm(0,7000,0,function()init_network()end)
          if m~=nil then
               m:close()
          end
          m = mqtt.Client(id, 120)
          m:connect("192.168.1.9",1883,0,function(conn)
               tmr.stop(0)
               print("Connected")
               subscribe()
               tmr.alarm(0, 60000, 1, function() post_data() end)
               m:on("offline",function(con)
                    print("offline.Reconnecting")
                    init_network()
               end)
          end)
     end
end

gpio.mode(3, gpio.OUTPUT)
id="esp_"..wifi.sta.getmac()
init_network()
