local IS_PRE_CATACLYSM = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) or (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) or (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)

local GetTrackingInfo = C_Minimap.GetTrackingInfo
if (not IS_PRE_CATACLYSM) then
    GetTrackingInfo = function(spellIndex)
        local trackingInfo = C_Minimap.GetTrackingInfo(spellIndex)
        name = trackingInfo.name
        textureFileID = trackingInfo.texture
        active = trackingInfo.active
        return name, textureFileID, active
    end
end

function GetTrackingInfoByName(trackingName)
    for i = 1, C_Minimap.GetNumTrackingTypes() do
        local name, textureFileID, active = GetTrackingInfo(i)
        if (name == trackingName) then
            return i, textureFileID, active
        end
    end
    return nil
end