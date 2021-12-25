
AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.RenderGroup		= RENDERGROUP_OPAQUE
ENT.Spawnable = true
ENT.Type = "nextbot"


function ENT:Initialize()
	self:SetModel( "models/Zombie/Classic.mdl" )
	
	self.LoseTargetDist	= 2000	
	self.SearchRadius 	= 1000	
	
	self.StartleDist = 500
    self.WanderDist = 200
	
		--self.cover = { x=-800, y=80, z=0 }
	--print(self.cover.x)
   
   --self:SetHealth(200)
   
end

----------------------------------------------------

----------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end


function ENT:HaveEnemy()
	if ( self:GetEnemy() and IsValid(self:GetEnemy()) ) then
		if ( self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist ) then
			return self:FindEnemy()
		elseif ( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
			return self:FindEnemy()		-- Return false if the search finds nothing
		end	
		return true
	else
		return self:FindEnemy()
	end
end


function ENT:FindEnemy()
	local _ents = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	for k,v in ipairs( _ents ) do
		if ( v:IsPlayer() ) then
			self:SetEnemy(v)
			return true
		end
	end	
	self:SetEnemy(nil)
	return false
end


function ENT:PlayerNear()
  for k, v in pairs( ents.FindInSphere(self:GetPos(), self.StartleDist) ) do
      if( v:IsPlayer() && v:IsLineOfSightClear(self:GetPos() )    ) then
	     return true
	  end
  end
  
  return false

end


--TODO 
--добавит звуки, анимации-реакции на игрока(мол зомби увидел игрока)

function ENT:RunBehaviour()
	while ( true ) do
		
		--if ( self:HaveEnemy() ) then
		--инициируем врага(игрока) для нпс
		self:HaveEnemy()
		
		if ( self:PlayerNear() ) then
			
			self.loco:FaceTowards(self:GetEnemy():GetPos())	
			
			self:StartActivity( ACT_WALK )			
			self.loco:SetDesiredSpeed( 40 )		
			--
			self:ChaseEnemy( ) 						
			
			self:StartActivity( ACT_IDLE )			

		else
		
			self:StartActivity( ACT_WALK )			
			self.loco:SetDesiredSpeed( 60 )		
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400 ) -- Walk to a random place within about 400 units (yielding)
			self:StartActivity( ACT_IDLE )
		end

		coroutine.wait(2)
		
	end

end	

----------------------------------------------------

----------------------------------------------------
function ENT:ChaseEnemy( options )

	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() and path:GetLength()>=60) do
	
		if ( path:GetAge() > 0.1 ) then					
			path:Compute(self, self:GetEnemy():GetPos())
		end
		path:Update( self )								
		
		if ( options.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end
	
	print("ZOMBIE REACHED PLAYER")
	self:AttackEnemy()

	return "ok"

end

-- когда зомби перестал идти за игроком он должен его бить
-- пока растояние меньше 50 (path:GetLength()>50  -- ChaseEnemy) зомби бьет врага/игрока
-- self:GetEnemy():GetPos()

--ПРОБЛЕМА нпс неотзывчивый

--TODO добавить звуки удара
function ENT:AttackEnemy()


self:StartActivity( ACT_MELEE_ATTACK1 )
print("ATTACKED")
oldHP = self:GetEnemy():Health()
self:GetEnemy():SetHealth(oldHP - 10)
--coroutine.wait(1)

end

	--[[---------------------------------------------------------
	
function ENT:Initialize()
   self:SetModel("models/seagull.mdl")
   
   self.StartleDist = 500
   self.WanderDist = 200
   
   PrintTable( self:GetSequenceList() )
   
   
end


-- ВАЖНАЯ ФУНКЦИЯ 
function ENT:PlayerNear()
  for k, v in pairs( ents.FindInSphere(self:GetPos(), self.StartleDist) ) do
      if( v:IsPlayer() && v:IsLineOfSightClear(self:GetPos() )    ) then
	     return true
	  end
  end
  
  return false

end


	
function ENT:RunBehaviour()
      while(true) do
	      if(self:PlayerNear() )then
		  self.loco:SetDesiredSpeed( 100 )
		  self:EmitSound( "ambient/alarms/klaxon1.wav" )
		  self:PlaySequenceAndWait( "Hop" )
		  self:StartActivity( ACT_RUN )
		  self:MoveToPos( self:GetPos() + Vector( math.Rand(-1, 1), math.Rand(-1, 1), 0) * 1000)
		  self:PlaySequenceAndWait( "Land" )
		  self:StartActivity( ACT_IDLE )
		  else
		  self:StartActivity( ACT_WALK )
		  self.loco:SetDesiredSpeed( 100 )
		  self:MoveToPos( self:GetPos() + Vector( math.Rand(-1, 1), math.Rand(-1, 1), 0) * self.WanderDist )
		  self:StartActivity( ACT_IDLE )
		  
		  end
		  coroutine.wait(1)
	  end
	  
end
		
		
	-----------------------------------------------------------]]



list.Set("NPC", "nextbot_custom", {
  Name = "standart nextbot",
  Class = "nextbot_soldier",
  Category = "NextBot"
})