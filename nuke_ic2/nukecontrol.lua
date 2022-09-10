local component = require("component")
local sides = require("sides")
local event = require("event")

local modem = component.modem

while true do 
    local str = io.read()
    modem.broadcast(19213, str)
    os.sleep(0.05)
end