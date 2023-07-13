-- Extract used wordle words from web page

-- List has form:
--     <h2>All Wordle answers</h2>
--     <ul class="inline">
--     <li>ABACK</li>
--     <li>ABASE</li>
--     ...
--     </ul>

local cURL = require("cURL")

-- Function to retrieve the complete web page source using cURL
local function fetchWebPage(url)
    local response = {}

    local easy = cURL.easy()
    easy:setopt_url(url)
    easy:setopt_writefunction(function(data)
        table.insert(response, data)
        return #data
    end)
    easy:perform()
    easy:close()

    return table.concat(response)
end

-- function to extract text between start pattern and end pattern
local function extractText(inputText, startPattern, endPattern)
    local startPos, endPos = string.find(inputText, startPattern)
    if startPos and endPos then
        local startOffset = endPos + 1
        local endOffset = string.find(inputText, endPattern, startOffset)
        if endOffset then
            return string.sub(inputText, startOffset, endOffset - 1)
        end
    end
    return nil
end

local function listUsedWords()
    -- URL of the web page to scrape
    local url = "https://www.rockpapershotgun.com/wordle-past-answers"

    local page_source = fetchWebPage(url)

    local start_pattern = "<h2>All Wordle answers</h2>"
    local end_pattern = "</ul>"
    local page_extract = extractText(page_source, start_pattern, end_pattern)

    local answer_pattern = "<li>([A-Z]+)</li>"
    local answers = {}
    for answer in page_extract:gmatch(answer_pattern) do
        table.insert(answers, answer)
    end

    for i, answer in ipairs(answers) do
        print(i,answer)
    end
end

listUsedWords()
