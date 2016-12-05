-- Broker [Class Hall]
-- Description: Broker plug-in to open your Order Hall
-- Author: r1fT
-- Version: v1.1.3.70100
-- Hash: @project-hash@



LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local ClassHallProfile = UnitName("player").."-"..GetRealmName()
local LDBClassHall = LDB:NewDataObject("Broker_|cff008cffClass Hall|r", 
{
	type = "data source", 
	text = "", 
	OnClick = function(frame,button)
		if button == "LeftButton" then
			GarrisonLandingPage_Toggle()
		end
		if button == "RightButton" then
			ClassHallInitDB()
			menu = {
				{ text = "Broker_|cff008cffClassHall|r", isTitle = true },
				{ text = "\n", disabled = true }
				}
				for name, _ in pairs(BrokerClassHall.profiles) do
					local info = {};
					info.text = name;
					if name == ClassHallProfile then 	
						info.checked = true;						
					else
						info.checked = false;
					end
					info.func = function()
						ClassHallProfile = name
					end
					tinsert(menu, info)
				end
				if BrokerClassHall.chbuttonstate == "true" then
					local info = {};
					info.text = "Hide Class Hall Button";
					info.func = function()
						BrokerClassHall.chbuttonstate = "false"
						HideClassHallButton()
					end
					tinsert(menu, info)
				else
					local info = {};
					info.text = "Show Class Hall Button";
					info.func = function()
						BrokerClassHall.chbuttonstate = "true"
						HideClassHallButton()
					end
					tinsert(menu, info)
				end
			local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")
			EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
		end
	end
})

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	LoadClassHallLDB()
	ClassHallSaveToonData()
	HideClassHallButton()
end) 
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEAVING_WORLD")

function ClassHallInitDB()
	if type(BrokerClassHall) ~= "table" then
		BrokerClassHall = {}
	end
	if type(BrokerClassHall.profiles) ~= "table" then
		BrokerClassHall.profiles = {}
	end
	if type(BrokerClassHall.ignores) ~= "table" then
		BrokerClassHall.ignores = {}
	end
	if BrokerClassHall.chbuttonstate == nil then
		BrokerClassHall.chbuttonstate = "true"
	end
	if type(BrokerClassHall.profiles[ClassHallProfile]) ~= "table" then
		BrokerClassHall.profiles[ClassHallProfile] = {}
	end
	for name, missions in pairs(BrokerClassHall.profiles) do
		for i, mission in ipairs(missions) do
			if type(mission) == "table" and not mission.missionEndTime then
				mission.missionEndTime = mission.timeComplete
			end
		end
	end
	
end

function ClassHallSaveToonData()
	ClassHallInitDB()
	local ClassHallProfile_Save = UnitName("player").."-"..GetRealmName()
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	end
	local followershipment_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		followershipment_categoryInfo = C_Garrison.GetFollowerShipments(LE_GARRISON_TYPE_7_0)
	end
	local mission_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		mission_categoryInfo = C_Garrison.GetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
	end
	local research_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		research_categoryInfo = C_Garrison.GetLooseShipments(C_Garrison.GetLandingPageGarrisonType(LE_GARRISON_TYPE_7_0))
	end
	local talent_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		talent_categoryInfo = C_Garrison.GetTalentTrees(LE_GARRISON_TYPE_7_0, select(C_Garrison.GetLandingPageGarrisonType(LE_GARRISON_TYPE_7_0), UnitClass("player")))
	end
	local currency_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		currency_categoryInfo = GetCurrencyInfo(currencyId)
	end
	GetCurrencyInfo(currencyId)
	wipe(BrokerClassHall.profiles[ClassHallProfile_Save])
	
	if follower_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].follower ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].follower = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].follower)
		end
		for _, info in ipairs(follower_categoryInfo) do
			tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].follower, info)
		end
	end
	if followershipment_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].followershipment ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].followershipment = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].followershipment)
		end
		local info
		local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID
		for _, v in ipairs(followershipment_categoryInfo) do
			name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID = C_Garrison.GetLandingPageShipmentInfoByContainerID(v)
			info = {}
			info.name = name
			info.shipmentsReady = shipmentsReady
			info.shipmentsTotal = shipmentsTotal
			info.missionEndTime = creationTime + duration
			tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].followershipment, info)
		end
	end
	if mission_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].mission ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].mission = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].mission)
		end
		for _, info in ipairs(mission_categoryInfo) do
			tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].mission, info)
		end
	end
	if research_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].research ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].research = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].research)
		end
		for _, info in ipairs(research_categoryInfo) do
			local info
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID
			for k, v in pairs(C_Garrison.GetLooseShipments(3) or {}) do
				name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID = C_Garrison.GetLandingPageShipmentInfoByContainerID(v)
				if itemID == 139390 and creationTime and duration and name then
					if not info then
						info = {rewards = {{}}}
					end
					info.isArtifact = true
					info.name = name
					info.missionEndTime = creationTime + duration
					if GetServerTime() >= info.missionEndTime then
						info.isComplete = true
						shipmentsReady = shipmentsReady + 1
						if shipmentsReady > shipmentsTotal then
							shipmentsReady = shipmentsTotal
						end
					elseif shipmentsReady > 0 then
						info.isComplete = true
					else
						info.isComplete = nil
					end
					info.artifactReady = shipmentsReady
					info.artifactTotal = shipmentsTotal
					info.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0
					info.typeIcon = texture
					info.rewards[1].itemID = itemID
					info.rewards[1].quantity = 1
					tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].research, info)
					break
				end
			end
		end
	end
	if talent_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].talent ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].talent = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].talent)
		end
		for _, info in ipairs(talent_categoryInfo) do
			tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].talent, info)
		end
	end
	if talent_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].talent ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].talent = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].talent)
		end
		for _, info in ipairs(talent_categoryInfo) do
			tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].talent, info)
		end
	end
	if currency_categoryInfo ~= nil then
		if BrokerClassHall.profiles[ClassHallProfile_Save].currency ~= table then
			BrokerClassHall.profiles[ClassHallProfile_Save].currency = {}
		else
			wipe(BrokerClassHall.profiles[ClassHallProfile_Save].currency)
		end
		local currency, amount, icon = GetCurrencyInfo(currencyId)
		tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].currency, currency)
		tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].currency, amount)
		tinsert(BrokerClassHall.profiles[ClassHallProfile_Save].currency, icon)
	end
