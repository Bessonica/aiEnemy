AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



local function LoadFiles(filePath, lastFolder)
     print("Looking for " .. lastFolder)
     local files, folders = file.Find(filePath .. "/*", "GAME")
	 for k, File in pairs(files) do
	     
		 local category = string.sub(File, 0, 2)
		 
		 if(category == "sv") then
		    print("Adding Server:" .. lastFolder .. File)
			include(lastFolder .. File)
		 end
		 
		 if(category == "sh") then
		    print("Adding SHared:         " .. lastFolder .. File)
			include(lastFolder .. File)
			AddCSLuaFile(lastFolder .. File)
			print("Adding SHared: SUCCESS " .. lastFolder .. File)
		 end
		 
		 		 
		 if(category == "cl") then
		    print("Adding client:" .. lastFolder .. File)
			AddCSLuaFile(lastFolder .. File)
		 end
		 
	 end	 
	 
	 for k, Folder in pairs(folders)do
	     LoadFiles(filePath .. "/" .. Folder, lastFolder .. Folder .. "/")
	 end
	 
end

LoadFiles( "gamemodes/aiEnemy/gamemode", "" )

--[[
local function LoadFiles( filePath, lastFolder )=
end ]]
--[[
LoadFiles( "gamemodes/aiEnemy/gamemode", "" )

17
npc:SetPos(ply:GetPos() + Vector(0, 300, 0) )

]]
function GM:PlayerSpawn( ply )
    local npcZombie = ents.Create("nextbot_soldier")
	npcZombie:SetPos(ply:GetPos() + Vector(-1000, 100, 0) )
	npcZombie:Spawn()
	
	--npc to show cover
	local npcShooter = ents.Create("nextbot_soldierRanged")
	npcShooter:SetPos( Vector(-800, 80, 0) )
	npcShooter:Spawn()
	
	local npcShooter1 = ents.Create("nextbot_soldierRanged")
	npcShooter1:SetPos(ply:GetPos() + Vector(-500, 80, 0) )
	npcShooter1:Spawn()
	
	--local wep = ents.Create("weapon_shotgun")
	--wep:SetOwner(npcShooter)
	--wep:Spawn()
	
	--npcShooter:Give(wep)
	
	
	--npcShooter:Give("weapon_shotgun")
	
	
	--nextbot_soldierRunner
	local npcRunner1 = ents.Create("nextbot_soldierRunner")
	npcRunner1:SetPos(ply:GetPos() + Vector(-900, 80, 0) )
	npcRunner1:Spawn()
	
	
	ply:Give("weapon_shotgun")
	ply:GiveAmmo( 100, "BuckShot")
end