HUNTER_TRACKING_BAR_SYSTEM = 437898938 -- CRC32("Hunter Tracking Bar")

local HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_TRACK_PETS = "Show Track Pets"
local HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_HERBS = "Show Find Herbs"
local HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_MINERALS = "Show Find Minerals"
local HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_FISH = "Show Find Fish"

local Setting_ShowTrackPets = 100
local Setting_ShowFindHerbs = 101
local Setting_ShowFindMinerals = 102
local Setting_ShowFindFish = 103

local SettingDisplayInfo = {
	-- Orientation
	{
		setting = Enum.EditModeActionBarSetting.Orientation,
		name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION,
		type = Enum.EditModeSettingDisplayType.Dropdown,
		options =
		{
			{value = Enum.ActionBarOrientation.Horizontal, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL},
			{value = Enum.ActionBarOrientation.Vertical, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL},
		},
	},

	-- Num Rows/Columns
	{
		setting = Enum.EditModeActionBarSetting.NumRows,
		name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
		altName = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
		type = Enum.EditModeSettingDisplayType.Slider,
		minValue = 1,
		maxValue = 4,
	},

	-- Icon Size
	{
		setting = Enum.EditModeActionBarSetting.IconSize,
		name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
		type = Enum.EditModeSettingDisplayType.Slider,
		minValue = 50,
		maxValue = 200,
		stepSize = 10,
		ConvertValue = function(self, value, forDisplay)
			-- ConvertValueDefault
			if (forDisplay) then
				return self:ClampValue((value * self.stepSize) + self.minValue)
			else
				return (value - self.minValue) / self.stepSize
			end
		end,
		formatter = function(value)
			-- ShowAsPercentage
			local roundToNearestInteger = true
			return FormatPercentage(value / 100, roundToNearestInteger)
		end,
	},

	-- Icon Padding
	{
		setting = Enum.EditModeActionBarSetting.IconPadding,
		name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_PADDING,
		type = Enum.EditModeSettingDisplayType.Slider,
		minValue = 2,
		maxValue = 10,
		stepSize = 1,
	},

	-- Visible Setting
	{
		setting = Enum.EditModeActionBarSetting.VisibleSetting,
		name = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING,
		type = Enum.EditModeSettingDisplayType.Dropdown,
		options = 
		{
			{value = Enum.ActionBarVisibleSetting.Always, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS},
			{value = Enum.ActionBarVisibleSetting.InCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT},
			{value = Enum.ActionBarVisibleSetting.OutOfCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT},
			{value = Enum.ActionBarVisibleSetting.Hidden, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_HIDDEN},
		},
	},

    --[[

    -- Show Track Pets
    {
        setting = Setting_ShowTrackPets,
        name = HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_TRACK_PETS,
        type = Enum.EditModeSettingDisplayType.Checkbox,
    },

    -- Show Find Herbs
    {
        setting = Setting_ShowFindHerbs,
        name = HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_HERBS,
        type = Enum.EditModeSettingDisplayType.Checkbox,
    },

    -- Show Find Minerals
    {
        setting = Setting_ShowFindMinerals,
        name = HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_MINERALS,
        type = Enum.EditModeSettingDisplayType.Checkbox,
    },

    -- Show Find Fish
    {
        setting = Setting_ShowFindFish,
        name = HUD_EDIT_MODE_SETTING_HUNTER_TRACKING_BAR_SHOW_FIND_FISH,
        type = Enum.EditModeSettingDisplayType.Checkbox,
    },

    ]]
}
EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[HUNTER_TRACKING_BAR_SYSTEM] = SettingDisplayInfo

-- Source: Blizzard_EditMode\Mainline\EditModeSettingDisplayInfo.lua:721
EditModeSettingDisplayInfoManager.displayInfoMap[HUNTER_TRACKING_BAR_SYSTEM] = {}
for _, settingDisplayInfo in ipairs(SettingDisplayInfo) do
	-- Can't access metatable directly so steal it from some other system.
	local mt = getmetatable(EditModeSettingDisplayInfoManager.displayInfoMap[Enum.EditModeSystem.ActionBar][settingDisplayInfo.setting])
	setmetatable(settingDisplayInfo, mt)
	-- And then add it to the map.
	EditModeSettingDisplayInfoManager.displayInfoMap[HUNTER_TRACKING_BAR_SYSTEM][settingDisplayInfo.setting] = settingDisplayInfo
end

