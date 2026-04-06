--- lib/json.lua
--- Pure-Lua JSON encoder and decoder.
--- Supports null (json.null), booleans, numbers, strings, arrays, and objects.
--- Usage:
---   local json = require("lib.json")
---   local tbl  = json.decode('{"key":"value"}')
---   local str  = json.encode(tbl)

local json = {}

-- Sentinel value representing JSON null
json.null = setmetatable({}, { __tostring = function() return "null" end })

-- ─── Encoder ────────────────────────────────────────────────────────────────

local escape_map = {
    ['"']  = '\\"',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t',
}

local function encode_string(s)
    s = s:gsub('[\\"\b\f\n\r\t]', escape_map)
    s = s:gsub('[\0-\31]', function(c)
        return string.format('\\u%04x', c:byte())
    end)
    return '"' .. s .. '"'
end

local function is_array(t)
    local max, count = 0, 0
    for k, _ in pairs(t) do
        if type(k) ~= 'number' or k < 1 or math.floor(k) ~= k then
            return false
        end
        count = count + 1
        if k > max then max = k end
    end
    return count == max
end

local function encode_value(val, indent, current_indent)
    local t = type(val)
    if val == json.null then
        return 'null'
    elseif t == 'boolean' then
        return tostring(val)
    elseif t == 'number' then
        if val ~= val then return '"NaN"' end
        if val == math.huge  then return '"Infinity"'  end
        if val == -math.huge then return '"-Infinity"' end
        if math.floor(val) == val and math.abs(val) < 1e15 then
            return string.format('%d', val)
        end
        return string.format('%.14g', val)
    elseif t == 'string' then
        return encode_string(val)
    elseif t == 'table' then
        local next_indent = current_indent and (current_indent .. indent) or nil
        local sep  = indent and ('\n' .. (next_indent or '')) or ''
        local csep = indent and ('\n' .. (current_indent or '')) or ''
        local isep = indent and ' ' or ''

        if is_array(val) then
            if #val == 0 then return '[]' end
            local parts = {}
            for _, v in ipairs(val) do
                parts[#parts + 1] = sep .. encode_value(v, indent, next_indent)
            end
            return '[' .. table.concat(parts, ',') .. csep .. ']'
        else
            local keys = {}
            for k in pairs(val) do keys[#keys + 1] = k end
            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)
            if #keys == 0 then return '{}' end
            local parts = {}
            for _, k in ipairs(keys) do
                local ks = encode_string(tostring(k))
                parts[#parts + 1] = sep .. ks .. ':' .. isep ..
                    encode_value(val[k], indent, next_indent)
            end
            return '{' .. table.concat(parts, ',') .. csep .. '}'
        end
    else
        error('json.encode: unsupported type ' .. t)
    end
end

--- Encode a Lua value to a JSON string.
--- @param val  any  The value to encode.
--- @param opts table|nil  Optional settings: { indent = "  " } for pretty print.
--- @return string
function json.encode(val, opts)
    opts = opts or {}
    local indent = opts.indent  -- e.g. "  " or "\t"
    return encode_value(val, indent, indent and '' or nil)
end

-- ─── Decoder ────────────────────────────────────────────────────────────────

local function make_scanner(s)
    local pos = 1

    local function peek() return s:sub(pos, pos) end

    local function skip_ws()
        while pos <= #s and s:sub(pos, pos):match('%s') do pos = pos + 1 end
    end

    local function expect(c)
        skip_ws()
        if s:sub(pos, pos) ~= c then
            error(string.format('json.decode: expected %q got %q at pos %d',
                c, s:sub(pos, pos), pos))
        end
        pos = pos + 1
    end

    local decode_value  -- forward declaration

    local function decode_string()
        expect('"')
        local buf = {}
        while pos <= #s do
            local c = s:sub(pos, pos)
            if c == '"' then
                pos = pos + 1
                return table.concat(buf)
            elseif c == '\\' then
                pos = pos + 1
                local esc = s:sub(pos, pos)
                pos = pos + 1
                if     esc == '"'  then buf[#buf+1] = '"'
                elseif esc == '\\' then buf[#buf+1] = '\\'
                elseif esc == '/'  then buf[#buf+1] = '/'
                elseif esc == 'b'  then buf[#buf+1] = '\b'
                elseif esc == 'f'  then buf[#buf+1] = '\f'
                elseif esc == 'n'  then buf[#buf+1] = '\n'
                elseif esc == 'r'  then buf[#buf+1] = '\r'
                elseif esc == 't'  then buf[#buf+1] = '\t'
                elseif esc == 'u'  then
                    local hex = s:sub(pos, pos + 3)
                    pos = pos + 4
                    local cp = tonumber(hex, 16)
                    if not cp then error('json.decode: invalid \\u escape') end
                    -- Basic BMP: encode as UTF-8
                    if cp < 0x80 then
                        buf[#buf+1] = string.char(cp)
                    elseif cp < 0x800 then
                        buf[#buf+1] = string.char(0xC0 + math.floor(cp/64),
                                                   0x80 + (cp % 64))
                    else
                        buf[#buf+1] = string.char(0xE0 + math.floor(cp/4096),
                                                   0x80 + math.floor((cp%4096)/64),
                                                   0x80 + (cp%64))
                    end
                else
                    error('json.decode: unknown escape \\' .. esc)
                end
            else
                buf[#buf+1] = c
                pos = pos + 1
            end
        end
        error('json.decode: unterminated string')
    end

    local function decode_number()
        skip_ws()
        local num_str = s:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
        if not num_str then
            error('json.decode: invalid number at pos ' .. pos)
        end
        pos = pos + #num_str
        return tonumber(num_str)
    end

    local function decode_array()
        expect('[')
        skip_ws()
        local arr = {}
        if s:sub(pos, pos) == ']' then
            pos = pos + 1
            return arr
        end
        while true do
            arr[#arr + 1] = decode_value()
            skip_ws()
            local c = s:sub(pos, pos)
            if c == ']' then pos = pos + 1; break
            elseif c == ',' then pos = pos + 1
            else error('json.decode: expected , or ] at pos ' .. pos) end
        end
        return arr
    end

    local function decode_object()
        expect('{')
        skip_ws()
        local obj = {}
        if s:sub(pos, pos) == '}' then
            pos = pos + 1
            return obj
        end
        while true do
            skip_ws()
            local key = decode_string()
            skip_ws()
            expect(':')
            obj[key] = decode_value()
            skip_ws()
            local c = s:sub(pos, pos)
            if c == '}' then pos = pos + 1; break
            elseif c == ',' then pos = pos + 1
            else error('json.decode: expected , or } at pos ' .. pos) end
        end
        return obj
    end

    decode_value = function()
        skip_ws()
        local c = s:sub(pos, pos)
        if c == '"' then
            return decode_string()
        elseif c == '{' then
            return decode_object()
        elseif c == '[' then
            return decode_array()
        elseif c == 't' then
            if s:sub(pos, pos+3) == 'true' then pos=pos+4; return true end
            error('json.decode: invalid token at pos ' .. pos)
        elseif c == 'f' then
            if s:sub(pos, pos+4) == 'false' then pos=pos+5; return false end
            error('json.decode: invalid token at pos ' .. pos)
        elseif c == 'n' then
            if s:sub(pos, pos+3) == 'null' then pos=pos+4; return json.null end
            error('json.decode: invalid token at pos ' .. pos)
        elseif c:match('[%-0-9]') then
            return decode_number()
        else
            error('json.decode: unexpected character ' .. c .. ' at pos ' .. pos)
        end
    end

    return decode_value, skip_ws, function() return pos end
end

--- Decode a JSON string into a Lua value.
--- @param s string  The JSON text to decode.
--- @return any
function json.decode(s)
    assert(type(s) == 'string', 'json.decode expects a string')
    local decode_value, skip_ws, get_pos = make_scanner(s)
    local val = decode_value()
    skip_ws()
    local pos = get_pos()
    if pos <= #s then
        error(string.format('json.decode: trailing garbage at pos %d', pos))
    end
    return val
end

return json
