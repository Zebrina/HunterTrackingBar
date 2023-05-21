if (not IsPlayerHunter()) then
    -- TODO: Add a red chat message telling player to disable addon.
    return;
end

local IS_CLASSIC = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE);

HUNTERTRACKINGBAR_YPOS = 89;
HUNTERTRACKINGBAR_XPOS = 236;

HUNTER_TRACKING_ACTIVE_TEXTURE = "Interface\\Icons\\Spell_Nature_WispSplode";

local function HunterTrackingBarFrame_ForEachButton(self, callback)
    for i, button in ipairs(self.Buttons) do
        callback(button, i);
    end
end

function HunterTrackingBarFrame_OnShow(self)
end

function HunterTrackingBarFrame_OnHide(self)
end

function HunterTrackingBarFrame_OnLoad(self)
	--if (IsAddOnLoaded("FastEquipMenu")) then
	--	self:SetPoint("BOTTOMLEFT", "InventoryEquipmentBar", "TOPLEFT", 75, 5.5);
	if (IS_CLASSIC) then
		self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 3);
	else
		if (IsAddOnLoaded("ClassicUI")) then
			self:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton1", "TOPLEFT", 28, 5.5);
		else
			self:SetPoint("BOTTOMLEFT", "MultiBarBottomLeftButton11", "TOPLEFT", 28, 5.5);
		end
	end
    
    for i = 2, getn(self.Buttons) do
        local button = self.Buttons[i];
        --button:ClearAllPoints();
        button:SetPoint("LEFT", self.Buttons[i - 1], "RIGHT", 8, 0);
    end

	HunterTrackingBarFrame_Update(self);
	HunterTrackingBarFrame_UpdateButtonLayout(self);

    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	--self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
end

function HunterTrackingBarFrame_OnEvent(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        HunterTrackingBarFrame_Update(self);
		if (IsPlayerHunter()) then
			ShowHunterTrackingBar();
		end
    elseif (event == "MINIMAP_UPDATE_TRACKING") then
        HunterTrackingBarFrame_Update(self);
		if (IS_CLASSIC) then
			HunterTrackingBarFrame_UpdateCooldowns(self);
		end
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		HunterTrackingBarFrame_UpdateButtonLayout(self);
    end
end

function HunterTrackingBarFrame_OnUpdate(self, elapsed)
	if (self.updateCooldowns) then
		HunterTrackingBarFrame_Update(self);
	end
end

function HunterTrackingBarFrame_Update(self)
    HunterTrackingBarFrame_ForEachButton(self, HunterTrackingButton_Update);
    --[[
	if (true) then
        return;
    end
	local petActionButton, petActionIcon;
	for i=1, 8, 1 do
		local buttonName = "HunterTrackingButton" .. i;
		petActionButton = _G[buttonName];
		petActionIcon = petActionButton.icon or _G[buttonName.."Icon"];
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i);

        if (isActive) then
            -- spell_nature_wispsplode
            petActionIcon:SetTexture(HUNTER_TRACKING_ACTIVE_TEXTURE);
            petActionButton:SetChecked(true);
        else
            petActionIcon:SetTexture(select(3, GetSpellInfo(self.spellID)));
            petActionButton:SetChecked(false);
        end
		if (texture) then
			if (GetPetActionSlotUsable(i)) then
				petActionIcon:SetVertexColor(1, 1, 1);
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4);
			end
			petActionIcon:Show();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		else
			petActionIcon:Hide();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		end
	end
	]]
end

function HunterTrackingBarFrame_UpdateCooldowns(self)
	self.updateCooldowns = C_Timer.NewTimer(1.5, function()
		self.updateCooldowns = nil;
	end);

    HunterTrackingBarFrame_ForEachButton(self, function(button, i)
        local start, duration, enable = GetSpellCooldown(button.spellID);
		CooldownFrame_Set(button.cooldown, start, duration, enable);

		if (GameTooltip:GetOwner() == button) then
			HunterTrackingButton_OnEnter(button);
		end
    end);
end

-- /run HunterTrackingBarFrame_UpdateButtonLayout(HunterTrackingBarFrame)
function HunterTrackingBarFrame_UpdateButtonLayout(self)
	local previousButton;
	HunterTrackingBarFrame_ForEachButton(self, function(button, i)
		if (HunterTrackingButton_ShouldShow(button)) then
			local point, relativeTo, relativePoint, offsetX, offsetY = button:GetPoint();
			if (previousButton == nil) then
				point = "BOTTOMLEFT";
				relativeTo = self;
				relativePoint = "BOTTOMLEFT";
				offsetX = 36;
				offsetY = 2;
			else
				point = "LEFT";
				relativeTo = previousButton;
				relativePoint = "RIGHT";
				offsetX = 8;
				offsetY = 0;
			end

			previousButton = button;

			button:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
			button:Show();
		else
			button:Hide();
		end
	end);
