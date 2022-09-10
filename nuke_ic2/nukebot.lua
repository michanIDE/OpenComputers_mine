local component = require("component")
local sides = require("sides")
local event = require("event")

local chunkloader = component.chunkloader
local robot = component.robot
local redstone = component.redstone
local generator = component.generator
local navigation = component.navigation
local invCnt = component.inventory_controller
local modem = component.modem

local farX = 0
local farY = 0
local farZ = 0

local x, y, z, sideX, sideY, sideZ
local port = 19213
local fuelSlot = 4
local n
local flg

local password = "password"

local function refillFuel()
    robot.select(fuelSlot)
    if generator.count() < 64 then
        generator.insert(64 - generator.count())
        if robot.count() < 1 then
            fuelSlot = fuelSlot + 1
        end
    end
end

local function turnUntil(side)
    while side ~= navigation.getFacing() do
        robot.turn(true)
    end
end

local function movefwd()
    n = robot.move(sides.front)
    if n == nil then
        robot.swing(sides.front)
        robot.move(sides.front)
    end
end

local function moveback()
    n = robot.move(sides.back)
    if n == nil then
        robot.swing(sides.back)
        robot.move(sides.back)
    end
end

local function moveup()
    n = robot.move(sides.top)
    if n == nil then
        robot.swing(sides.top)
        robot.move(sides.top)
    end
end

local function movedown()
    n = robot.move(sides.bottom)
    if n == nil then
        robot.swing(sides.bottom)
        robot.move(sides.bottom)
    end
end

local function placenuke()
    robot.select(1)
    robot.place(sides.front)
    robot.select(2)
    invCnt.dropIntoSlot(sides.front, 2)
    robot.select(3)
    invCnt.dropIntoSlot(sides.front, 1)

    redstone.setOutput(sides.front, 15)
    os.sleep(0.02)
    redstone.setOutput(sides.front, 0)
    os.sleep(15)
    chunkloader.setActive(false)
end

chunkloader.setActive(true)
modem.open(port)

while true do
    local _, _, from, _, _, recv = event.pull("modem_message")
    if recv == "activate" then
        break
    end
    os.sleep(0.02)
end
while true do
    local _, _, from, _, _, recv = event.pull("modem_message")
    if string.find(recv, "fwd ") ~= nil then
        local cmd, cnt = string.match(recv, "(.-)%s(.+)")
        local count = tonumber(cnt)
        for i = 1, count, 1 do
            movefwd()
            refillFuel()
        end
    elseif string.find(recv, "back ") ~= nil then
        local cmd, cnt = string.match(recv, "(.-)%s(.+)")
        local count = tonumber(cnt)
        for i = 1, count, 1 do
            moveback()
            refillFuel()
        end
    elseif string.find(recv, "up ") ~= nil then
        local cmd, cnt = string.match(recv, "(.-)%s(.+)")
        local count = tonumber(cnt)
        for i = 1, count, 1 do
            moveup()
            refillFuel()
        end
    elseif string.find(recv, "down ") ~= nil then
        local cmd, cnt = string.match(recv, "(.-)%s(.+)")
        local count = tonumber(cnt)
        for i = 1, count, 1 do
            movedown()
            refillFuel()
        end
    elseif string.find(recv, "turnr") ~= nil then
        robot.turn(true)
        refillFuel()
    elseif string.find(recv, "turnl") ~= nil then
        robot.turn(false)
        refillFuel()
    elseif string.find(recv, "nuke") ~= nil then
        placenuke()
    end
    os.sleep(0.02)
end
