local cfg = MapConfig
if game.GetMap() ~= cfg.MapID then return end

-- HOOKS
local showHealth = cfg.ShowHealth
hook.Add('HUDShouldDraw', 'quests', function(name)
	if name == 'CHudHealth' and not showHealth then return false end
end)
local function no() return false end
hook.Add('ContextMenuOpen', 'quests', no)
hook.Add('SpawnMenuOpen', 'quests', no)
hook.Add('Initialize', 'quests', function()
	if GAMEMODE.SuppressHint then
		GAMEMODE:SuppressHint('OpeningMenu')
		GAMEMODE:SuppressHint('Annoy1')
		GAMEMODE:SuppressHint('Annoy2')
	end
end)


-- RENDER
color_shadow = Color(0,0,0,200)

qLabels = qLabels or {}
for k in pairs(cfg.TypesData) do
	qLabels[k] = qLabels[k] or {}
end

local function drawLines(lines, length, type)
	local sw, sh = ScrW(), ScrH()
	local data = cfg.TypesData[type]
	local startY, color, font = data.startY(sh), data.color, data.font
	local alpha = 231

	for i, key in ipairs(lines) do
		local phrase = language.GetPhrase(cfg.LocalePrefix .. '.' .. key)
		timer.Simple((length / 20) * i, function()
			if type == 2 and i == #lines then -- why not type 3?
				color, startY = Color(30, 30, 30), ScrH() / 1.4 - #qLabels[type] * 35
			end
			addLogLine(color, phrase, length)

			local lbl = vgui.Create 'DLabel'
			lbl:SetPos(0, startY + #qLabels[type] * 35)
			lbl:SetSize(sw, 50)
			lbl:SetContentAlignment(5)
			lbl:SetAlpha(0)
			lbl:AlphaTo(alpha, .25, 0, function() end)
			lbl:SetFont(font)
			lbl:SetColor(color)
			lbl:SetExpensiveShadow(2, color_shadow)
			lbl:SetText(phrase)
			local pos = #qLabels[type] + 1
			qLabels[type][pos] = lbl
			timer.Simple(length, function()
				lbl:AlphaTo(0, .25, 0, function()
					lbl:Remove()
					qLabels[type][pos] = nil
				end)
			end)
		end)
	end
end

net.Receive('quest.sendLines', function()
	drawLines(net.ReadTable(), net.ReadInt(10), net.ReadInt(5))
end)