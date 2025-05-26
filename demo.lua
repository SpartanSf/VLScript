--[[

THIS TEST REQUIRES VLSCRIPT

]]


local obelisk = require("obelisk")
local vlscript = require("vlscript")


-- vlscript code
local code = [[
define main {
    let x 5000000000
    let f #'loop
    call f
    halt
}

define loop {
    - x x 1
    if = x 0 {
        return
    }
    jump f
}

]]

print("Please be patient as lua tries to work...")
local luaStart = os.epoch("utc") / 1000
-- slow asf lua
local x = 5000000000
repeat
    x = x - 1
until x == 0

local luaEnd = os.epoch("utc") / 1000
print("Lua: " .. (math.floor((luaEnd - luaStart) * 1000 + 0.5) / 1000) .. "s")

local obeliskoid = obelisk.new() -- Spawn a new obelisk VM instance

-- Completely compile and load the bytecode for the previous vlscript script
local data = vlscript.compile(vlscript.buildAST(vlscript.tokenize(code)))

local log = fs.open("obl2.log", "w")
log.writeLine(textutils.serialise(data))
log.flush()

--data = vlscript.compile(data)
obeliskoid:quickBytecode(0, data)

local start = os.epoch("utc") / 1000
-- absolute lua demolisher
obeliskoid:run()
local endtime = os.epoch("utc") / 1000
print("Obelisk: " .. (math.floor((endtime - start) * 1000 + 0.5) / 1000) .."s")

print("Final output information:\n")
print("Stack: "..textutils.serialise(obeliskoid.stack))
print("Variables: "..textutils.serialise(obeliskoid.variables))
