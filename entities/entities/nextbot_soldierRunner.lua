
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


--ИДЕЯ ДЛЯ УКРЫТИЙ
--в init вписываем список координат укрытий
--из списка выберает ближайшее укрытие и за него прячется
--как его научить занимать укрытие?

-- 1) выбрали укрытие,его координату
-- 2) берем координату игрока и укрытия и проводим прямую между ними
-- 3) удлиняем эту прямую и теперь мы получаем координату где между нпс и игроком будет укрытие

--      -----  СДЕЛАНО  -----
--      ВИЗУАЛИЗАЦИЯ
-- X = точка куда отправлятся игроку
-- O = укрытие
--            X
--           O
--          .       NPC 
--         .
--        .
--      ИГРОК
--

-- Vector(x, y, z)
-- Angle(pitch, yaw, roll)

--TODO
-- 1 пусть npc стоит на месте и стреляет по игроку
function ENT:Initialize()
	--self:SetModel( "models/Combine_Soldier.mdl" )
    self:SetModel( "models/Humans/Group01/Female_01.mdl" )
	--"models/Humans/Group01/Female_01.mdl" 
	--"models/Zombie/Classic.mdl"
	self.LoseTargetDist	= 2000	
	self.SearchRadius 	= 1000	
	
	self.StartleDist = 500
    self.WanderDist = 200
	
	--init cover pos
	-- -500, 80, 0
	-- -800, 80, 0
	--self.cover = { x=-800, y=80, z=0 }
	
	self.cover = Vector(-800, 80, 0)
	self.coverSt = Vector(-500, 80, 0)
	
	self.coverNew = Vector(-800, 80, 0 ) * 1.05
	--print(self.coverNew)
	--print(self.cover.x)
	
	--get new point for cover
	--self.cover:Sub(self.coverSt)
	print("new coord")
	print(self.cover)
	
	self:SetHealth(80)
	
	self.TestCircle = Vector(-500, 80, 0)
	 
	 -- радиус нпс кружляет вокруг игрока  
	self.radius = 300
    
   
   
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
			return self:FindEnemy()		
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
		self:StartActivity( ACT_IDLE )
		if ( self:PlayerNear() ) then
		    --print( self:GetPos() )
			self:StartActivity( ACT_IDLE )		
			--self:StartActivity( ACT_RUN )		
		    
			--self:StartActivity( ACT_WALK )			
			self.loco:SetDesiredSpeed( 300 )	
			self:StartActivity( ACT_RUN )
			--self:StartActivity( ACT_WALK )
			
			--self:RunAtTarget(self:GetEnemy():GetPos())
			--self.TestCircle
			
			--дать ускорение при набегании
			self:CircleAroundTarget(self:GetEnemy():GetPos())
			
			
			--self:CircleAroundTarget(self.TestCircle)
			
			-- Takecover
			--if(self:Health()<=10)
			if(self:Health()<=70) then
			self:TakeCover(self.cover)
			end
			print("Health")
			print(self:Health())
			--self:StartActivity( ACT_IDLE )	
			--ACT_COVER_LOW Y
			--ACT_COVER   X
			--self:StartActivity( ACT_COVER_LOW )
			
			
			
		

		else


		end

		coroutine.wait(1)
		
	end

end	


function ENT:ShootEnemy( options )

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

	while ( path:IsValid() and self:HaveEnemy() and path:GetLength()>=20) do
	
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
	print(self:GetPos())
	self:AttackEnemy()

	return "ok"

end

 --      !!!!  -------------- TODO --------------------- !!!!
 -- звук испуга когда они убегают
 -- может после того как они спрятались они получают немного хп ???
