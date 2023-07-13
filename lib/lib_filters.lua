local M = {}

local ok, util = pcall(require, "lib_utils")
if not ok then
    print("require not satisfied: lib_utils")
    return
end

-- Return nl terminated list of words that match pattern.
function M.filter_letters_exact(word_list, pattern)
    -- pattern is used to find words that contain all letters in pattern
    pattern = pattern or "-----" -- Default for pattern is 5 hyphens
    print([[--- Filtered for Exact Letter Matches::  pattern is: ]] .. util.remove_nl(pattern))
    local count = 0
    local new_list = ""

    -- Append word to new_list if word matches pattern
    for word in word_list:gmatch(pattern) do
        if (#word ~= 0) and (word ~= nil) then
            new_list = new_list .. word
            count = count + 1
        end
    end
    return new_list, count
end

-- Eliminate (Block) words that contain any letter in b_letters
-- Any word that contains a 'block' letter (b_letters) is disqualfied
-- Return a new word_list without these disqualifications.
function M.filter_letters_block(word_list, b_letters)
    b_letters = b_letters or ""
    print("\n--- Filtered for eliminated letters:: letters are: " .. b_letters)

    -- 1: Build the remove list
    local remove_list = ""
    for word in word_list:gmatch("%a+\n") do -- for each word in list
        -- io.write( "--> checking new word: " .. word )

        -- local word_added = false
        for test_letter in util.string_iter(b_letters) do
            local first, _ = word:find(test_letter) -- does word contain letter?
            if first ~= nil then                    -- disqualify this word
                -- dprint( "      .. letter: " .. test_letter .. "  found in: " .. word )
                -- if not word_added then
                remove_list = remove_list .. word
                -- word_added = true
                -- io.write( "                                         --> remove list word added: " .. word )
                goto next_word
                -- end
                -- else
                -- 	dprint( "      .. letter: " .. test_letter .. "  NOT found in: " .. word )
            end
        end
        ::next_word::
    end

    -- dump
    -- print( "\n---- remove list: dump start ----" )
    -- for w in remove_list:gmatch( "%a+\n" ) do
    --     io.write( "  dump:  " .. w )
    -- end
    -- print( "---- dump end ----\n" )

    -- 2: Create the return list
    --		Apply the remove_list to the input word_list

    local new_list = ""
    local return_count = 0

    for outer_word in word_list:gmatch("%a+\n") do -- for each word in word_list
        -- io.write( "outer = " .. outer_word )
        local outer_passed_over = false
        for w in remove_list:gmatch("%a+\n") do
            -- io.write( "       inner:  " .. w )
            if not outer_passed_over then
                if outer_word == w then -- MATCH FOUND!
                    -- pass over. do not put this in the new list
                    -- pass over. No need to check more inners
                    -- io.write( "        --> pass over: " .. outer_word )
                    outer_passed_over = true
                end
            end
        end
        -- At end of for loop to check for inner word, add to new_list if not passed over
        if outer_passed_over == false then
            -- dprint( "       --> adding outer_word to return list: " .. outer_word )
            new_list = new_list .. outer_word
            return_count = return_count + 1
        end
    end

    return new_list, return_count
end

-- If word_list contains a word in used_list, then remove it
function M.filter_used(word_list, used_list)
    local new_list = ""
    local remove_list = ""

    local found
    for outer_word in word_list:gmatch("%a+\n") do -- for each word in word_list
        found = false
        for inner in used_list:gmatch("%a+\n") do  -- for each word in word_list
            if outer_word == inner then
                remove_list = remove_list .. outer_word
                -- io.write( outer_word )
                found = true
                goto continue
            end
        end
        ::continue::
        if not found then
            new_list = new_list .. outer_word
        end
    end

    return new_list, remove_list
end


-- test_digits: 'digits' are the index restrictions for 'letter' in 'word'
local test_digits = function(word, letter, digits)
    if digits == nil or digits == "" then
        util.dprint("      no digits")
        return true -- letter appears but no digit restrictions so allow letter
    end

    for digit in util.string_iter(digits) do
        local c = word:sub(tonumber(digit), tonumber(digit))
        util.dprint("      index:character: " .. digit .. ":" .. c, false)
        if c == letter then
            util.dprint("        disqualify: " .. c .. " at position " .. digit)
            return false
        end
    end
    return true
end

-- filter_letters_know:
-- Return List of words that contain each and every letter in 'k_letters'
-- Format:
-- currently: example: "loi"
-- proposed: l34,oi32 where the digits are where the letters are know but not exact.
-- ie l is know but is not in the 3 or 4  position
-- o is know in any position
-- i is know but is not tin the 3 or 2 position
-- comma is an optional separarator after digits if any

M.filter_letters_known = function(word_list, k_letters)
    k_letters = k_letters or ""
    print("\n--- Filtered for Known Letter in Unknown positions:: letters are: " .. k_letters)
    local ret_count = 0 -- return value
    local ret_list = "" -- return value

    if #k_letters == 0 then
        return word_list, util.count_lines(word_list)
    end

    -- test each word for all letters
    for word in word_list:gmatch("%a+\n") do -- for each word in list
        local found_count = 0               -- found_count has a scope of one word
        local letter_count = 0              -- count of letters only -- no digits

        for letter, digits in k_letters:gmatch("(%a)(%d*),?") do
            letter_count = letter_count + 1 -- each iteration does one letter plus optional digits
            local first, _ = word:find(letter) -- does word contain letter?
            if first ~= nil then
                if test_digits(word, letter, digits) then
                    found_count = found_count + 1
                end
            end
        end                           -- for all letter in word

        if found_count == letter_count then -- word contains all valid letters
            ret_count = ret_count + 1
            ret_list = ret_list .. word

            util.dprint(util.remove_nl(word) .. " found")
        else
            util.dprint(util.remove_nl(word) .. " not found")
        end
    end -- for each word

    util.dprint("-------------------")
    return ret_list, util.count_lines(ret_list)
end

return M
