-- package.path = package.path .. ";" .. os.getenv( "HOME" ) .. "/code/lua/lib/?.lua"

local ok, util = pcall(require, "lib_utils")
if not ok then
    print("require not satisfied: lib_utils")
    return
end

local M = {}



-- local list1 = M.filter_letters_known1( "relish\nfollow\nfrolic\n", "l13,i,o" )
-- print(list1)
-- local list2 = M.filter_letters_known1( "relish\nfollow\nfrolic\n", "lio" )
-- print(list2)

local test_discards = function()
    local discards = M.read_used_dict("../used_words.txt")
end

-- test_discards()

return M
