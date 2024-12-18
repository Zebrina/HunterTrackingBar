local IS_RETAIL = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local IS_WRATH = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local IS_CATACLYSM = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
local IS_PRE_CATACLYSM = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) or (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) or IS_WRATH

local IsAddOnLoaded = _G.IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local GetSpellInfo = _G.GetSpellInfo or C_Spell.GetSpellInfo
if (IS_RETAIL) then
	-- Wrapper for GetSpellInfo to make it behave in retail as it does in classic.
	-- name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = GetSpellInfo(spellOrIndex, bookType)
	GetSpellInfo = function(spellOrIndex, bookType)
		local spellInfo = C_Spell.GetSpellInfo(spellOrIndex, bookType)
		if (spellInfo == nil) then
			return nil
		end
		return spellInfo.name, spellInfo.rank, spellInfo.iconID, spellInfo.castTime,
			   spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
	end
end

HUD_EDIT_MODE_HUNTER_TRACKING_BAR_LABEL = "Hunter Tracking Bar"

HUNTERTRACKINGBAR_YPOS = 89
HUNTERTRACKINGBAR_XPOS = 236

HUNTER_TRACKING_ACTIVE_TEXTURE = 136116 -- "Interface\\Icons\\Spell_Nature_WispSplode"

local IMPROVED_TRACKING_SPELLID = 52783

HunterTrackingBarMixin = {}

function HunterTrackingBarMixin:ForEachButton(callback)
    for index, button in ipairs(self.Buttons) do
        callback(button, index)
    end
end

function HunterTrackingBarMixin:OnLoad()
	HTB = self

	if (IS_RETAIL and not IsAddOnLoaded("ClassicUI")) then
		self:EditMode_OnLoad()

		--[[
		if (IsAddOnLoaded("ClassicUI")) then
			self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 5.5)
		else
			self:SetPoint("BOTTOMLEFT", "MultiBarBottomRight", "TOPLEFT", 28, 5.5 + 40)
		end
		]]
	else
		self:SetParent(MainMenuBar)

		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 3)
	
		for i = 2, #self.Buttons do
			local button = self.Buttons[i]
			--button:ClearAllPoints()
			button:SetPoint("LEFT", self.Buttons[i - 1], "RIGHT", 8, 0)
		end
	end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")

	if (not IS_PRE_CATACLYSM) then
		-- In cataclysm and later tracking types are learned at different levels.
		self:RegisterEvent("PLAYER_LEVEL_CHANGED")
	else
		self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		if (IS_WRATH) then
			-- For Improved Tracking talent.
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end
	end
end

