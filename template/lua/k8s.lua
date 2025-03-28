function string:startswith(start)
    return self:sub(1, #start) == start
end

local function transform(content)
    local out = ""
    for line in content:gmatch("([^\n]*)\n") do
        if not utils.is_comment(line) then
            out = out .. line .. "\n"
        end
    end
    return out
end

local function identity(content)
    return content
end

return identity