local function GetDefaultAnchorInfo(index)
	return {
		point = "BOTTOMLEFT",
		relativeTo = "PetActionBar",
		relativePoint = "TOPLEFT",
		offsetX = 0,
		offsetY = 4,
	}
end

EDIT_MODE_MODERN_SYSTEM_MAP[HUNTER_TRACKING_BAR_SYSTEM] = {
	settings = {
		[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
		[Enum.EditModeActionBarSetting.NumRows] = 1,
		[Enum.EditModeActionBarSetting.IconSize] = 5,
		[Enum.EditModeActionBarSetting.IconPadding] = 2,
		[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
        --[[
		[Setting_ShowTrackPets] = 0,
		[Setting_ShowFindHerbs] = 0,
		[Setting_ShowFindMinerals] = 0,
		[Setting_ShowFindFish] = 0,
        ]]
	},
	anchorInfo = GetDefaultAnchorInfo(),
}

local SystemInfoPreset = {
	system = HUNTER_TRACKING_BAR_SYSTEM,
	settings = {
		{
			setting = Enum.EditModeActionBarSetting.Orientation,
			value = Enum.ActionBarOrientation.Horizontal,
		},
		{
			setting = Enum.EditModeActionBarSetting.NumRows,
			value = 1,
		},
		{
			setting = Enum.EditModeActionBarSetting.IconSize,
			value = 5,
		},
		{
			setting = Enum.EditModeActionBarSetting.IconPadding,
			value = 2,
		},
		{
			setting = Enum.EditModeActionBarSetting.VisibleSetting,
			value = Enum.ActionBarVisibleSetting.Always,
		},
        --[[
		{
			setting = Setting_ShowTrackPets,
			value = 0,
		},
        ]]
	},
	anchorInfo = GetDefaultAnchorInfo(),
	isInDefaultPosition = true,
}

do

    -- TODO
    --SystemInfoPreset.settings[]
end

--EDIT_MODE_MODERN_SYSTEM_MAP[HUNTER_TRACKING_BAR_SYSTEM]

--[[
local SettingMapPreset = {
	[Enum.EditModeActionBarSetting.Orientation] = {
		setting = Enum.EditModeActionBarSetting.Orientation,
		value = Enum.ActionBarOrientation.Horizontal,
	},
	[Enum.EditModeActionBarSetting.NumRows] = {
		setting = Enum.EditModeActionBarSetting.NumRows,
		value = 1,
	},
	[Enum.EditModeActionBarSetting.IconSize] = {
		setting = Enum.EditModeActionBarSetting.IconSize, -- 3
		value = 5,
	},
	[Enum.EditModeActionBarSetting.IconPadding] = {
		setting = Enum.EditModeActionBarSetting.IconPadding, -- 4
		value = 2,
	},
	[Enum.EditModeActionBarSetting.VisibleSettin] = {
		setting = Enum.EditModeActionBarSetting.VisibleSetting, -- 5
		value = "Always",
	},
}
]]

--local PLAYER_CLASS = select(2, UnitClass("player"))

-- This is more reliable than doing frame:IsVisible() 
-- or frame:IsShown() when edit mode is involved.
local function ShouldShowBar(frame)
    if (frame == PetActionBar) then
        return PetHasActionBar()
    elseif (frame == StanceBar) then
        return (GetNumShapeshiftForms() ~= 0) or HasTempShapeshiftActionBar()
    elseif (frame == PossessActionBar) then
        return IsPossessBarVisible()
    elseif (frame == MainMenuBarVehicleLeaveButton) then
        return CanExitVehicle()
    end
    return frame:IsVisible()
end

function HunterTrackingBarMixin:EditMode_OnLoad()
    self.system = HUNTER_TRACKING_BAR_SYSTEM--Enum.EditModeSystem.ActionBar

    -- Modified ActionBarMixin:ActionBar_OnLoad()
    -- Source: Blizzard_ActionBar\Mainline\ActionBar.lua:3

    self.numButtonsShowable = #self.Buttons
    self.minButtonPadding = 2
    self.buttonPadding = self.minButtonPadding
    self.actionButtons = {}
    self.shownButtonContainers = {}

    local actionBarName = self:GetName()

    -- Create action buttons
    for i = 1, #self.Buttons do
        local buttonContainer = CreateFrame("Frame", actionBarName.."ButtonContainer"..i, self, "ActionBarButtonContainerTemplate", i)

        local actionButton = self.Buttons[i]

        actionButton:SetParent(buttonContainer)
        actionButton:SetPoint("CENTER")
        actionButton.bar = self
        actionButton.container = buttonContainer
        actionButton.index = i

        actionButton.commandName = "BINDING_NAME_CLICK "..actionButton:GetName()..":LeftButton"
        --actionButton.commandName = "HUNTERTRACKINGBUTTON"..i

        table.insert(self.actionButtons, actionButton)

        buttonContainer:SetSize(actionButton:GetWidth(), actionButton:GetHeight())
    end

    self:UpdateShownButtons()
    self:UpdateGridLayout()

    -- End

    -- Modified EditModeActionBarMixin:EditModeActionBar_OnLoad()
    -- Source: Blizzard_ActionBar\Mainline\ActionBar.lua:256

    self:OnSystemLoad()

    self.isShownExternal = self:IsShown()
    
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    -- End

    hooksecurefunc(EditModeManagerFrame, "UpdateLayoutInfo", function(layoutInfo)
        self:OnUpdateLayoutInfo(layoutInfo)
    end)

    local updateLayoutInfo = function()
        if (self.systemInfo and self.systemInfo.isInDefaultPosition) then
            self:UpdatePositionAnchorInfo()
        end
    end

    PossessActionBar:HookScript("OnShow", updateLayoutInfo)
    PossessActionBar:HookScript("OnHide", updateLayoutInfo)
    MainMenuBarVehicleLeaveButton:HookScript("OnShow", updateLayoutInfo)
    MainMenuBarVehicleLeaveButton:HookScript("OnHide", updateLayoutInfo)
    PetActionBar:HookScript("OnShow", updateLayoutInfo)
    PetActionBar:HookScript("OnHide", updateLayoutInfo)
    StanceBar:HookScript("OnShow", updateLayoutInfo)
    StanceBar:HookScript("OnHide", updateLayoutInfo)
    MultiBarBottomRight:HookScript("OnShow", updateLayoutInfo)
    MultiBarBottomRight:HookScript("OnHide", updateLayoutInfo)
    MultiBarBottomLeft:HookScript("OnShow", updateLayoutInfo)
    MultiBarBottomLeft:HookScript("OnHide", updateLayoutInfo)

    hooksecurefunc(EditModeManagerFrame, "RevertSystemChanges", function(systemFrame)
        self:OnRevertSystemChanges(systemFrame)
    end)

    local secureVisibilityHandler = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
    secureVisibilityHandler:SetFrameRef("HunterTrackingBarFrame", self)
    secureVisibilityHandler:SetAttribute("_onstate-visibility", [[
        local HunterTrackingBarFrame = self:GetFrameRef("HunterTrackingBarFrame")
        if (newstate == "hide") then
            HunterTrackingBarFrame:Hide()
        else
            HunterTrackingBarFrame:Show()
        end
    ]])
    --RegisterAttributeDriver(secureVisibilityHandler, "state-visibility", "[vehicleui][petbattle] hide; show")

    local securePositionHandler = CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")
    securePositionHandler:SetFrameRef("HunterTrackingBarFrame", self)
    securePositionHandler:SetFrameRef("PossessActionBar", PossessActionBar)
    securePositionHandler:SetFrameRef("MainMenuBarVehicleLeaveButton", MainMenuBarVehicleLeaveButton)
    securePositionHandler:SetFrameRef("PetActionBar", PetActionBar)
    securePositionHandler:SetFrameRef("StanceBar", StanceBar)
    securePositionHandler:SetFrameRef("MultiBarBottomRight", MultiBarBottomRight)
    securePositionHandler:SetFrameRef("MultiBarBottomLeft", MultiBarBottomLeft)
    securePositionHandler:SetFrameRef("MainMenuBar", MainMenuBar)
    securePositionHandler:SetAttribute("_onstate-position", [[
        if (newstate == "nocombat") then
            return
        end

        local ref
        local placeAbove = true

        if (newstate == "possessbar") then
            ref = self:GetFrameRef("PossessActionBar")
            placeAbove = false
        elseif (newstate == "vehicleexitbutton") then
            ref = self:GetFrameRef("MainMenuBarVehicleLeaveButton")
            placeAbove = false
        elseif (newstate == "petbar") then
            ref = self:GetFrameRef("PetActionBar")
        elseif (newstate == "stancebar") then
            ref = self:GetFrameRef("StanceBar")
        else
            local MultiBarBottomRight = self:GetFrameRef("MultiBarBottomRight")
            if (MultiBarBottomRight:IsVisible()) then
                ref = MultiBarBottomRight
            else
                local MultiBarBottomLeft = self:GetFrameRef("MultiBarBottomLeft")
                if (MultiBarBottomLeft:IsVisible()) then
                    ref = MultiBarBottomLeft
                else
                    ref = self:GetFrameRef("MainMenuBar")
                end
            end
        end

        local point, relativeTo, relativePoint, offsetX, offsetY = ref:GetPoint()

        local HunterTrackingBarFrame = self:GetFrameRef("HunterTrackingBarFrame")
        HunterTrackingBarFrame:ClearAllPoints()
        if (placeAbove) then
            HunterTrackingBarFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY + ref:GetHeight() + 4)
        else
            HunterTrackingBarFrame:SetPoint(point, relativeTo, relativePoint, offsetX + ref:GetWidth() + 8, offsetY)
        end
    ]])
    self.securePositionHandler = securePositionHandler
    self:EnableSecurePositionHandler(GetNumShapeshiftForms() == 0)

    -- Not needed.
    self:SetScript("OnUpdate", nil)
end

function HunterTrackingBarMixin:GetDefaultPositionAnchorInfo()
	local relativeTo, leftAligned

    local shouldShowStanceBar = ShouldShowBar(StanceBar)
    local shouldShowPetActionBar = ShouldShowBar(PetActionBar)

    if (shouldShowStanceBar) then
        relativeTo = StanceBar
        leftAligned = true
    elseif (ShouldShowBar(PossessActionBar)) then
        relativeTo = PossessActionBar
        leftAligned = true
    elseif (ShouldShowBar(MainMenuBarVehicleLeaveButton)) then
        relativeTo = MainMenuBarVehicleLeaveButton
        leftAligned = true
    elseif (shouldShowPetActionBar) then
        relativeTo = PetActionBar
    --[[
    elseif (shouldShowStanceBar) then
        relativeTo = StanceBar
    ]]
    elseif (ShouldShowBar(MultiBarBottomRight)) then
        relativeTo = MultiBarBottomRight
    elseif (ShouldShowBar(MultiBarBottomLeft)) then
        relativeTo = MultiBarBottomLeft
    else
        relativeTo = MainMenuBar
    end

	if (not leftAligned) then
		return {
			point = "BOTTOMLEFT",
			relativeTo = relativeTo:GetName(),
			relativePoint = "TOPLEFT",
			offsetX = 0,
			offsetY = 4,
		}
	else
		return {
			point = "BOTTOMLEFT",
			relativeTo = relativeTo:GetName(),
			relativePoint = "BOTTOMRIGHT",
			offsetX = 8,
			offsetY = 0,
		}
	end
end

function HunterTrackingBarMixin:GetSavedSystemInfo()
    return HunterTrackingBarSavedSystemInfo or CopyTable(SystemInfoPreset)
end

function HunterTrackingBarMixin:EnableSecurePositionHandler(enable)
	if (enable) then
		RegisterAttributeDriver(self.securePositionHandler, "state-position",
			"[combat,possessbar] possessbar;"..
			"[combat,canexitvehicle] vehicleexitbutton;"..
			"[combat,pet] petbar;"..
			"[combat,stance] stancebar;"..
			"[combat] combat; nocombat"
		)
	else
		UnregisterAttributeDriver(self.securePositionHandler, "state-position")
	end
end

function HunterTrackingBarMixin:SaveLayoutInfo()
	HunterTrackingBarSavedSystemInfo = CopyTable(self.savedSystemInfo)
end

function HunterTrackingBarMixin:UpdatePositionAnchorInfo()
	if (InCombatLockdown()) then
		self.requireLayoutInfoUpdate = true
		return
	end
	self.requireLayoutInfoUpdate = nil

	self:ClearAllPoints()
	local anchorInfo = self.systemInfo.isInDefaultPosition and self:GetDefaultPositionAnchorInfo() or self.savedSystemInfo.anchorInfo
	self:SetPoint(anchorInfo.point, anchorInfo.relativeTo, anchorInfo.relativePoint, anchorInfo.offsetX, anchorInfo.offsetY)
end

-- EditModeManagerFrame hook
function HunterTrackingBarMixin:OnUpdateLayoutInfo(layoutInfo)
	if (self:IsInitialized()) then
		self:UpdatePositionAnchorInfo()
	else
		self.requireLayoutInfoUpdate = true
	end
end

-- EditModeManagerFrame hook
function HunterTrackingBarMixin:OnRevertSystemChanges(systemFrame)
	if (systemFrame ~= self) then
		return
	end

	print("OnRevertSystemChanges")

	self.systemInfo.anchorInfo = CopyTable(self.savedSystemInfo.anchorInfo)
	self.systemInfo.anchorInfo2 = nil
	self.systemInfo.isInDefaultPosition = self.savedSystemInfo.isInDefaultPosition
	self:BreakSnappedFrames()
	self:ApplySystemAnchor()
	EditModeSystemSettingsDialog:UpdateDialog(self)
	self:SetHasActiveChanges(false)
end

-- Override EditModeActionBarMixin
--[[
function EditModeActionBarMixin:UpdateVisibility()
    -- Do nothing.
end
]]

-- Override EditModeSystemMixin
function EditModeSystemMixin:ShouldResetSettingsDialogAnchors(oldSelectedSystemFrame)
	return not oldSelectedSystemFrame or (oldSelectedSystemFrame.system ~= self.system and oldSelectedSystemFrame.system ~= Enum.EditModeSystem.ActionBar)
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:UpdateDisplayInfoOptions(displayInfo)
	print("UpdateDisplayInfoOptions ->", displayInfo.setting)
	do
		return EditModeSystemMixin.UpdateDisplayInfoOptions(self, displayInfo)
	end

	if (displayInfo.setting == Enum.EditModeActionBarSetting.Orientation) then
		print("Orientation")
	elseif (displayInfo.setting == Enum.EditModeActionBarSetting.NumRows) then
		print("NumRows")
	elseif (displayInfo.setting == Enum.EditModeActionBarSetting.IconSize) then
		print("IconSize")
	elseif (displayInfo.setting == Enum.EditModeActionBarSetting.IconPadding) then
		print("IconPadding")
	elseif (displayInfo.setting == Enum.EditModeActionBarSetting.VisibleSetting) then
		print("VisibleSetting")
	end

	return displayInfo
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:ShouldShowSetting(setting)
	print("ShouldShowSetting ->", setting)
	return EditModeSystemMixin.ShouldShowSetting(self, setting)
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:AddExtraButtons(extraButtonPool)
	EditModeSystemMixin.AddExtraButtons(self, extraButtonPool)

	local quickKeybindModeButton = extraButtonPool:Acquire()
	quickKeybindModeButton.layoutIndex = 4
	quickKeybindModeButton:SetText(QUICK_KEYBIND_MODE)
	quickKeybindModeButton:SetOnClickHandler(EnterQuickKeybindMode)
	quickKeybindModeButton:Show()

	return true
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:OnDragStop()
	if self:CanBeMoved() then
		EditModeManagerFrame:ClearSnapPreviewFrame()
		self:StopMovingOrSizing()
		self.isDragging = false

		if EditModeManagerFrame:IsSnapEnabled() then
			EditModeMagnetismManager:ApplyMagnetism(self)
		end

		self.systemInfo.isInDefaultPosition = false
		self:SetHasActiveChanges(true)

		EditModeSystemSettingsDialog:UpdateDialog(self)

		EditModeManagerFrame:OnEditModeSystemAnchorChanged()
	end
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:PrepareForSave()
	self:UpdateSystem(CopyTable(self.systemInfo))
	self:SaveLayoutInfo()
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:ResetToDefaultPosition()
	self.systemInfo.anchorInfo = self:GetDefaultPositionAnchorInfo()
	self.systemInfo.anchorInfo2 = nil
	self.systemInfo.isInDefaultPosition = true
	self:BreakSnappedFrames()
	self:ApplySystemAnchor()
	EditModeSystemSettingsDialog:UpdateDialog(self)
	self:SetHasActiveChanges(true)
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:OnEditModeEnter()
	self:EnableSecurePositionHandler(false)
	EditModeActionBarSystemMixin.OnEditModeEnter(self)
end

-- Override EditModeSystemMixin
function HunterTrackingBarMixin:OnEditModeExit()
	EditModeSystemMixin.OnEditModeExit(self)
	self:EnableSecurePositionHandler(self.systemInfo.isInDefaultPosition and GetNumShapeshiftForms() == 0)
	C_Timer.NewTimer(0.5, function() self:UpdatePositionAnchorInfo() end)
end