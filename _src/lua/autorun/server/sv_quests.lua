if game.GetMap() ~= MapConfig.MapID then return end

util.AddNetworkString 'quest.sendTyped'
util.AddNetworkString 'quest.sendCustom'
util.AddNetworkString 'quest.hide'
util.AddNetworkString 'quest.updateClientside'

hook.Add('PlayerNoClip', 'quests', function(_, on)
	if on and not MapConfig.EnableNoclip then
		return false
	end
end)
hook.Add('PlayerSwitchFlashlight','quests', function(ply)
	if not ply:GetQuestProperty('flashlight') then
		return false
	end
end)

hook.Add('PlayerSpawn', 'quests', function(ply)
	timer.Simple(0, function()
		if ply:IsValid() then
			ply:UpdateQuestSpeed()
			ply:UpdateQuestNetwork()
		end
	end)
end)

hook.Add('PlayerLoadout', 'quests', function()
	if MapConfig.StripWeapons then
		return true
	end
end)

hook.Add('GetFallDamage', 'quests', function(ply)
	if ply:GetQuestProperty('falldamage') == false then
		return 0
	end
end)

hook.Add('EntityTakeDamage', 'quests', function(ent, dmg)
	if ent:IsPlayer() and ent:GetQuestProperty('damage') == false then
		return true
	end
end)