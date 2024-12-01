local IS_CLASSIC = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE)

local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

HUNTERTRACKINGBAR_YPOS = 89
HUNTERTRACKINGBAR_XPOS = 236

HUNTER_TRACKING_ACTIVE_TEXTURE = "Interface\\Icons\\Spell_Nature_WispSplode"

HunterTrackingBarMixin = {}

function HunterTrackingBarMixin:ForEachButton(callback)
    for i, button in ipairs(self.Buttons) do
        callback(button, i)
    end
end

function HunterTrackingBarMixin:OnLoad()
	--if (IsAddOnLoaded("FastEquipMenu")) then
	--	self:SetPoint("BOTTOMLEFT", "InventoryEquipmentBar", "TOPLEFT", 75, 5.5)
	if (IS_CLASSIC) then
		self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 3)
	else
		if (IsAddOnLoaded("ClassicUI")) then
			self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 5.5)
		else
			self:SetPoint("BOTTOMLEFT", "PetActionBar", "TOPLEFT", 28, 5.5)
		end
	end
    
    for i = 2, getn(self.Buttons) do
        local button = self.Buttons[i]
        --button:ClearAllPoints()
        button:SetPoint("LEFT", self.Buttons[i - 1], "RIGHT", 8, 0)
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB")
	--self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
end

