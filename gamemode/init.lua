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
	
	
	ply:Give("weapon_shotgun")
end