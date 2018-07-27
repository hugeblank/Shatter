-- Secure keystroke event client by hugeblank
-- This code goes on your neural interface, with a wireless modem in the peripherals cross
-- Argument 1: Modem Channel (same as one on server)
-- Argument 2: SMT UUID (The servers SMT UUID)

local args = {...}
args[1] = tonumber(args[1])
if type(args[1]) ~= "number" then
    error("invalid argument #1, modem channel expected", 2)
end
local smt = require("/smt")
local t = smt("smt.main.transit")
local cid
t.openChannel(args[1])
parallel.waitForAll(t.listener, function()
    t.openTunnel(args[2], args[1])
    _, cid = os.pullEvent("RLWE-Finish")
    while true do
        local _, uncid, queue = os.pullEvent("RLWE-Receive")
        queue = textutils.unserialise(queue)
        if uncid == cid then
            for i = 1, #queue do
                os.queueEvent(unpack(queue[i]))
            end
        end
    end
end,
function()
    while true do
        local e = os.pullEvent("terminate")
        if e then
            t.sendData(cid, "REBOOT")
        end
    end
end)
