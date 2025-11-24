return function(totalSeconds)
    totalSeconds = tonumber(totalSeconds) or 0
    local negative = totalSeconds < 0
    totalSeconds = math.abs(totalSeconds)

    -- round to nearest second
    totalSeconds = math.floor(totalSeconds + 0.5)

    local patternValues = {
        y = 31540000, -- years
        o = 2628000,  -- months
        w = 604800,   -- weeks
        d = 86400,    -- days
        h = 3600,     -- hours
        m = 60,       -- minutes
        s = 1,        -- seconds
    }

    local order = {"y","o","w","d","h","m","s"}
    local parts = {}

    for _, unit in ipairs(order) do
        local value = patternValues[unit]
        if totalSeconds >= value then
            local amount = math.floor(totalSeconds / value)
            totalSeconds = totalSeconds - amount * value
            table.insert(parts, tostring(amount) .. unit)
        end
    end

    if #parts == 0 then
        return (negative and "-" or "") .. "0s"
    end

    local result = table.concat(parts)
    if negative then
        result = "-" .. result
    end
    return result
end