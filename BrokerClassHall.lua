-- Broker [Class Hall]
-- Description: Broker plug-in to open your Order Hall
-- Author: r1fT
-- Version: 1.0.0.70100

LDB = LibStub:GetLibrary("LibDataBroker-1.1")	
local LDBClassHall = LDB:NewDataObject("Class Hall", 
{
	type = "data source", 
	text = "", 
	OnClick = function(frame,button)
		if button == "LeftButton" then
			GarrisonLandingPage_Toggle()
		end
	end
})

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	LoadClassHallLDB()
end) 
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
f:RegisterEvent("GARRISON_FOLLOWER_ADDED")
f:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
f:RegisterEvent("GARRISON_TALENT_COMPLETE")
f:RegisterEvent("GARRISON_TALENT_UPDATE")
f:RegisterEvent("GARRISON_SHOW_LANDING_PAGE")

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
	self:AddLine("Class Hall")
	self:AddLine("\n")
	
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local NoResearch = true
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
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
	if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end

		local currency, amount, icon = GetCurrencyInfo(currencyId)
		self:AddDoubleLine(" |T"..icon..":0:0:0:2:64:64:4:60:4:60|t |cFFFFE000"..currency..":", "|cFFFFFFFF"..amount,1,1,1, 1,1,1)

		if #follower_categoryInfo > 0 then
			self:AddLine("\n")
			for _, info in ipairs(follower_categoryInfo) do
				self:AddDoubleLine("|T"..info.icon..":0|t |cFFFFE000"..info.name..":", "|cFFFFFFFF"..info.count.."/"..info.limit,1,1,1, 1,1,1)
			end
		end
		
		if #mission_categoryInfo > 0 then
			self:AddLine("\n")
			self:AddLine("|cFF00FF00Current Missions")
			for _, info in ipairs(mission_categoryInfo) do
				if info.timeLeftSeconds > 0 then
					self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..info.timeLeft,1,1,1, 1,1,1)
				else
					self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFF00FF00Compleated",1,1,1, 1,1,1)
				end
			end
		end
		
		if #research_categoryInfo > 0 then
			self:AddLine("\n")
			self:AddLine("|cFF00FF00Current Research")
			local ResearchString0
			local ResearchString1
			for _, info in ipairs(research_categoryInfo) do
				research_string  = string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",C_Garrison.GetLandingPageShipmentInfoByContainerID(info))
				research_table = mysplit(research_string,",")				
				for key, value in pairs(research_table) do
					if key == 1 then
						ResearchString0 = value
					end
					if key == 8 then
						ResearchString1 = value
					end
					if ResearchString0 ~= nil then
						if ResearchString1 ~= nil then
							self:AddDoubleLine("|cFFFFE000"..ResearchString0..":", "|cFFFFFFFF"..ResearchString1,1,1,1, 1,1,1)
							ResearchString0 = nil
							ResearchString1 = nil
						end
					end
				end
			end
		end
		
		if #talent_categoryInfo > 0 then
			for _, tree in ipairs(talent_categoryInfo) do
				for _, info in ipairs(tree) do
					if info.selected == true then
						if info.researched == false then
							NoResearch = false
							local talenttimeremaing_days = string.format("%.1d", info.researchTimeRemaining/86400)
							local talenttimeremaing_hours = string.format("%.1d", (info.researchTimeRemaining-(talenttimeremaing_days*86400))/3600)
							if tonumber(talenttimeremaing_days) > 0 then
								self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..talenttimeremaing_days.." day "..talenttimeremaing_hours.." hr",1,1,1, 1,1,1)
							else
								talenttimeremaing_min = string.format("%.1d", (info.researchTimeRemaining-(talenttimeremaing_hours*3600))/60)
								if tonumber(talenttimeremaing_hours) > 0 then
									self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..talenttimeremaing_hours.." hr "..talenttimeremaing_min.." min",1,1,1, 1,1,1)
								else
									self:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..talenttimeremaing_min.." min",1,1,1, 1,1,1)
								end
							end
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
end

function LoadClassHallLDB()
	ClassIcon = UnitClass("player")
	ClassIcon = ClassIcon:gsub("%s+", "")
	LDBClassHall.icon = "Interface\\Addons\\BrokerClassHall\\Icons\\"..ClassIcon;
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
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

