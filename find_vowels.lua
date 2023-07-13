-- name:    find_vowels.lua
-- purpose: print list of words that contain specified number of vowels.


local function isempty(s)
    return s == nil or s == ''
end

local function addRelPath(dir)
    if not isempty(dir) then
        print("addRelPath for: " .. dir)
    else
        print("addRelPath for: " .. "current")
    end
    -- transformations are performed to ensure that the spath represents
    -- .. a relative path to the current Lua script file.
    local spath =
        debug.getinfo(1, 'S').source
        :sub(2)                  -- remove the "@" symbol from position 1
        :gsub("^([^/])", "./%1") -- replace the start '/' if exist, with './'
        :gsub("[^/]*$", "")      -- removes everything after the last forward slash
    print("** " .. spath)
    dir = dir and (dir .. "/") or ""
    print("** " .. dir)
    spath = spath .. dir
    print("** " .. spath)
    package.path = spath .. "?.lua;"
        .. spath .. "?/init.lua"
        .. package.path
end

addRelPath("lib")

-- package.path = package.path .. ";" .. os.getenv("HOME") .. "/code/lua/lib/?.lua"
local ok, util = pcall(require, "myutils")
if not ok then
    print("require not satisfied")
    return
end

-- Filter words from table. Each filterd word contains  nvowels.
-- Return as table.
local function filter_vowels(tab, nvowels)
    local ret_list = {}
    for _, v in pairs(tab) do
        if nvowels == util.count_pattern(v, "%s*[aeiou]") then
            print(v)
            table.insert(ret_list, v)
        end
    end
    return ret_list
end

-- Return table of letters wherein each entry is a letter.
-- Given a string, Add each letter of that string to a table
-- Return that table
local function split2Tab(str)
    local tab = {}
    for i = 1, #str do
        local c = str:sub(i, i)
        table.insert(tab, c)
    end
    return tab
end

-- Given a table of letter values representing a word,
-- Return true if one or more letters repeat themselves.
-- Return false if all letters in parameter tab are unique.
local function hasDuplicateLetters(tab)
    local hashSet = {}
    for _, value in pairs(tab) do
        if hashSet[value] ~= nil then
            -- Duplicate
            return true
        else
            hashSet[value] = true
        end
    end
    return false
end

-- Given a word list of type table
-- Remove words with any duplicate letters
-- Return new word list (type table) ith each word having unique letters.
local function removeDuplicates(tab)
    local new = {}
    local count = 0
    for _, value in pairs(tab) do
        -- test new word for duplicate letters
        local wordTab = split2Tab(value)
        if hasDuplicateLetters(wordTab) then
            count = count + 1
            --print("removing: " .. value)    -- Duplicate
        else
            table.insert(new, value)
        end
    end
    return new, count
end

local function printTable(tab)
    for i, v in pairs(tab) do
        print(i, v)
    end
end

local vowel_find = function(nvowels)
    local count_orginal, count_duplicates, count_noDuplicates
    local tt = util.read_file_to_table("wordlist.txt")
    count_orginal = #tt

    tt, count_duplicates = removeDuplicates(tt)
    count_noDuplicates = #tt

    tt = filter_vowels(tt, nvowels)
    print("..... count with  " .. tostring(nvowels) .. " " .. "vowels: " .. #tt)

    print("..... count duplicates:      " .. count_duplicates)
    print("..... count no duplicates:   " .. count_noDuplicates)
    print("..... count orginal list:    " .. count_orginal)
end

local function main()
    local cmd_args = util.collect_cmd_line_args()
    -- example find_vowels v=3
    local nvowels = cmd_args["v"]
    vowel_find(tonumber(nvowels))
end

main()
