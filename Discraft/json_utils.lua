-- JSON util function
local json = {}

function json.encode(data)
    return textutils.serialiseJSON(data)
end

function json.decode(data)
    return textutils.unserialiseJSON(data) or {}
end

return json