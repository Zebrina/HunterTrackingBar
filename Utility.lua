function IsPlayerHunter()
    return select(2, UnitClass("player")) == "HUNTER";
end

function GetTrackingInfoByName(trackingName)
    for i = 1, C_Minimap.GetNumTrackingTypes() do
        local name, texture, active = C_Minimap.GetTrackingInfo(i);
        if (name == trackingName) then
            return i, texture, active;
        end
    end
    return nil;
end