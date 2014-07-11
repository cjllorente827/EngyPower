-----------------------------------------------------------------------------------------------
-- Client Lua Script for EngyPower
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- EngyPower Module Definition
-----------------------------------------------------------------------------------------------
local EngyPower = {
	log = ""
}

local timerUpdate
 
-----------------------------------------------------------------------------------------------
-- Numerical Constants
-----------------------------------------------------------------------------------------------
local N_UPDATE_INTERVAL = 0.2
local N_VOLATILITY_ENUM = 1
local N_VOL_MAX = 100
local N_VOL_HI = 70
local N_VOL_MID = 50
local N_VOL_LO = 30

-----------------------------------------------------------------------------------------------
-- Sprite Paths
-----------------------------------------------------------------------------------------------
-- Replacing with pixies \(^_^)/
--[[local SPR_LO_BAR = "sprResourceBar_ShieldProgBar"
local SPR_MID_BAR = "sprResourceBar_GreenProgBar"
local SPR_HI_BAR = "sprResourceBar_OrangeProgBar"
local SPR_FULL_BAR = "sprResourceBar_RedProgBar" --]]

-----------------------------------------------------------------------------------------------
-- Default Settings
-----------------------------------------------------------------------------------------------
local tPixieDefault = {
  strText = "Hello Pixie!",
  strFont = "CRB_Interface10",
  bLine = false,
  strSprite = "WhiteFill",
  cr = {a=1,r=0.4,g=0.8,b=1.0},
  crText = {a=1, r=1.0, g=1.0, b=1.0},
  loc = {
    fPoints = {0,0,0,0},
    nOffsets = {0,0,100,100}
  },
  flagsText = {
    DT_CENTER = true,
    DT_VCENTER = true
  }
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function EngyPower:new(o)
	
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function EngyPower:Init()
	
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- EngyPower OnLoad
-----------------------------------------------------------------------------------------------
function EngyPower:OnLoad()
	
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("EngyPower.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	Player = GameLib.GetPlayerUnit()
end

-----------------------------------------------------------------------------------------------
-- EngyPower OnDocLoaded
-----------------------------------------------------------------------------------------------
function EngyPower:OnDocLoaded()
	
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Main", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
	    self.wndBar = self.wndMain:FindChild("Bar")
	    self.wndNumber = self.wndMain:FindChild("Number")

		self.xmlDoc = nil
		
		Apollo.RegisterSlashCommand("ep", "ShowConfig", self)
		Apollo.RegisterSlashCommand("epreload", "OnEngyPowerOn", self)
		Apollo.RegisterSlashCommand("epoff", "OnEngyPowerOff", self)
		Apollo.RegisterSlashCommand("epdebug", "ShowDebugInfo", self)

		self:OnEngyPowerOn()
		
	end
end

-----------------------------------------------------------------------------------------------
-- EngyPower Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/ep"
function EngyPower:OnEngyPowerOn()
	local player = GameLib.GetPlayerUnit()
	if player == nil or player:GetClassId() ~= GameLib.CodeEnumClass.Engineer then return end
	
	self.wndMain:Invoke() -- show the window
	
	--start the update loop timer
	if timerUpdate ~= nil then
		timerUpdate:Start()
	else
		timerUpdate = ApolloTimer.Create(N_UPDATE_INTERVAL, true, "OnUpdate", self)
	end
	
end

function EngyPower:ShowConfig()
	Print("This is where a config window would go... IF I HAD ONE")
end


-- Closes the window and stops the timer from running
function EngyPower:OnEngyPowerOff()
	timerUpdate:Stop()
	self.wndMain:Close()
end

-----------------------------------------------------------------------------------------------
-- Main Update Loop
-----------------------------------------------------------------------------------------------
function EngyPower:OnUpdate()
	
	local player = GameLib.GetPlayerUnit()
	if player == nil then return end
	local nVolatility = player:GetResource(N_VOLATILITY_ENUM)
	
	self.wndNumber:SetText(nVolatility)
											
	
	--Old code based on using sprites, replacing with Pixies \(^_^)/
	--[[self.wndProgressBar:SetProgress(nVolatility/100)
	
	local strFillSprite = SPR_LO_BAR

	if nVolatility >= N_VOL_LO and nVolatility < N_VOL_MID then
		strFillSprite = SPR_MID_BAR
	elseif nVolatility >= N_VOL_MID and nVolatility <= N_VOL_HI then
		strFillSprite = SPR_HI_BAR	
	elseif nVolatility > N_VOL_HI then
		strFillSprite = SPR_FULL_BAR
	end

	self.wndProgressBar:SetFillSprite(strFillSprite)--]]
	
end

-----------------------------------------------------------------------------------------------
-- EngyPower Debug
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/epdebug"
function EngyPower:ShowDebugInfo()
	self.wndBar:AddPixie(tPixieDefault)
	Print(tostring(self.wndBar:GetPixieInfo()))
	Print(self.log)
end

-----------------------------------------------------------------------------------------------
-- EngyPower Instance
-----------------------------------------------------------------------------------------------
local EngyPowerInst = EngyPower:new()
EngyPowerInst:Init()


