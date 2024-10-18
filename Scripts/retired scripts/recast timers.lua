function RecastTimes()
    local ability_id = 4
    local recast_functions = {
        ["GetRecastTimeElapsed"] = GetRecastTimeElapsed(ability_id),
        ["GetRealRecastTimeElapsed"] = GetRealRecastTimeElapsed(ability_id),
        ["GetRecastTime"] = GetRecastTime(ability_id),
        ["GetRealRecastTime"] = GetRealRecastTime(ability_id),
        ["GetSpellCooldown"] = GetSpellCooldown(ability_id),
        ["GetRealSpellCooldown"] = GetRealSpellCooldown(ability_id),
        ["GetSpellCooldownInt"] = GetSpellCooldownInt(ability_id)
    }
    
    for name, value in pairs(recast_functions) do
        yield("/e " .. name .. ": " .. tostring(value))
    end
end

RecastTimes()
