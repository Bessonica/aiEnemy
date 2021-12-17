AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.m_fMaxYawSpeed = 200 -- Max turning speed
ENT.m_iClass = CLASS_CITIZEN_REBEL -- NPC Class

--[[---------------------------------------------------------
	--что делать когда обьект заспавнился
	
	разобраться с 
	self:CapabilitiesAdd(CAP_MOVE_GROUND)
	
	________________________________________
		self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_OPEN_DOORS, CAP_ANIMATEDFACE, CAP_SQUAD, CAP_USE_WEAPONS, CAP_DUCK, CAP_MOVE_SHOOT, CAP_TURN_HEAD, CAP_USE_SHOT_REGULATOR, CAP_AIM_GUN ) )

	
-----------------------------------------------------------]]

function ENT:Initialize()

	
	self.nick = "standart Soldier"
	self:SetModel( "models/seagull.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	
	self:SetNPCState(NPC_STATE_IDLE)
	self:SetSolid(SOLID_BBOX)
	self:DropToFloor()
	
	
	self:SetHealth( 50 )
	self:CapabilitiesAdd(CAP_MOVE_GROUND)

end


--[[---------------------------------------------------------
	--что делать когда обьект получает урон
-----------------------------------------------------------]]

function ENT:OnTakeDamage( dmginfo )

    local attacker = dmginfo:GetAttacker()
	local damage = dmginfo:GetDamage()
	
	self:SetHealth(self:Health() - damage)
	if(self:Health() <= 0 && attacker:IsPlayer() ) then
	   SafeRemoveEntity(self)
	   print(attacker:Nick() .. "is killed" .. self.nick .. )
	end
	
	return false

end

--[[---------------------------------------------------------
	--узнаем точность атаки
-----------------------------------------------------------]]


function ENT:GetAttackSpread( Weapon, Target )
	if(Weapon:GetClass() == "weapon_shotgun") then
	   return 0.5
	else 
	   return 0.1
	end
	
end

--[[
function ENT:GetRelationship( entity )

	if( entity:IsPlayer() ) then
	   return D_LI
	else
	   return D_NU
	end

end ]]