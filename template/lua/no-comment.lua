local function transform(content)
    local buf = rs.StringBuf.with_capacity(#content)
    for line in rs.String.new(content):lines() do
        local line_no_leading_spaces = line:trim_start()
        local is_comment_line = line_no_leading_spaces:starts_with("#")
        if not is_comment_line then
            buf:push(line)
            buf:put_newline()
        end
    end
    return buf:take_string():trim().val
end

local function identity(content)
    return content
end

return transform
-- return identity
