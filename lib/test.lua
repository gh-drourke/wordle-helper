local util = require "lib_utils"
local tm = require "test_mod"



local function test_cmd_flag()
    print("\n--- test: collect_cmd_line_flags")
    local flags = util.collect_cmd_line_flags()

    print("flag dump")
    for i, v in pairs(flags) do
        print(i, v)
    end
    if flags["w"] then
        print("w exists")
    else
        print("w does not exists")
    end

    print("end test 2\n")
end


print("Hello from test.lua")
print(util.trim("    trim me    "))
util.dprint(" I am dprint", true)
tm.hello()


test_cmd_flag()

