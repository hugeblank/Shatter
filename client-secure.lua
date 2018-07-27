local args = {...}
if type(args[1]) ~= "number" then
    error("invalid argument #1, modem channel expected", 2)
end
if type(args[2]) ~= "string" then
    error("invalid argument #2, SMT UUID expected", 2)
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
