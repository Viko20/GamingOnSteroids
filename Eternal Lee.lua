require "DamageLib"
require "Eternal Prediction"

if myHero.charName ~= "Lee Sin" then return end

local myHero = _G.myHero

local Q = { delay = 0.2, range = 1100, speed = 1800, width = 60}
local W = { range = 700 }
local E = { delay = 0.1 , range = 350 , speed = math.huge }
local R = { delay = 0.3, range = 375 }

local qPred = Prediction:SetSpell(qSpellData, TYPE_LINE, true)

Q.IsReady = function() return LocalGameCanUseSpell(_Q) == READY end         
W.IsReady = function() return LocalGameCanUseSpell(_W) == READY end         
E.IsReady = function() return LocalGameCanUseSpell(_E) == READY end         
R.IsReady = function() return LocalGameCanUseSpell(_R) == READY end 

-- Helper Functions

local function GetDistance(p1,p2)
	return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y) + (p2.z - p1.z)*(p2.z - p1.z))
end

local function IsValidTarget(unit, range, onScreen)

    local range = range or math.huge 
	return unit and unit.distance <= range and not unit.dead and unit.valid and unit.visible and unit.isTargetable and not (onScreen and not unit.pos2D.onScreen)
end

-- Cast Functions

local CastQ = function(target)

	local pred = QPred:GetPrediction(target, myHero.pos)
	if pred and pred.hitChance >= 0.5 and pred:mCollision() == 0 and pred:hCollision() == 0 then
		Control.CastSpell(HK_Q, pred.castPos) 
	end
end

local CastW = function(target)

	local target = target or myHero
	Control.CastSpell(HK_W, target.pos) 
end

local CastE = function(target)

	Control.CastSpell(HK_E, target.pos) 
end

local CastR = function(target)

	Control.CastSpell(HK_R, target.pos)
end


-- Combo Functions

local RegularCombo = function(target)

	if myHero.attackData.state ~= 2 and IsValidTarget(target, Q.range, true) and Q.IsReady then
		CastQ(target)
	end

	if myHero.attackData.state ~= 2 and IsValidTarget(target, E.range, true) and E.IsReady then
		CastE(target)
	end

	if myHero.attackData.state ~= 2 and W.IsReady then
		CastW()
	end
	
	if myHero.attackData.state ~= 2 and R.IsReady and getdmg("R", target) > target.health then
		CastR()
	end
	
end


local Combo = function(target)
	
	if true then
		RegularCombo(target)
	end

end


-- Core Functions

local Mode = function()

	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		return "Combo"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
        return "Harass"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEARS] then
        return "LaneClear"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
        return "LaneClear"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
        return "LastHit"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
        return "Flee"
  end
end

local Tick = function()

	local target
	if target == nil then return end
	
	if Mode() == "Combo" then
		Combo(target)
	end
end

LocalCallbackAdd("Tick", function() Tick() end) 