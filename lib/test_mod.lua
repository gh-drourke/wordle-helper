
local M = {}

-- private
local message = "Hello world!"

function M.hello()
    print(message)
end

function M.dprint(str, debug)
    debug = debug or false
    if debug then
        -- str = M.remove_nl(str)
        print(str)
    end
end

return M
