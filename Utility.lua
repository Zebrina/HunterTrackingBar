function IsPlayerHunter()
    return select(2, UnitClass("player")) == "HUNTER";
end

function GetTrackingInfoByName(trackingName)
    for i = 1, GetNumTrackingTypes() do
        local name, texture, active = GetTrackingInfo(i);
        if (name == trackingName) then
            return i, texture, active;
        end
    end
    return nil;
end