local _ = [[
In this application:

- a Dictionary is maintained as a stream of characters ( a lua string ) of the form:
    <word><nl><word><nl> ...
    All words in the dictionary are terminated by a newline.

- a sequence acts like a list and is only accessed in sequential order.

Usage example:

    lua wordle.lua b=adidet  e=mou--  k=n
    -- b must be 5 characters

    lua wordle.lua -h    <-- usage
]]


local function isempty(s)
    return s == nil or s == ''
end

local function getAbsSourcePath()
    local level = 2
    local info = debug.getinfo(level, "S")

    if info and info.source and info.source:sub(1, 1) == "@" then
        local scriptName = info.source:sub(2) -- remove '@'
        local currentDir = os.getenv("PWD") or io.popen("cd"):read()
        local filePath = currentDir .. "/" .. scriptName

        -- Extract the directory path
        local lastSeparatorIndex = filePath:match(".*[\\//]()")
        if lastSeparatorIndex then
            return filePath:sub(1, lastSeparatorIndex - 1)
        end
    end

    return nil -- Source path not found
end

local function addRelPath(dir)
    -- transformations to ensure that the spath represents
    -- .. a relative path to the current Lua script file.
    local spath =
        debug.getinfo(1, 'S').source
        :sub(2)                  -- remove the "@" symbol from position 1
        :gsub("^([^/])", "./%1") -- replace the start '/' if exist, with './'
        :gsub("[^/]*$", "")      -- remove everything after the last forward slash
    dir = dir and (dir .. "/") or ""
    spath = spath .. dir
    package.path = spath .. "?.lua;"
        .. spath .. "?/init.lua"
        .. package.path
end

addRelPath("lib")

-- package.path = package.path .. ";" .. os.getenv( "HOME" ) .. "/src/lua/lib/?.lua"

local ok, util = pcall(require, "lib_utils")
if not ok then
    print("require lib_utils not satisfied")
    return
end

local filter = require("lib_filters")

local debug = false
local cmdFlags

local print_exact = function(word_list, pattern)
    local list, count = filter.filter_letters_exact(word_list, pattern)
    io.write(list) -- each element in list ends with a newline
    print("---- count: " .. count)
    return list
end

local print_known = function(word_list, pattern)
    -- local list, count = filter_letters_known( word_list, pattern )
    local list, count = filter.filter_letters_known(word_list, pattern)
    io.write(list)
    print("---- count: " .. count)
    return list
end

local print_block = function(word_list, pattern)
    local list, count = filter.filter_letters_block(word_list, pattern)
    io.write(list)
    print("---- count: " .. count)
    return list
end

local print_used = function(word_list, used_list)
    local list, discards = filter.filter_used(word_list, used_list)

    print("\n--- filtered for discarded (used) words: ")
    io.write(list)
    print("---- count: " .. util.count_lines(list))

    if cmdFlags["u"] then
        print("\n--- discarded words are: ")
        io.write(discards)
        print("---- count: " .. util.count_lines(discards))
    end

    return list, discards
end

local make_exact_pattern = function(letters)
    local wc = "%a"
    local pattern = ""

    letters = letters or "-----"
    if #letters ~= 5 then
        print("error: make_exact_pattern requires 5 letters")
        return
    end
    letters = letters .. "\n"

    for let in util.string_iter(letters) do
        -- util.dprint("next letter: " .. let)
        if let == "-" then
            pattern = pattern .. wc
        else
            pattern = pattern .. let
        end
    end
    return pattern
end

local function make_source_path(fname)
    local source_path = getAbsSourcePath()
    return source_path .. fname
end

local wordle_start = function()
    local word_file = make_source_path("wordle_dict.txt")
    local used_words_file = make_source_path("used_words_dict.txt")

    if not util.file_exists(word_file) then
        print("Error: word file not found! Exiting")
        return
    end

    if not util.file_exists(used_words_file) then
        print("Warning: used_words_dict not found! Creating empty file")
        util.file_create(used_words_file)
        -- TODO - populate !
    end

    local all_words = util.read_file(word_file)
    local discards = util.read_used_dict(used_words_file)
    local cmd_args = util.collect_cmd_line_args()

    local arg_e = cmd_args["e"]
    local arg_k = cmd_args["k"]
    local arg_b = cmd_args["b"]
    print()

    local word_liste = print_exact(all_words, make_exact_pattern(arg_e))
    local word_listb = print_block(word_liste, arg_b)
    local word_listk = print_known(word_listb, arg_k)
    local word_final, discard_list = print_used(word_listk, discards)

    arg_e = arg_e or "not given"
    arg_b = arg_b or "not given"
    arg_k = arg_k or "not given"

    local a_count = util.count_lines(all_words)
    local x_count = util.count_lines(discards)
    local e_count = util.count_lines(word_liste)
    local b_count = util.count_lines(word_listb)
    local k_count = util.count_lines(word_listk)
    local u_count = util.count_lines(word_final)
    local d_count = util.count_lines(discard_list)

    local fmt = "%-12s %-24s count: %-12s"
    print(string.format("%s", "\n--- Summary Total Words -----"))
    print(string.format(fmt, "all      ", "from wordle dict", a_count))
    print(string.format(fmt, "used     ", "from used dict", x_count))
    
    print(string.format("%s", "\n--- Summary Filters -----"))
    print(string.format(fmt, "exact    ", arg_e, e_count))
    print(string.format(fmt, "block    ", arg_b, b_count))
    print(string.format(fmt, "known    ", arg_k, k_count))
    print(string.format(fmt, "final    ", "from dict", u_count))
    print(string.format(fmt, "discards ", "from dict", d_count))
    print("---")
end

local wordle_test = function()
    print("Wordle test mode")
    filter.filter_letters_known("fallow\nfollow\nfrolic\n", "li")
end

local function main()
    cmdFlags = util.collect_cmd_line_flags()
    if cmdFlags["h"] then
        print("usage: lua wordle.lua e=<letters k=<letters b=<letters")
        print(" e= for exactly positioned known letters (use hyphen for place markers)")
        print(" k= for know letters but unknown placement")
        print(" b= for blocked letters -- letters not in the word")
        print(" -u print used words filtered from final list")
        print(" -h help")
        return
    end
    if cmdFlags["t"] then
        wordle_test()
    else
        wordle_start()
    end
end

main()
