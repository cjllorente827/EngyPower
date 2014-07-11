-----------------------------------------------------------------------------------------------
-- Client Lua Script for EngyPower
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- EngyPower Module Definition
-----------------------------------------------------------------------------------------------
local EngyPower = {
    log = "",
	tBarSettings = {}
}

local Util = {}

local timerUpdate
 
-----------------------------------------------------------------------------------------------
-- Numerical Constants
-----------------------------------------------------------------------------------------------
local N_UPDATE_INTERVAL = 0.1
local N_VOLATILITY_ENUM = 1
local N_VOL_MAX = 100
local N_VOL_HI = 70
local N_VOL_MID = 50
local N_VOL_LO = 30

-----------------------------------------------------------------------------------------------
-- Color tables
-----------------------------------------------------------------------------------------------
local tBlue     = {a=1,r=0,g=0.5,b=1}
local tGreen    = {a=1,r=0,g=1,b=0}
local tOrange   = {a=1,r=1,g=0.5,b=0}
local tRed      = {a=1,r=1,g=0,b=0}

-----------------------------------------------------------------------------------------------
-- Default Settings
-----------------------------------------------------------------------------------------------

local tBarDefault = {
  strText = "",
  strFont = "CRB_Interface10",
  bLine = false,
  strSprite = "WhiteFill",
  cr = tBlue,
  crText = {a=1, r=1, g=1, b=1},
  loc = {
    fPoints = {0,0,0,0}, --left, top, right, bottom
    nOffsets = {10,10,390,50} --left, top, right, bottom
  },
  flagsText = {
    DT_CENTER = true,
    DT_VCENTER = true
  }
}


local nBarMaxLength
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
        self.wndNumber = self.wndMain:FindChild("Number")
        self.wndBar = self.wndMain:FindChild("Bar")

        self.tBarSettings = Util.CloneTable(tBarDefault)
        self.nBarPixieId = self.wndBar:AddPixie(self.tBarSettings)
        nBarMaxLength = self.tBarSettings.loc.nOffsets[3] - self.tBarSettings.loc.nOffsets[1]

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

    self.tBarSettings.loc.nOffsets[3] = (nVolatility*nBarMaxLength/100) + self.tBarSettings.loc.nOffsets[1]

    --[[
     Color cutoffs are as follows
     0-29: Blue
     30-49: Green
     50-70: Orange
     71-100: Red
    ]]
    if nVolatility < N_VOL_LO then
        self.tBarSettings.cr = tBlue
    elseif nVolatility >= N_VOL_LO and nVolatility < N_VOL_MID then
        self.tBarSettings.cr = tGreen  
    elseif nVolatility >= N_VOL_MID and nVolatility <= N_VOL_HI then
        self.tBarSettings.cr = tOrange
    else
        self.tBarSettings.cr = tRed
    end

    self.wndBar:UpdatePixie(self.nBarPixieId, self.tBarSettings)
    
end

-----------------------------------------------------------------------------------------------
-- EngyPower Util
-----------------------------------------------------------------------------------------------

function Util.CloneTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Util.CloneTable(orig_key)] = Util.CloneTable(orig_value)
        end
        setmetatable(copy, Util.CloneTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-----------------------------------------------------------------------------------------------
-- EngyPower Debug
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/epdebug"
function EngyPower:ShowDebugInfo()
    Print(self.log)
end

-----------------------------------------------------------------------------------------------
-- EngyPower Instance
-----------------------------------------------------------------------------------------------
local EngyPowerInst = EngyPower:new()
EngyPowerInst:Init()


