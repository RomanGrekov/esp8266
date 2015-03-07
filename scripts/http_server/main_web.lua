dht22 = require("dht22")
                
SWITCH_PIN = 3
DHT22_PIN = 4

gpio.mode(SWITCH_PIN, gpio.OUTPUT)

tmr.alarm(0, 10000, 1, function()
     print("connect ".. tmr.now())
     wifi.sta.connect()
     end )

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
        local _, _, method, action = string.find(request, "([A-Z]+) .+?([a-z_=]+) HTTP");
        print(request)
        
        if(method == "GET")then          
            if(action == "get_switch_state")then
                local text_state = "";
                local pin_state = 0;
            
                pin_state = gpio.read(SWITCH_PIN)
                if(pin_state == 1)then
                      text_state = "OFF";
                elseif(pin_state == 0)then
                      text_state =  "ON";
                end
                print("State " .. text_state)
                client:send(wrap(text_state));
            end
            if(action == "set_switch_state=on")then
                    print("Switch on")
                    gpio.write(SWITCH_PIN, gpio.LOW);
                    client:send("HTTP/1.1 200 OK\r\nContent-Type: text/xml; charset=utf-8\r\nContent-Length: 0");
            end
            if(action == "set_switch_state=off")then
                    print("Switch off")
                    gpio.write(SWITCH_PIN, gpio.HIGH);
                    client:send("HTTP/1.1 200 OK\r\nContent-Type: text/xml; charset=utf-8\r\nContent-Length: 0");
            end
            
            if(action == "get_temp")then
                dht22.read(DHT22_PIN)
                t = dht22.getTemperature()
                t = ((t-(t % 10)) / 10).."."..string.format("%.i",(t % 10))
                print ("Temperature " .. t)
                client:send(wrap(t));
            end
            if(action == "get_humid")then
                dht22.read(DHT22_PIN)
                h = dht22.getHumidity()
                h = ((h - (h % 10)) / 10).."."..string.format("%.i",(h % 10))
                print("Humidity " .. h)
                client:send(wrap(h));

            end
        end
        client:close();
        collectgarbage();
    end)
    --dht22 = nil
    --package.loaded["dht22"]=nil
    conn:on("sent",function(conn) conn:close() end)
end)

function wrap (val)
    return "<h1>"..val.."</h1>"
end
