local cfg = MapConfig
if game.GetMap() ~= cfg.MapID then return end

questsBank = questsBank or {}
questsBank.lines = questsBank.lines or {}
questsBank.fonts = questsBank.fonts or {}
local linesBank, fontsBank = questsBank.lines, questsBank.fonts

local readTable, readFloat, readString, readBool, readUInt, readColor = net.ReadTable, net.ReadFloat, net.ReadString, net.ReadBool, net.ReadUInt, net.ReadColor
local independently = 'independently'

-- font flags
local FONT_UNDERLINE	= 1
local FONT_ITALIC		= 2
local FONT_STRIKEOUT	= 4

-- HOOKS
local showHealth = true
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

net.Receive('quest.updateClientside', function()
	showHealth = readBool()
end)


-- RENDER
color_shadow = Color(0,0,0,200)

-- returns (x,y) of the top-left corner, and (width,height) of all lines
local function calcPosition(lines, font, left, top, right, bottom)
	local sw, sh = ScrW(), ScrH()
	local x, y = 0, 0

	-- calc lines' "bounding box"
	local tw, th = 0, 0
	surface.SetFont(font)
	for _, v in ipairs(lines) do
		local lw, lh = surface.GetTextSize(language.GetPhrase(cfg.LocalePrefix .. '.' .. v))
		tw = math.max(tw, lw)
		th = th + lh + 5
	end

	-- calc x,y based on margins
	if isnumber(left) then
		x = left * (0 < left and left < 1 and sw or 1)
	end
	if isnumber(top) then
		y = top * (0 < top and top < 1 and sh or 1)
	end
	if isnumber(right) then
		x = sw - right * (0 < right and right < 1 and sw or 1) - tw
	end
	if isnumber(bottom) then
		y = sh - bottom * (0 < bottom and bottom < 1 and sh or 1) - th
	end

	return x, y, tw, th
end

local bindings = {
	['[$nl]'] = '\n',
}
local function drawLines(uid, lines, length, fadein, fadeinstyle, fadeindelay, fadeout, fadeoutstyle, fadeoutdelay, showinlogs, color, font, align, margins)
	local startX, startY, linesWidth, linesHeight = calcPosition(lines, font, margins.left, margins.top, margins.right, margins.bottom)
	
	linesBank[uid] = linesBank[uid] or {}
	for i, key in ipairs(lines) do

		-- determine line length
		local lineLength
		if length ~= -1 then
			lineLength = length
			if fadeinstyle == independently then
				lineLength = lineLength - (i-1)*(fadeindelay+fadein)
			end
			if fadeoutstyle == independently then
				lineLength = lineLength + (i-1)*(fadeoutdelay+fadeout)
			end
		end

		local phrase = bindings[key] or language.GetPhrase(cfg.LocalePrefix .. '.' .. key)
		timer.Simple(fadeinstyle == independently and (i-1)*(fadeindelay+fadein) or 0, function()

			if showinlogs then
				addLogLine(color, phrase, lineLength)
			end

			surface.SetFont(font)
			local lw, lh = surface.GetTextSize(phrase)
			local x = startX
			if align == TEXT_ALIGN_CENTER then
				x = startX - lw/2
			elseif align == TEXT_ALIGN_RIGHT then
				x = startX + (linesWidth - lw)
			end

			local lbl = vgui.Create 'DLabel'
			lbl:SetPos(x, startY + (i-1) * lh)
			lbl:SetSize(lw, lh)
			lbl:SetAlpha(0)
			lbl:AlphaTo(231, fadein, 0, function() end)
			lbl:SetFont(font)
			lbl:SetColor(color)
			lbl:SetExpensiveShadow(2, color_shadow)
			lbl:SetText(phrase)
			local idx = #linesBank[uid] + 1
			linesBank[uid][idx] = lbl

			if not lineLength then return end
			timer.Simple(lineLength, function()
				if IsValid(lbl) then
					lbl:AlphaTo(0, fadeout, 0, function()
						lbl:Remove()
						linesBank[uid][idx] = nil
						if table.IsEmpty(linesBank[uid]) then
							linesBank[uid] = nil
						end
					end)
				end
			end)
	
		end)

	end
end

local function drawTypedLines(uid, lines, length, fadein, fadeinstyle, fadeindelay, fadeout, fadeoutstyle, fadeoutdelay, showinlogs, type)
	local data = cfg.TypesData[type]
	drawLines(uid, lines, length, fadein, fadeinstyle, fadeindelay, fadeout, fadeoutstyle, fadeoutdelay, showinlogs, data.color, data.font, data.alignment, data.margins)
end

local function drawCustomLines(uid, lines, length, fadein, fadeinstyle, fadeindelay, fadeout, fadeoutstyle, fadeoutdelay, showinlogs, margins, fontName, fontSize, fontWeight, fontData, color, alignment)
	if 0 < fontSize and fontSize < 1 then
		fontSize = math.floor(fontSize * ScrH())
	end
	local font = ('%d_%d_%d_%d'):format(util.CRC(fontName), fontSize, fontWeight, fontData)
	if not fontsBank[font] then
		surface.CreateFont(font, {
			font = fontName,
			extended = true,
			size = fontSize,
			weight = fontWeight,
			underline = bit.band(fontData, FONT_UNDERLINE) == FONT_UNDERLINE,
			italic = bit.band(fontData, FONT_ITALIC) == FONT_ITALIC,
			strikeout = bit.band(fontData, FONT_STRIKEOUT) == FONT_STRIKEOUT,
		})
		fontsBank[font] = true
	end
	drawLines(uid, lines, length, fadein, fadeinstyle, fadeindelay, fadeout, fadeoutstyle, fadeoutdelay, showinlogs, color, font, alignment, margins)
end

net.Receive('quest.sendTyped', function()
	drawTypedLines(readUInt(31), readTable(), readFloat(), readFloat(), readString(), readFloat(), readFloat(), readString(), readFloat(), readBool(), readString())
end)

net.Receive('quest.sendCustom', function()
	drawCustomLines(readUInt(31), readTable(), readFloat(), readFloat(), readString(), readFloat(), readFloat(), readString(), readFloat(), readBool(), readTable(), readString(), readFloat(), readUInt(11), readUInt(3), readColor(), readUInt(2))
end)

net.Receive('quest.hide', function()

	local uid = readUInt(31)
	local fadeout = readFloat()
	local style = readString()
	local delay = readFloat()
	if not linesBank[uid] then return end

	local i = 1
	for idx, line in pairs(linesBank[uid]) do
		timer.Simple(fadeoutstyle == independently and (i-1)*(delay+fadeout) or 0, function()
			if IsValid(line) then
				line:AlphaTo(0, fadeout, 0, function()
					line:Remove()
					linesBank[uid][idx] = nil
					if table.IsEmpty(linesBank[uid]) then
						linesBank[uid] = nil
					end
				end)
			end
		end)
		i = i + 1
	end

end)