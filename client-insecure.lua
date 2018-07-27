-- Insecure keystroke event client by hugeblank
-- This code goes on your neural interface, with a wireless modem in the peripherals cross
-- Argument 1: Server Computer ID

local args = {...}
args[1] = tonumber(args[1])
if type(args[1]) ~= "number" then
  error("invalid argument #1, computer ID expected", 2)
end
local ms = peripheral.getNames()
for i = 1, #ms do
    if peripheral.getType(ms[i]) == "modem" then
        rednet.open(ms[i])
    end
end
while true do
  local id, queue = rednet.receive("KEYBOARD")
  if id == args[1] then
    for i = 1, #queue do
      os.queueEvent(unpack(queue[i]))
    end
  end
end
