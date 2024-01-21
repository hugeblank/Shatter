-- Simple, insecure keystroke handler meant for use within an offhand pocket computer

local modem = assert(peripheral.find("modem"), "No modem found for keyboard listener module")
local events = {
    key = true,
    key_up = true,
    char = true,
    paste = true
}
local t = 0
while true do
    local e = table.pack(os.pullEvent())
    if events[e[1]] then
        modem.transmit(0, 0, e)
    end
end