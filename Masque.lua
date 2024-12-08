local MasqueLib = LibStub("Masque", true) or (LibMasque and LibMasque("Button"))
if (MasqueLib == nil) then
    return
end

local MasqueGroup = MasqueLib:Group("Hunter Tracking Bar", "Action Buttons", true)
if (MasqueGroup) then
    for _, button in ipairs(HunterTrackingBarFrame.Buttons) do
        MasqueGroup:AddButton(button)
    end
end