end

function LDBClassHall.OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()
    ClassHallMakeToolTip(GameTooltip)
    GameTooltip:Show()
end

function LDBClassHall.OnLeave()
	GameTooltip:Hide()
end


	
function ClassHallMakeToolTip(self)
	ClassHallSaveToonData()
	self:AddLine("Class Hall |cFF0000FF[|cFFFFFFFF"..ClassHallProfile.."|cFF0000FF]")
	self:AddLine("\n")
	local NoResearch = true
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end

		local currency = BrokerClassHall.profiles[ClassHallProfile].currency[1]
		local amount = BrokerClassHall.profiles[ClassHallProfile].currency[2]
		local icon = BrokerClassHall.profiles[ClassHallProfile].currency[3]
		self:AddDoubleLine(" |T"..icon..":0:0:0:2:64:64:4:60:4:60|t |cFFFFE000"..currency..":", "|cFFFFFFFF"..amount,1,1,1, 1,1,1)

		if #BrokerClassHall.profiles[ClassHallProfile].follower > 0 then
			self:AddLine("\n")
			for _, info in ipairs(BrokerClassHall.profiles[ClassHallProfile].follower) do
				self:AddDoubleLine("|T"..info.icon..":0|t |cFFFFFFFF"..info.name..":", "|cFFFFFFFF"..info.count.."/"..info.limit,1,1,1, 1,1,1)
			end
		end
		
		if #BrokerClassHall.profiles[ClassHallProfile].mission > 0 then
			self:AddLine("\n")
			self:AddLine("|cFF00FF00Current Missions")
			for _, info in ipairs(BrokerClassHall.profiles[ClassHallProfile].mission) do
				local timeremaining = info.missionEndTime-GetServerTime()
				if timeremaining > 0 then
					local missiontimeremaining = ClassHallTimeFormat(timeremaining)
					self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
				else
					self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFF00FF00Completed",1,1,1, 1,1,1)
				end
			end
		end
		
		self:AddLine("\n")
		self:AddLine("|cFF00FF00Current Research")
		
		if #BrokerClassHall.profiles[ClassHallProfile].followershipment > 0 then
			for _, info in ipairs(BrokerClassHall.profiles[ClassHallProfile].followershipment) do
				if info.missionEndTime ~= 0 then
					local timeremaining = info.missionEndTime-GetServerTime()
					local missiontimeremaining = ClassHallTimeFormat(timeremaining)
					GameTooltip:AddDoubleLine("|cFFFFE000"..info.name.." ("..info.shipmentsReady.."/"..info.shipmentsTotal.."):", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
				end
			end
		end	
		
		if #BrokerClassHall.profiles[ClassHallProfile].research > 0 then
			for _, info in ipairs(BrokerClassHall.profiles[ClassHallProfile].research) do
				if info.missionEndTime ~= nil then
					if info.missionEndTime > 0 then
						local timeremaining = info.missionEndTime-GetServerTime()
						local missiontimeremaining = ClassHallTimeFormat(timeremaining)
						GameTooltip:AddDoubleLine("|cFFFFE000"..info.name.." ("..info.artifactReady.."/"..info.artifactTotal.."):", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
					end
				end
			end
		end
		
		if #BrokerClassHall.profiles[ClassHallProfile].talent > 0 then
			for _, tree in ipairs(BrokerClassHall.profiles[ClassHallProfile].talent) do
				for _, info in ipairs(tree) do
					if info.selected == true then
						if info.researched == false then
							NoResearch = false
							local timeremaining = (info.researchDuration+info.researchStartTime)-GetServerTime()
							local missiontimeremaining = ClassHallTimeFormat(timeremaining)
							self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
						end
					end
					if info.tier == 5 then
						if info.researched == true then
							NoResearch = false
						end
					end
				end
				if NoResearch == true then
					self:AddLine("|cFFFF0000No Class Hall Talent Research")
				end
			end
		end

	self:AddLine("\n")			
	self:AddLine("|cff00ff00Left click for Class Hall report")
	self:AddLine("|cff00ff00Right click to view other characters")
	return 
end

function LoadClassHallLDB()
	ClassIcon = UnitClass("player")
	ClassIcon = ClassIcon:gsub("%s+", "")
	LDBClassHall.icon = "Interface\\Addons\\broker_orderhall\\Icons\\"..ClassIcon;
end

function HideClassHallButton()
	if BrokerClassHall.chbuttonstate == "false" then
		C_Timer.After(2, function()
		GarrisonLandingPageMinimapButton:Hide()
		end)
	else
		GarrisonLandingPageMinimapButton:Show()
	end
end

function ClassHallTimeFormat(remaining)
	local seconds = remaining % 60
	remaining = (remaining - seconds) / 60
	local minutes = remaining % 60
	remaining = (remaining - minutes) / 60
	local hours = remaining % 24
	local days = (remaining - hours) / 24
	if days > 0 then
		time_formated = days.." day "..hours.." hr"
	else
		if hours > 0 then
			time_formated = hours.." hr "..minutes.." min"
		else
			time_formated = minutes.." min"
		end
	end
	return time_formated
end

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