function HunterTrackingBarMixin:OnEvent(event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		self:UpdateButtonLayout()
		self:Update()
		if (IS_RETAIL) then
			self:UpdateSystem(self:GetSavedSystemInfo())
			if (self.requireLayoutInfoUpdate) then
				C_Timer.NewTimer(0.5, function() self:UpdatePositionAnchorInfo() end)
			end
		end
    elseif (event == "MINIMAP_UPDATE_TRACKING") then
        self:Update()
		if (not IS_RETAIL) then
			self:UpdateCooldowns()
		end
	elseif (event == "PLAYER_LEVEL_CHANGED" or event == "LEARNED_SPELL_IN_TAB") then
		self:UpdateButtonLayout()
	elseif (event == "PLAYER_TARGET_CHANGED") then
        self:ForEachButton(function(button)
			button:UpdateImprovedTrackingTalent()
		end)
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (self.requireLayoutInfoUpdate) then
			self:UpdatePositionAnchorInfo()
		end
    end
end

function HunterTrackingBarMixin:OnUpdate(elapsed)
	if (self.updateCooldowns) then
		self:Update()
	end
end

function HunterTrackingBarMixin:Update()
    self:ForEachButton(function(button)
		button:Update()
	end)
end

function HunterTrackingBarMixin:UpdateCooldowns()
	self.updateCooldowns = C_Timer.NewTimer(1.5, function()
		self.updateCooldowns = nil
	end)

    self:ForEachButton(function(button)
        local start, duration, enable = GetSpellCooldown(button.spellID)
		CooldownFrame_Set(button.cooldown, start, duration, enable)

		if (GameTooltip:GetOwner() == button) then
			button:OnEnter()
		end
    end)
end

function HunterTrackingBarMixin:UpdateButtonLayout()
	if (IS_RETAIL) then
		self.actionButtons = {}

		self:ForEachButton(function(button)
			if (button:ShouldShow()) then
				table.insert(self.actionButtons, button)

				button:Show()
			else
				button:Hide()
			end
		end)

		self:UpdateShownButtons()
		self:UpdateGridLayout()
	else
		
-- TODO
--[[
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 3)
	
		for i = 2, #self.Buttons do
			local button = self.Buttons[i]
			--button:ClearAllPoints()
			button:SetPoint("LEFT", self.Buttons[i - 1], "RIGHT", 8, 0)
		end
		]]

		local previousButton
		self:ForEachButton(function(button)
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
	
	if (IS_RETAIL) then
		BaseActionButtonMixin.BaseActionButtonMixin_OnLoad(self)
		SmallActionButtonMixin.SmallActionButtonMixin_OnLoad(self)
		SmallActionButtonMixin.UpdateButtonArt(self)

		self.AutoCastOverlay.Corners:Hide()
	else
		self.SpellHighlightTexture:SetSize(34, 34)
		local normalTexture = self:GetNormalTexture()
		normalTexture:SetSize(54, 54)
		normalTexture:SetPoint("CENTER", 0, -1)
	end

	self.HotKey:ClearAllPoints()
	self.HotKey:SetPoint("TOPLEFT", -2, -3)
	self:UpdateHotkey()

	self:RegisterForClicks("AnyUp")
	self:RegisterEvent("UPDATE_BINDINGS")

	if (IS_PRE_CATACLYSM) then
		--self:SetAttribute("type", "spell")
		self:SetAttribute("spell", self.trackingName)
	else
		--self:SetScript("OnClick", self.OnClick)
	end
	
	if (not IS_RETAIL) then
		local cooldown = self.cooldown
		cooldown:SetSwipeColor(0, 0, 0)
		cooldown:ClearAllPoints()
		cooldown:SetWidth(29)
		cooldown:SetHeight(29)
		cooldown:SetPoint("CENTER", self, "CENTER")
	end
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
	self:SetTrackingActive(active)
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
	--[[
	if (self.retailOnly and not IS_RETAIL) then
		return false
	end

	if (self.shouldShow) then
		return self.shouldShow()
	end

	if (self.levelReqRetail and IS_RETAIL) then
		return UnitLevel("player") >= self.levelReqRetail
	end
	]]

	--return IsSpellKnown(self.spellID)
	return IsPlayerSpell(self.spellID)
end

-- Used by DragonFlight UI.
function HunterTrackingButtonMixin:HasAction()
	return self:ShouldShow()
end

function HunterTrackingButtonMixin:SetTrackingActive(active)
	--[[
	if (not IS_PRE_CATACLYSM) then
		if (IS_RETAIL) then
			self.AutoCastOverlay:ShowAutoCastEnabled(active)
			self.AutoCastOverlay:SetShown(active)
		else
			if (active) then
				AutoCastShine_AutoCastStart(self.AutoCastShine)
			else
				AutoCastShine_AutoCastStop(self.AutoCastShine)
			end
			self.AutoCastShine:SetShown(active)
		end
	else
		if (active) then
			self.icon:SetTexture(HUNTER_TRACKING_ACTIVE_TEXTURE)
		else
			self.icon:SetTexture(self.altIconTexture or self.iconTexture)
		end
	end
	]]
	--self:SetChecked(false)
	self:SetChecked(active)
end

function HunterTrackingButtonMixin:UpdateIcon()
	local _, texture, active = GetTrackingInfoByName(self.trackingName)
	
	if (not self.iconTexture and texture) then
		self.iconTexture = texture
		if (not IS_PRE_CATACLYSM) then
			self.icon:SetTexture(self.altIconTexture or texture)
		end
	end

	self:SetTrackingActive(active)
end

-- Wrath of the Lich King only.
function HunterTrackingButtonMixin:UpdateImprovedTrackingTalent()
	-- Improved Tracking talent in WotLK.
	-- Makes the button glow if not active and
	-- matches classification of current target.
	local trackingType = self.trackingType
	if (trackingType and IsSpellKnown(IMPROVED_TRACKING_SPELLID)) then
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