function ENT:TakeCover( dest )
-- dest = cover
	local dest = dest or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( dest.lookahead or 300 )
	path:SetGoalTolerance( dest.tolerance or 20 )
	path:Compute( self, dest )	

    if ( !path:IsValid() ) then return "failed" end
	
	--создаем вектор игрока и укрытия
	-- умножаем его на число
	-- и находим новую точку
	-- обновляем путь path:Update
	
	--self:GetEnemy():GetPos()
	
	while ( path:IsValid() and self:HaveEnemy() and path:GetLength()>=40) do
	
	    -- creat new point to hide behind cover 
		-- Vector( newX, newY)
		
		--print(self:GetPos())
		local playerX = self:GetEnemy():GetPos().x
		local playerY = self:GetEnemy():GetPos().y
		--print("player coord")
		--print(playerX, playerY)
		local k = 1.08
		-- k is how big is new vector
		-- newX = destX * k + (1-k) * playerX 
		-- same for y
		
		local newX =  k*dest.x +(1-k)*playerX
		local newY =  k*dest.y +(1-k)*playerY
		local newCoord = Vector(newX, newY)
		--print("NEW coord")
		--print(newCoord)

		if ( path:GetAge() > 0.1 ) then					
			--path:Compute(self, dest)
			path:Compute(self, newCoord)
		end
		path:Update( self )								
		
		if ( dest.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end
	
	self:StartActivity( ACT_COVER_LOW )
	return "ok"
end



--run at target in strait line,if player near target takes damage
function ENT:RunAtTarget(dest)
--dest = player
	local dest = dest or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( dest.lookahead or 300 )
	path:SetGoalTolerance( dest.tolerance or 20 )
	path:Compute( self, dest )	

    if ( !path:IsValid() ) then return "failed" end
	    
		-- заранее указывааем координату игрока,что бы она не обновлялась
		local targetX = dest.x
		local targetY = dest.y
		
		local k = 2
		
		local newX =  k*targetX +(1-k)*self:GetPos().x
		local newY =  k*targetY +(1-k)*self:GetPos().y
		local newCoord = Vector(newX, newY)
	
	while ( path:IsValid() and self:HaveEnemy() and path:GetLength()>=60) do
	--будет лучше если точка игрока не будет менятся он должен бежать по прямой

		
		if ( path:GetAge() > 0.1 ) then					
			--path:Compute(self, dest)
			path:Compute(self, newCoord)
		end
		path:Update( self )	
		
		if ( dest.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end
	
end

--run around player 
-- times - сколько раз кружлять вокруг игрока
-- сделать радиус круга полурандомный,что бы несколько нпс не наступали друг другу на "пятки"
-- ENT:CircleAroundTarget(dest, times, radius)

 --      !!!!  -------------- TODO --------------------- !!!!
-- дать возможность установить количество кругов,или сколько времени кружлять
-- дать ускорение при набегании
-- как им всем нпс дать разніе радиусы?
-- в инит сделать мин радиус + полурандомное число
-- дать разные звуки для набегание

function ENT:CircleAroundTarget(dest)

-- дать ускорение при набегании
 --      !!!!  -------------- TODO --------------------- !!!!
-- как им всем нпс дать разніе радиусы?
-- в инит сделать мин радиус + полурандомное число
-- дать разные звуки для набегание

    function PointOnCircle( ang, radius, offX, offY )
	print("______________________________")
	 print("angle")
	 print(ang)
	 
	 ang =  math.rad( ang )
	 local x = math.cos( ang ) * radius + offX
	 local y = math.sin( ang ) * radius + offY
	 
	 print("CALCULATED POINTOnCircle x, y, ang")
	 print(x, y, ang)
	 print("_______________________________")
	 return x, y
    end


    local centerX, centerY = dest.x, dest.y
	--           радиус от игрока и нсп
    --local radius = 250


	local dest = dest or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( dest.lookahead or 300 )
	path:SetGoalTolerance( dest.tolerance or 20 )
	path:Compute( self, dest )	

    if ( !path:IsValid() ) then return "failed" end
	
	print("STARTED TO CIRCLE")
	
	
	
	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	--идея, пусть будет переменная которая после каждого пролета while будет увеличиваться
	-- это бдет по сути degrees 
	-- !!!!! перенести centerX, centerY внутрь while так как игрок постоянно движется  !!!!
	-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	-- идея в инит создаем массив degrees где 1 -- 360
	-- в while обновляем путь и в каждой итерации увеличиваем degrees на 1
	--плюсуем 1 или переходим на новый элемент массива.(первый скорее всего проще)
	
	--как мне знать наверняка что он дойдет до координаты,или он не успеет и шагу сделать как будет новая координата и круга не будет
	-- нужно проверять
	
    degrees = 1
	
	--  while ( path:IsValid() and self:HaveEnemy() and path:GetLength()>=60) do
	while ( path:IsValid() and self:HaveEnemy() ) do
	       --print("CIRCLING")
		   -- local centerX, centerY = dest.x, dest.y
		   --self:GetEnemy():GetPos().x
		   
		   --local centerX, centerY = self:GetEnemy():GetPos().x, self:GetEnemy():GetPos().y
		   
		   local centerX = self:GetEnemy():GetPos().x
		   local centerY = self:GetEnemy():GetPos().y
	         -- получаем новую координату 
		     local xCircle, yCircle = PointOnCircle( degrees, self.radius, centerX, centerY )
			 local newCoord = Vector(xCircle, yCircle)
			  degrees = degrees + 10
			  print("DEGREES")
			  print(degrees)
			  print("COORD")
			  print(newCoord)
			  
			  if (degrees >= 360) then
			  degrees = 1
			  print("     -------- NOW DEGREES IS 1 -------    ")
			  end
			 
			 
			 -- _______________________________________________
			 -- идем к этой координате
			 
			 -- может сделать тут больше цифру, и тогда у нпс будет больше времени передвигатьс
			 if ( path:GetAge() > 0.1 ) then					
			  --path:Compute(self, dest)
			  path:Compute(self, newCoord)
		     end
			 
			 --while(path:GetLength()>=10) do
			   --path:Update( self )
			 --end
		     	
			 path:Update( self )
			 
			 
			 
			 if ( dest.draw ) then path:Draw() end
		
		     if ( self.loco:IsStuck() ) then
		      self:HandleStuck()
		      return "stuck"
	         end

		      coroutine.yield()
		   
		   
		   
		   
	
	end


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

--[[---------------------------------------------------------

function ENT:GiveWeapon(weaponcls)
	if not IsValid(self) then return end
	if self.Weapon then self.Weapon:Remove() end
	local att = "anim_attachment_RH"

	local shootpos = self:GetAttachment(self:LookupAttachment(att))
	
	local wep = ents.Create(weaponcls)

	wep:SetOwner(self)
	wep:SetPos(shootpos.Pos)
	wep:Spawn()

	wep.DontPickUp = true
	wep:SetSolid(SOLID_NONE)
	wep:SetParent(self)

	wep:SetAngles(self:GetForward():Angle())

	wep:Fire("setparentattachment", att)
	--wep:AddEffects(EF_BONEMERGE)

	self.Weapon = wep

	for _,fn in pairs(self.OnArm) do fn() end
end
-----------------------------------------------------------]]



list.Set("NPC", "nextbot_custom", {
  Name = "standart nextbot runner",
  Class = "nextbot_soldierRunner",
  Category = "NextBot"
})