function HunterTrackingBarMixin:OnEvent(event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
		self:UpdateButtonLayout()
		self:Update()
		if (IsPlayerHunter()) then
			ShowHunterTrackingBar()
		end
    elseif (event == "MINIMAP_UPDATE_TRACKING") then
        self:Update()
		if (IS_CLASSIC) then
			self:UpdateCooldowns()
		end
	elseif (event == "PLAYER_TARGET_CHANGED") then
        self:Update()
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		self:UpdateButtonLayout()
    end
end

function HunterTrackingBarMixin:OnUpdate(elapsed)
	if (self.updateCooldowns) then
		self:Update()
	end
end

function HunterTrackingBarMixin:OnShow()
end

function HunterTrackingBarMixin:OnHide()
end

function HunterTrackingBarMixin:Update()
    self:ForEachButton(function(button, i)
		button:Update()
	end)
    --[[
	if (true) then
        return
    end
	local petActionButton, petActionIcon
	for i=1, 8, 1 do
		local buttonName = "HunterTrackingButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = petActionButton.icon or _G[buttonName.."Icon"]
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

        if (isActive) then
            -- spell_nature_wispsplode
            petActionIcon:SetTexture(HUNTER_TRACKING_ACTIVE_TEXTURE)
            petActionButton:SetChecked(true)
        else
            petActionIcon:SetTexture(select(3, GetSpellInfo(self.spellID)))
            petActionButton:SetChecked(false)
        end
		if (texture) then
			if (GetPetActionSlotUsable(i)) then
				petActionIcon:SetVertexColor(1, 1, 1)
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
			end
			petActionIcon:Show()
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
		else
			petActionIcon:Hide()
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
		end
	end
	]]
end

function HunterTrackingBarMixin:UpdateCooldowns()
	self.updateCooldowns = C_Timer.NewTimer(1.5, function()
		self.updateCooldowns = nil
	end)

    self:ForEachButton(function(button, i)
        local start, duration, enable = GetSpellCooldown(button.spellID)
		CooldownFrame_Set(button.cooldown, start, duration, enable)

		if (GameTooltip:GetOwner() == button) then
			HunterTrackingButton_OnEnter(button)
		end
    end)
end

function HunterTrackingBarMixin:UpdateButtonLayout()
	local previousButton
	self:ForEachButton(function(button, i)
		if (button:ShouldShow()) then
			local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint()
			if (previousButton == nil) then
				point = "BOTTOMLEFT"
				relativeTo = self
				relativePoint = "BOTTOMLEFT"
				offsetX = 36
				offsetY = 2
			else
				point = "LEFT"
				relativeTo = previousButton
				relativePoint = "RIGHT"
				offsetX = 8
				offsetY = 0
			end

			previousButton = button

			button:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
			button:Show()
		else
			button:Hide()
		end
	end)
end

function ShowHunterTrackingBar(doNotSlide)
    --HunterTrackingBarFrame:SetPoint("LEFT", PetActionBarFrame, "RIGHT", 50, 0)
    HunterTrackingBarFrame:Show()
	--[[
    if (true) then
        return
    end
	if (not HunterTrackingBarFrame:IsShown()) then
		if (MainMenuBar.busy or UnitHasVehicleUI("player") or doNotSlide) then
			HunterTrackingBarFrame:SetPoint("TOPLEFT", HunterTrackingBarFrame:GetParent(), "BOTTOMLEFT", HUNTERTRACKINGBAR_XPOS, HUNTERTRACKINGBAR_YPOS)
			HunterTrackingBarFrame.state = "top"
			HunterTrackingBarFrame:Show()
		else
			HunterTrackingBarFrame:Show()
			HunterTrackingBarFrame.mode = "show"
		end
		UIParent_ManageFramePositions()
	end
	]]
end

function HideHunterTrackingBar()
	if (HunterTrackingBarFrame:IsShown()) then
		if (MainMenuBar.busy or UnitHasVehicleUI("player") ) then
			HunterTrackingBarFrame:SetPoint("TOPLEFT", HunterTrackingBarFrame:GetParent(), "BOTTOMLEFT", HUNTERTRACKINGBAR_XPOS, 0)
			HunterTrackingBarFrame.state = "bottom"
			HunterTrackingBarFrame:Hide()
		else
			HunterTrackingBarFrame.mode = "hide"
		end
	end
end

HunterTrackingButtonMixin = {}

function HunterTrackingButtonMixin:OnLoad()
    _G["BINDING_NAME_CLICK "..self:GetName()..":LeftButton"] = "Toggle "..self.trackingName

	self.HotKey:ClearAllPoints()
	self.HotKey:SetPoint("TOPLEFT", -2, -3)

	self:RegisterForClicks("AnyUp")
	self:RegisterEvent("UPDATE_BINDINGS")

	if (IS_CLASSIC) then
		self:SetAttribute("type", "spell")
		self:SetAttribute("spell", self.trackingName)
	else
		self:SetScript("OnClick", self.OnClick)
	end

    local cooldown = _G[self:GetName().."Cooldown"]
	cooldown:ClearAllPoints()
	cooldown:SetWidth(33)
	cooldown:SetHeight(33)
	cooldown:SetPoint("CENTER", self, "CENTER", -2, -1)

    self.setTexture = true
    self.setChecked = true

	self:UpdateHotkey()

    self.cooldown:SetSwipeColor(0, 0, 0)
end

function HunterTrackingButtonMixin:OnEvent(event, ...)
	if (event == "UPDATE_BINDINGS") then
		self:UpdateHotkey()
	end
end

function HunterTrackingButtonMixin:OnClick(button)
	local index, _, active = GetTrackingInfoByName(self.trackingName)
	if (index) then
		C_Minimap.SetTracking(index, not active)
	end
end

function HunterTrackingButtonMixin:OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	if (GameTooltip:SetSpellByID(self.spellID)) then
		self.UpdateTooltip = self.OnEnter
	else
		self.UpdateTooltip = nil
	end
end

function HunterTrackingButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function HunterTrackingButtonMixin:OnUpdate(elapsed)
end

function HunterTrackingButtonMixin:ShouldShow()
	if (self.noClassic and IS_CLASSIC) then
		return false
	end
	return IsSpellKnown(self.spellID)
end

function HunterTrackingButtonMixin:UpdateIcon()
	local _, texture, active = GetTrackingInfoByName(self.trackingName)

	if (self.setTexture and active) then
		self.icon:SetTexture(HUNTER_TRACKING_ACTIVE_TEXTURE)
	else
		self.icon:SetTexture(texture)
	end
	self:SetChecked(self.setChecked and active)

	local trackingType = self.trackingType
	if (trackingType) then
		if (not active and UnitCanAttack("player", "target") and UnitCreatureType("target") == trackingType) and not UnitIsDead("target") then
			ActionButton_ShowOverlayGlow(self)
		else
			ActionButton_HideOverlayGlow(self)
		end
	end
end

function HunterTrackingButtonMixin:UpdateHotkey()
	local binding = GetBindingText(GetBindingKey("CLICK "..self:GetName()..":LeftButton"), true)
	local hotkey = self.HotKey
	if (binding == "") then
		hotkey:Hide()
	else
		hotkey:SetText(binding)
		hotkey:Show()
	end
end

function HunterTrackingButtonMixin:Update()
    self:UpdateIcon()
    self:UpdateHotkey()
end