end

function ShowHunterTrackingBar(doNotSlide)
    --HunterTrackingBarFrame:SetPoint("LEFT", PetActionBarFrame, "RIGHT", 50, 0);
    HunterTrackingBarFrame:Show();
	--[[
    if (true) then
        return;
    end
	if (not HunterTrackingBarFrame:IsShown()) then
		if (MainMenuBar.busy or UnitHasVehicleUI("player") or doNotSlide) then
			HunterTrackingBarFrame:SetPoint("TOPLEFT", HunterTrackingBarFrame:GetParent(), "BOTTOMLEFT", HUNTERTRACKINGBAR_XPOS, HUNTERTRACKINGBAR_YPOS);
			HunterTrackingBarFrame.state = "top";
			HunterTrackingBarFrame:Show();
		else
			HunterTrackingBarFrame:Show();
			HunterTrackingBarFrame.mode = "show";
		end
		UIParent_ManageFramePositions();
	end
	]]
end

function HideHunterTrackingBar()
	if (HunterTrackingBarFrame:IsShown()) then
		if (MainMenuBar.busy or UnitHasVehicleUI("player") ) then
			HunterTrackingBarFrame:SetPoint("TOPLEFT", HunterTrackingBarFrame:GetParent(), "BOTTOMLEFT", HUNTERTRACKINGBAR_XPOS, 0);
			HunterTrackingBarFrame.state = "bottom";
			HunterTrackingBarFrame:Hide();
		else
			HunterTrackingBarFrame.mode = "hide";
		end
	end
end

function HunterTrackingButton_OnLoad(self)
    _G["BINDING_NAME_CLICK "..self:GetName()..":LeftButton"] = "Toggle "..self.trackingName;

	self.HotKey:ClearAllPoints();
	self.HotKey:SetPoint("TOPLEFT", -2, -3);

	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("UPDATE_BINDINGS");

	if (IS_CLASSIC) then
		self:SetAttribute("type", "spell");
		self:SetAttribute("spell", self.trackingName);
	else
		self:SetScript("OnClick", HunterTrackingButton_OnClick);
	end

    local cooldown = _G[self:GetName().."Cooldown"];
	cooldown:ClearAllPoints();
	cooldown:SetWidth(33);
	cooldown:SetHeight(33);
	cooldown:SetPoint("CENTER", self, "CENTER", -2, -1);

    self.setTexture = true;
    self.setChecked = true;

	HunterTrackingButton_UpdateHotkey(self);

    self.cooldown:SetSwipeColor(0, 0, 0);
end

function HunterTrackingButton_OnEvent(self, event, ...)
	if (event == "UPDATE_BINDINGS") then
		HunterTrackingButton_UpdateHotkey(self);
	end
end

function HunterTrackingButton_OnClick(self, button)
	local index, _, active = GetTrackingInfoByName(self.trackingName);
	if (index) then
		C_Minimap.SetTracking(index, not active);
	end
end

function HunterTrackingButton_OnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	if (GameTooltip:SetSpellByID(self.spellID)) then
		self.UpdateTooltip = HunterTrackingButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function HunterTrackingButton_OnLeave()
	GameTooltip:Hide();
end

function HunterTrackingButton_OnUpdate(self, elapsed)
end

function HunterTrackingButton_ShouldShow(self)
	if (self.noClassic and IS_CLASSIC) then
		return false;
	end
	return IsSpellKnown(self.spellID);
end

function HunterTrackingButton_UpdateIcon(self)
	local _, texture, active = GetTrackingInfoByName(self.trackingName);
	if (self.setTexture and active) then
		self.icon:SetTexture(HUNTER_TRACKING_ACTIVE_TEXTURE);
	else
		self.icon:SetTexture(texture);
	end
	self:SetChecked(self.setChecked and active);
end

function HunterTrackingButton_UpdateHotkey(self)
	local binding = GetBindingText(GetBindingKey("CLICK "..self:GetName()..":LeftButton"), true);
	local hotkey = self.HotKey;
	if (binding == "") then
		hotkey:Hide();
	else
		hotkey:SetText(binding);
		hotkey:Show();
	end
end

function HunterTrackingButton_Update(self)
    HunterTrackingButton_UpdateIcon(self);
    HunterTrackingButton_UpdateHotkey(self);
end