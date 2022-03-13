ENT.Type	= 'point'

local tonumber, writeBool = tonumber, net.WriteBool
local unset, yes, no = 'unset', 'yes', 'no'

ENT.Parsers = {
	walkspeed = tonumber,
	slowwalkspeed = tonumber,
	runspeed = tonumber,
	climbspeed = tonumber,
	crouchspeed = tonumber,
	jumppower = tonumber,
	static = tobool,
}

function ENT:Initialize()
	local kvs = self.kvs or {}
	if self.kvs.static then
		self:ApplyToEveryone()
		print('applied')
	end
end

QuestConfig = QuestConfig or {
	layer = 0,
}
hook.Add('PlayerDisconnected', 'quests.config', function(ply)
	QuestConfig[ply] = nil
end)

local function choiceToBool(choice, prev, layer)
	return choice ~= unset and { choice == yes, layer } or prev
end
local function dynamicInt(dynamic, prev, layer)
	return dynamic >= 0 and { dynamic, layer } or prev
end

function ENT:ApplyTo(data)
	QuestConfig.layer = QuestConfig.layer + 1
	local layer, kvs = QuestConfig.layer, self.kvs
	data.flashlight = choiceToBool(kvs.flashlight, data.flashlight, layer)
	data.damage = choiceToBool(kvs.damage, data.damage, layer)
	data.falldamage = choiceToBool(kvs.falldamage, data.falldamage, layer)
	data.walkspeed = dynamicInt(kvs.walkspeed, data.walkspeed, layer)
	data.slowwalkspeed = dynamicInt(kvs.slowwalkspeed, data.slowwalkspeed, layer)
	data.runspeed = dynamicInt(kvs.runspeed, data.runspeed, layer)
	data.climbspeed = dynamicInt(kvs.climbspeed, data.climbspeed, layer)
	data.crouchspeed = dynamicInt(kvs.crouchspeed, data.crouchspeed, layer)
	data.jumppower = dynamicInt(kvs.jumppower, data.jumppower, layer)
	data.showhealth = choiceToBool(kvs.showhealth, data.showhealth, layer)
end

function ENT:ApplyToTarget(target)
	local data = QuestConfig[target] or {}
	QuestConfig[target] = data
	self:ApplyTo(data)

	target:UpdateQuestSpeed()
	target:UpdateQuestNetwork()

end

function ENT:ApplyToEveryone()
	self:ApplyTo(QuestConfig)
	if QuestConfig.showhealth and QuestConfig.showhealth[2] == QuestConfig.layer then
		net.Start('quest.updateClientside')
			writeBool(QuestConfig.showhealth[1])
		net.Broadcast()
	end
	for _, v in ipairs(player.GetAll()) do
		v:UpdateQuestSpeed()
	end
end

function ENT:AcceptInput(name, activator, caller, args)
	name = name:lower()
	if name:sub(1, 2) == 'on' then
		self:FireOutput(name, activator, caller, args)
		return true
	elseif name == 'applyonactivator' then
		self:ApplyToTarget(activator)
	elseif name == 'applyoneveryone' then
		self:ApplyToEveryone()
	end
end

function ENT:KeyValue(key, value)
	self.kvs = self.kvs or {}
	key = key:lower()
	if self.Parsers[key] then value = self.Parsers[key](value) end
	print('set', key, value)
	self.kvs[key] = value
end