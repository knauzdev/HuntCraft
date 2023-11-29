ADDON_PREFIX_INFO = "BOUNTY_INFO"
ADDON_PREFIX_CARRIERS = "BOUNTY_CARRIERS"
ADDON_PREFIX_BOSS_STATUS = "BOUNTY_BOSS_STATUS"

PATH_ICON_CARRIER = "Interface/ICONS/Bounty/carrier.blp"
PATH_ICON_BOSS_UP = "Interface/ICONS/Bounty/boss_up.blp"
PATH_ICON_BOSS_BANISHING = "Interface/ICONS/Bounty/boss_banishing.blp"
ICON_CARRIER_SCALE = 40.0

local init = false;

local carriers = {} -- {name,x,y}
local pins = {}	-- {name,frame}

local spider_status = "DEAD";
local spider_pos = {0,0,0}

local pin_tooltip = nil

local function TranslateWorldToMap(x, y)
	local left, right, top, bottom = 3720.0, -160.0, 3760.0, 1020.0 -- Bayou map dimensions
	local mapwidth, mapheight = right-left, bottom-top

	local nx = ((top - x) / mapheight)
	local ny = ((left - y) / mapwidth)

	local nnx = nx *WorldMapButton:GetHeight()
	local nny = -ny *WorldMapButton:GetWidth()

	return nny, nnx -- finally, flip x and y because map is le retart
end

function SplitString(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

local function OnPinHover(self, motion)
	pin_tooltip:Show()
	pin_tooltip:SetFrameLevel(self:GetFrameLevel())
	local text = self:GetName()
	if string.find(text,"Boss") then
		 text="Boss Target"
	elseif string.find(text,"Carrier") then
		t = SplitString(text,"_")
		text = "Bounty Carrier: "..t[3]
	end

	pin_tooltip.text:SetText(text)
	pin_tooltip:SetPoint("LEFT",self,"RIGHT",0,10)
	pin_tooltip:SetWidth(pin_tooltip.text:GetStringWidth()+10)
end

local function OnPinLeave(self, motion)
	pin_tooltip:Hide()
end

local function CreatePin(name, icon_path)
	-- create a new pin
	local exists = false
	for k, p in pairs(pins) do -- if pin with name already exists, find it and return it
		if p[1] == name then return p[2] end
	end
	pin = nil
	pin = CreateFrame("Button", "Pin_"..name, WorldMapButton)
	table.insert(pins,{name,pin})
	pin:EnableMouse(true)
	pin:SetPoint("CENTER", WorldMapButton, "CENTER")
	local texture = pin:CreateTexture(nil, "OVERLAY")
	pin.texture = texture
	texture:SetAllPoints(pin)
	pin:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonDown", "RightButtonUp")
	pin:SetMovable(true)
	pin:Hide()
	local frameLevel = WorldMapButton:GetFrameLevel() + 5
	pin:SetParent(WorldMapButton)
	pin:SetFrameStrata("HIGH")
	pin:SetFrameLevel(frameLevel)
	pin:SetHeight(ICON_CARRIER_SCALE)
	pin:SetWidth(ICON_CARRIER_SCALE)
	pin:SetAlpha(0.8)
	pin.texture:SetTexture(icon_path)
	pin.texture:SetTexCoord(0, 1, 0, 1)
	pin.texture:SetVertexColor(1, 1, 1, 1)

	pin:SetScript("OnEnter",OnPinHover);
	pin:SetScript("OnLeave",OnPinLeave);
	return pin
end

function Init()
	-- init pin hover tooltip frame
	pin_tooltip = CreateFrame("Frame", "PinToolTip", WorldMapButton)
	pin_tooltip.text = pin_tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	pin_tooltip.text:SetPoint("CENTER",0,0)
	pin_tooltip:SetWidth(100)
	pin_tooltip:SetHeight(25)
	pin_tooltip:SetAlpha(1)
	pin_tooltip:SetFrameLevel(5)
	pin_tooltip:SetFrameStrata("HIGH")
	pin_tooltip.texture = pin_tooltip:CreateTexture("Texture","Background")
	pin_tooltip.texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
	pin_tooltip.texture:SetTexCoord(0, 1, 0, 1)
	pin_tooltip.texture:SetVertexColor(1, 1, 1, 1)
	pin_tooltip.texture:SetAllPoints(pin_tooltip)
	pin_tooltip:Hide()

	init = true
end

function BountyWorldMapIcons_OnUpdate()
	if not init then Init() end
	if not WorldMapButton:IsVisible() then return end
	if not (GetZoneText() == "The Bayou") then return end

	for k, pin in pairs(pins) do pin[2]:Hide(); end

	for k, carrier in pairs(carriers) do -- draw carriers
			icon = CreatePin("Carrier_"..carrier[1],PATH_ICON_CARRIER);
			icon:Show()
			local x, y = TranslateWorldToMap(carrier[2],carrier[3])
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x, y)
			if (carrier[1] == UnitName("player")) then icon:Hide() end
	end

	spider_boss_pin = CreatePin("Boss_Spider",PATH_ICON_BOSS_UP)
	if spider_boss_pin then
		if spider_status=="ALIVE" then
			spider_boss_pin:Show()
			spider_boss_pin:ClearAllPoints()
			spider_boss_pin.texture:SetTexture(PATH_ICON_BOSS_UP)
		elseif spider_status=="BANISHING" then
			spider_boss_pin:Show()
			spider_boss_pin:ClearAllPoints()
			spider_boss_pin.texture:SetTexture(PATH_ICON_BOSS_BANISHING)
		end
		local x,y = TranslateWorldToMap(spider_pos[1], spider_pos[2])
		spider_boss_pin:SetPoint("CENTER", WorldMapButton, "TOPLEFT", x, y)
	end
end

function BountyWorldMapIcons_OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix,msg,type,sender = arg1,arg2,arg3,arg4
		if prefix == ADDON_PREFIX_INFO then
			RaidNotice_AddMessage(RaidWarningFrame,msg,ChatTypeInfo["RAID_WARNING"]);
		elseif prefix == ADDON_PREFIX_CARRIERS then
			local sep_carriers = SplitString(msg,",")
			for k,v in pairs(carriers) do carriers[k]=nil end

			for k,sep_carrier in pairs(sep_carriers) do
				local car = SplitString(sep_carrier,"_")
				table.insert(carriers, car)
			end
		elseif prefix == ADDON_PREFIX_BOSS_STATUS then
			local sep1 = SplitString(msg,",")
			spider_status = sep1[1]
			spider_pos = SplitString(sep1[2],"_")
		end
	end
end
