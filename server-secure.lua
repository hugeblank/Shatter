-- Secure keystroke event transmitter by hugeblank
-- This code goes on any old computer with a modem attached, and a wireless keyboard bound
-- Argument 1: Modem Channel

local args = {...}
if type(args[1]) ~= "number" then
    error("invalid argument #1, modem channel expected")
end
local smt = require("/smt")
local t = smt("smt.main.transit")
local tQueue = {}
local cid
t.openChannel(args[1])
parallel.waitForAll(t.listener, function()
    _, cid = os.pullEvent("RLWE-Finish")
    print("Connection Established with NI")
    while true do
        if #tQueue ~= 0 then
            print(textutils.serialise(tQueue))
            t.sendData(cid, textutils.serialise(tQueue))
        end
        tQueue = {}
        sleep(.15)
    end
end,
function()
    while true do
        local _, uncid, msg = os.pullEvent("RLWE-Receive")
        if msg == "REBOOT" then
            os.reboot()
        end
    end
end,
function()
    while true do
        local e = {os.pullEvent()}
        if e[1] == "char" or e[1] == "key" or e[1] == "paste" then
            tQueue[#tQueue+1] = e
        end
        if e[1] == "terminate" and not peripheral.find("modem") then
            return
        end
    end
end)
