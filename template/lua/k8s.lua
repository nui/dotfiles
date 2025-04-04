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
    local buf = rs.StringBuf.with_capacity(#content)
    for line in rs.String.new(content):lines() do
        local line_no_leading_spaces = line:trim_start()
        local is_comment_line = line_no_leading_spaces:starts_with("#")
        if not is_comment_line then
            buf:push(line)
            buf:put_newline()
        end
    end
    return buf.val
end

local function transform_rust_spans(content)
    local out = ""
    for span in rs.String.new(content):line_spans() do
        local start = span[1]
        local stop = span[2]
        local line = content:sub(start, stop)
        local line = rs.String.new(line)
        local line_no_leading_spaces = line:trim_start()
        local is_comment_line = line_no_leading_spaces:starts_with("#")
        if not is_comment_line then
            out = out .. line.val .. "\n"
        end
    end
    return out
end

local function identity(content)
    return content
end

-- return transform
-- return transform_rust
-- return transform_rust_spans
return identity
