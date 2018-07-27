local args = {...}
if type(args[1]) ~= "number" then
  error("invalid argument #1, computer ID expected", 2)
end
os.pullEvent = os.pullEventRaw
rednet.open("top")

local queueTbl = {}

local function queue()
    while true do
        local e = {os.pullEvent()}
        if e[1] == "char" or e[1] == "key" or e[1] == "paste" then
            table.insert(queueTbl,e)
        elseif e[1] == "terminate" and not peripheral.find("modem") then
            return
        end
    end
end

local function send()
    while true do
        sleep(.15)
        if #queueTbl>0 then
            rednet.send(args[1],queueTbl,"KEYBOARD")
            queueTbl = {}
        end
    end
end

parallel.waitForAny(send,queue)