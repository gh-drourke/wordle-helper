
local function split2Tab(str)
    -- return table of letters
    local tab = {}
	for i = 1, #str do
		local c = str:sub(i, i)
		--print(c)
        table.insert(tab, c)
	end
    return tab
end

local function removeDuplicates(tab)
	local hashSet = {}
	local new = {}
	for _, value in pairs(tab) do
		if hashSet[value] ~= nil then
			-- Duplicate
		else
			table.insert(new, value)
			hashSet[value] = true
		end
	end
    return new
end

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

local tab1 = split2Tab("Hello")
for _,v in pairs(tab1) do
    print(v)
end

print("has duplicate letters: " .. tostring(hasDuplicateLetters(tab1)))

print("====")
local tab2 = removeDuplicates(tab1)

for _,v in pairs(tab2) do
    print(v)
end

print("has duplicate letters: " .. tostring(hasDuplicateLetters(tab2)))

