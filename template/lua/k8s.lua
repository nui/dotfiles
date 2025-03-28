require "lua-string"

local function transform(content)
    local out = ""
    for line in content:gmatch("([^\n]*)\n") do
        local line_no_leading_spaces = line:trimstart()
        local is_comment_line = line_no_leading_spaces:startswith("#")
        if not is_comment_line then
            out = out .. line .. "\n"
        end
    end
    return out
end

local function transform_rust(content)
    local out = ""
    for line in content:gmatch("([^\n]*)\n") do
        local line_no_leading_spaces = rs.str.trim_start(line)
        local is_comment_line = rs.str.starts_with(line_no_leading_spaces, "#")
        if not is_comment_line then
            out = out .. line .. "\n"
        end
    end
    return out
end

local function identity(content)
    return content
end

-- return transform
-- return transform_rust
return identity
