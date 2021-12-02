
ENT.Base = "base_entity"
ENT.Type = "ai"

ENT.PrintName		= "Standart Soldier"
ENT.Author			= "PanfilovDmytro"
ENT.Contact			= ""
ENT.Purpose			= "first test"
ENT.Instructions	= ""

ENT.AutomaticFrameAdvance = false



--[[---------------------------------------------------------
	--что делать когда обьект удаляется
-----------------------------------------------------------]]

function ENT:OnRemove()
    print(self:GetClass() .. "killed")
end