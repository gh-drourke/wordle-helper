local M = {}

function M.dprint(str, debug)
    debug = debug or false
    if debug then
        str = M.remove_nl(str)
        print(str)
    end
end

--[[ to use:

package.path = package.path .. ";" .. os.getenv( "HOME" ) .. "/code/lua/lib/?.lua"
local ok, util = pcall( require, "myutils" )
if not ok then
	print( "require not satisfied" )
	return
end
]] --


-- ----------------------------- OS ----------------------------------

-- Execute an OS command
function M.osExecute(cmd)
    local fileHandle = assert(io.popen(cmd, "r"))
    local commandOutput = assert(fileHandle:read("*a"))
    local returnTable = { fileHandle:close() }
    return commandOutput, returnTable[3] -- rc[3] contains returnCode
end

--[[
Note on commande line arguements
If an argument name is a single letter, it’s standard to prefix it with a single dash
1. Flags    -l
2. Arguement with no value:         --help
3. Arguement with value:            --block-size <value> 
4. Arguement with value:            x=<value>   note: simple to collect and parse
                                    i.e. each argument is written as one contiguous string.
]] --

-- Collect command line arguments of form x=<value>
-- Return table of these arguments
function M.collect_cmd_line_args()
    local tab = {}
    for i = 1, #arg do
        if arg[i]:match("%a=") then
            local spec = string.sub(arg[i], 1, 1)
            local new_arg = string.sub(arg[i], 3, #arg[i])
            tab[spec] = new_arg
        end
    end
    return tab
end

local function test_collect_cmd_line_args()
    print("\n--- test: collect_cmd_line_args")
    local test = [[line one
	line two
	line three
	]]
    -- M.write_file( "testout.txt" ) end
    print("line count: " .. M.count_lines(test))
    print("second line is: " .. M.get_lineN(test, 2))
end

-- collect command line flags of form <hyphen><letter> value. Note space.
-- the form:  -uv is not supported
function M.collect_cmd_line_flags()
    local flags = {}

    for i = 1, #arg do
        -- print("testing arg: " .. i .. "  " .. arg[i])
        -- if arg[i]:find( "h", 2, true ) == 1 then
        -- 	print( "arg startwith" .. arg[i] )
        -- end
        if arg[i]:match("^%-") then
            local new_arg = string.sub(arg[i], 2, 2) -- take one letter only
            -- TODO: take a sequence of letters
            -- print("new arg: " .. new_arg)
            -- table.insert(flags, new_arg)
            flags[new_arg] = true
        end
    end
    return flags
end

local function test_cmd_flag()
    print("\n--- test: collect_cmd_line_flags")
    local flags = M.collect_cmd_line_flags()

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

-- ----------------------------- File Handling ----------------------------------

-- Test for existence of file.
-- Return true if the file exists, else return false.
function M.file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

function M.file_create(file)
    local f = io.open(file, "w")
    if f then
        f:close()
    end
    return f ~= nil
end

-- Return contents of file as a string.
-- Return nil if files does not exist.
function M.read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end
    local content = file:read("a") -- *a or *all reads the whole file, *a for lua version 5.3 file:close()
    return content
end

M.read_used_dict = function(dict_name)
    local ret_string = ""

    -- if M.file_exists(dict_name) == false then
    --     print("file does not exist: " .. dict_name)
    --     return ret_string
    -- end

    local discards = M.read_file(dict_name)

    if discards == nil then
        print("Error: discards is nil")
    elseif #discards == 0 then
        print("Warning: no discards")
    else
        local count = 0
        for word in discards:gmatch("(%a+)\n") do -- for each word in list
            word = word .. "\n"
            word = string.lower(word)
            count = count + 1
            ret_string = ret_string .. word
        end
    end
    return ret_string
end

-- function M.write_file( fpath, contents )
--     local file = io.open( fpath, "w" )
--     if not file then return nil end
--     file:write( contents )
--     file:close()
-- end
--

-- ------------------------- Strings ---------------------------------------

-- Iterate over a string, character by character
-- Return nil if not found
-- Return idx number of character if found (1 = first position)
M.string_iter = function(str)
    local idx = 0
    -- print("init string_iter: str is: " .. str .. "  len is: " .. #str)
    return function()
        idx = idx + 1
        if idx <= #str then
            return string.sub(str, idx, idx)
        else
            return nil
        end
    end
end

-- Count the number of non-overlapping occurrences of a substring inside a string.
function M.count_substring(s1, s2)
    return select(2, s1:gsub(s2, ""))
end

-- Count the number of  occurrences of pattern p inside a string s.
function M.count_pattern(s, p)
    local count = 0
    for _ in string.gmatch(s, p) do
        count = count + 1
    end
    return count
end

-- split string and return a table
function M.mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function M.split(s, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for match in (s .. sep):gmatch("(.-)" .. sep) do
        table.insert(t, match)
    end
    return t
end

-- split a string with oldsep, return string with new sep
function M.split_and_concat(str, oldsep, newsep)
    local tt = M.split(str, oldsep)
    local tmp = {}
    for _, v in ipairs(tt) do
        table.insert(tmp, M.trim(v))
    end
    return table.concat(tmp, newsep)
end

function M.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- M.trim_all(string) => return string with white space trimmed on both sides
function M.trim_all(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- M.trim_left(string) => return string with white space trimmed on left side only
function M.trim_left(s)
    return (string.gsub(s, "^%s*(.*)$", "%1"))
end

-- trim_right(string) => return string with white space trimmed on right side only
function M.trim_right(s)
    return (string.gsub(s, "^(.-)%s*$", "%1"))
end

-- return 'true' if str endswith ptrn
--		note: to remove last chacter: s = s:sub(1, -2)
function M.endswith(str, ptrn)
    local s = #str + 1 - #ptrn
    return string.find(str, ptrn, s) == s
end

function M.ends_with(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

-- Return true if string s starts with prefix, false otherwise.
function M.startswith(str, prefix)
    return str:find(prefix, 1, true) == 1
end

function M.startswith2(str, start)
    return str:sub(1, #start) == start
end

-- remove nl from of string
-- examples: '', \n', a\n\r', 'ab\n
function M.remove_nl(str) -- TODO check for pattern [\r\n]  
    if not str then
        return ""
    end

    str = string.gsub(str, "[\r\n]*", '')
    -- print("rnl:orginal: " .. str)
    return str
end

local test_remove_nl = function()
    print("\ntest: remove_nl")
    print("1   abc-n : " .. M.remove_nl("abc\n"))
    print("2   ab-n  : " .. M.remove_nl("ab\n"))
    print("3     -n  : " .. M.remove_nl("\n"))
    print("4         : " .. M.remove_nl(""))
    print("5 nil     : " .. M.remove_nl(nil))
    print("6 line RN:  " .. M.remove_nl("6 line \r\n"))
    print("7 line NR:  " .. M.remove_nl("6 line \n\r"))
    print("--end")
end


function M.remove_pattern(s, p, b)
    b = b or false
    if b then
        print("\nrp: " .. p)
        print("rp orginal: " .. s)
    end
    s = s:gsub(p, '') -- replace pattern with ''
    if b then
        print("rp final  : " .. s)
    end
    return s
end

local test_remove_pattern = function()

    -- remove pattern from start of string
    print("\n--- remove pattern ';'")

    -- local pat = "^;+" -- start of line, one or more semi-colons
    local pat1 = "^[; ]+" -- start of line, one or more semi-colons
    local pat2 = "[; ]*$"
    -- local pat3 = "[; ]+\n"

    local s1 = ";; I have semi-colons line 1;"
    local s2 = "; I have semi-colons line 2;; "
    local s3 = "I have do not have semi-colons line 3; ;;;;;"
    local s4 = " ;;  ;;  I have semi-colons line 4"
    -- local s5 = " ;;  ;;  I have semi-colons line 5;;\n"

    for _, s in pairs { s1, s2, s3, s4 } do
        s = M.remove_pattern(s, pat1, true)
    end

    for _, s in pairs { s1, s2, s3, s4 } do
        s = M.remove_pattern(s, pat2, true)
    end

    for _, s in pairs { s1, s2, s3, s4 } do
        s = M.remove_pattern(s, pat1, false)
        s = M.remove_pattern(s, pat2, false)
        print("combined: " .. s)
    end

end


-- count lines in s
function M.count_lines(s)
    local count = 0
    for _ in s:gmatch("\n") do
        count = count + 1
    end
    return count
end

-- From s, return the nth line
function M.get_lineN(s, n)
    local count = 1
    for str in s:gmatch(".-\n") do
        if count == n then
            return str
        else
            count = count + 1
        end
    end
end

-- ------------------------------ tables -----------------------------------
function M.print_pairs(tt)
    for i, v in pairs(tt) do
        print(i, v)
    end
end

-- -------------------------------nTesting ---------------------------------

local test1 = false
if test1 == true then
    test_collect_cmd_line_args()
end

local test2 = false
if test2 == true then
    test_cmd_flag()
end

local test3 = false
if test3 then
    test_remove_nl()
end

local test4 = false
if test4 then
    test_remove_pattern()
end

return M
