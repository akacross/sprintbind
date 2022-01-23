script_name("sprintbind")
script_author("checkdasound", "akacross")
script_version("0.2.0.4")
script_url("https://akacross.net/")

if getMoonloaderVersion() >= 27 then
	require 'libstd.deps' {
	   'fyp:mimgui',
	   'fyp:fa-icons-4',
	   'donhomka:mimgui-addons',
	   'donhomka:extensions-lite'
	}
end

require "lib.moonloader"
require "lib.sampfuncs"
require "extensions-lite"

local imgui, ffi = require 'mimgui', require 'ffi'
local new, str = imgui.new, ffi.string
local ped, h = playerPed, playerHandle
local vk = require 'vkeys'
local keys  = require 'game.keys'
local sampev = require 'lib.samp.events'
local mem = require 'memory'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local mimgui_addons = require 'mimgui_addons'
local faicons = require 'fa-icons'
local ti = require 'tabler_icons'

local function loadIconicFont(fontSize)
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    local iconRanges = imgui.new.ImWchar[3](ti.min_range, ti.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), fontSize, config, iconRanges)
end

local blank = {}
local sb = {
	tog = {true,false},
	key = {VK_F11,VK_SHIFT},
	delay = {10},
	autosave = false
} 

local mainc = imgui.ImVec4(0.92, 0.27, 0.92, 1.0)
local show = new.bool()
local bike, moto = {[481] = true, [509] = true, [510] = true}, {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}

path = getWorkingDirectory() .. '\\config\\' 
cfg = path .. 'sprintbind.ini'

function apply_custom_style()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   style.WindowRounding = 1.5
   style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
   style.FrameRounding = 1.0
   style.ItemSpacing = imgui.ImVec2(4.0, 4.0)
   style.ScrollbarSize = 13.0
   style.ScrollbarRounding = 0
   style.GrabMinSize = 8.0
   style.GrabRounding = 1.0
   style.WindowBorderSize = 0.0
   style.WindowPadding = imgui.ImVec2(4.0, 4.0)
   style.FramePadding = imgui.ImVec2(2.5, 3.5)
   style.ButtonTextAlign = imgui.ImVec2(0.5, 0.35)
 
   colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
   colors[clr.TextDisabled]           = ImVec4(0.7, 0.7, 0.7, 1.0)
   colors[clr.WindowBg]               = ImVec4(0.07, 0.07, 0.07, 1.0)
   colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.Border]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.4)
   colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.FrameBg]                = ImVec4(mainc.x, mainc.y, mainc.z, 0.7)
   colors[clr.FrameBgHovered]         = ImVec4(mainc.x, mainc.y, mainc.z, 0.4)
   colors[clr.FrameBgActive]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.9)
   colors[clr.TitleBg]                = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.TitleBgActive]          = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.TitleBgCollapsed]       = ImVec4(mainc.x, mainc.y, mainc.z, 0.79)
   colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
   colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
   colors[clr.ScrollbarGrab]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
   colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
   colors[clr.CheckMark]              = ImVec4(mainc.x + 0.13, mainc.y + 0.13, mainc.z + 0.13, 1.00)
   colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
   colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
   colors[clr.Button]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ButtonHovered]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.63)
   colors[clr.ButtonActive]           = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.Header]                 = ImVec4(mainc.x, mainc.y, mainc.z, 0.6)
   colors[clr.HeaderHovered]          = ImVec4(mainc.x, mainc.y, mainc.z, 0.43)
   colors[clr.HeaderActive]           = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.Separator]              = colors[clr.Border]
   colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
   colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
   colors[clr.ResizeGrip]             = ImVec4(mainc.x, mainc.y, mainc.z, 0.8)
   colors[clr.ResizeGripHovered]      = ImVec4(mainc.x, mainc.y, mainc.z, 0.63)
   colors[clr.ResizeGripActive]       = ImVec4(mainc.x, mainc.y, mainc.z, 1.0)
   colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
   colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
 end

-- imgui.OnInitialize() called only once, before the first render
imgui.OnInitialize(function()
	apply_custom_style() -- apply custom style
	local defGlyph = imgui.GetIO().Fonts.ConfigData.Data[0].GlyphRanges
	imgui.GetIO().Fonts:Clear() -- clear the fonts
	local font_config = imgui.ImFontConfig() -- each font has its own config
	font_config.SizePixels = 14.0;
	font_config.GlyphExtraSpacing.x = 0.1
	-- main font
	local def = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', font_config.SizePixels, font_config, defGlyph)
   
	local config = imgui.ImFontConfig()
	config.MergeMode = true
	config.PixelSnapH = true
	config.FontDataOwnedByAtlas = false
	config.GlyphOffset.y = 1.0 -- offset 1 pixel from down
	local fa_glyph_ranges = new.ImWchar[3]({ faicons.min_range, faicons.max_range, 0 })
	-- icons
	local faicon = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85(), font_config.SizePixels, config, fa_glyph_ranges)
	
	loadIconicFont(14)

	imgui.GetIO().ConfigWindowsMoveFromTitleBarOnly = true
	imgui.GetIO().IniFilename = nil
end)

imgui.OnFrame(function() return show[0] end,
function()
	local width, height = getScreenResolution()
	imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin(ti.ICON_SETTINGS .. 'Sprintbind', show, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		
		if imgui.Button(ti.ICON_DEVICE_FLOPPY.. 'Save') then
			saveIni()
		end 
		imgui.SameLine()
		if imgui.Button(ti.ICON_FILE_UPLOAD.. 'Load') then
			loadIni()
		end 
		imgui.SameLine()
		if imgui.Button(ti.ICON_ERASER .. 'Reset') then
			blankIni()
		end 
		imgui.SameLine()
		if imgui.Checkbox('Autosave', new.bool(sb.autosave)) then 
			sb.autosave = not sb.autosave 
			saveIni() 
		end  
	
		if imgui.Checkbox('Sprintbind', new.bool(sb.tog[1])) then sb.tog[1] = not sb.tog[1] end
		imgui.SameLine()
		imgui.PushItemWidth(40) 
		delay = new.int(sb.delay[1])
		if imgui.DragInt('Speed  [(0) Fastest]', delay, 0.5, 0, 200) then sb.delay[1] = delay[0] end
		imgui.PopItemWidth()
		if imgui.Checkbox('Bikebind', new.bool(sb.tog[2])) then sb.tog[2] = not sb.tog[2] end
	imgui.End()
end)

function main()
	blank = table.deepcopy(sb)
	if not doesDirectoryExist(path) then createDirectory(path) end
	if doesFileExist(cfg) then loadIni() else blankIni() end
	while not isSampAvailable() do wait(100) end
	
	sampRegisterChatCommand("sprintbind", function() show[0] = not show[0] end)
	sampfuncsLog("(Sprintbind: /sprintbind) Authors: " .. table.concat(thisScript().authors, ", "))
	while true do wait(0) 
		if wasKeyPressed(sb.key[1]) then sb.tog[1] = not sb.tog[1] sampAddChatMessage('Sprintbind: '..(sb.tog[1] and '{008000}on' or '{FF0000}off'), -1) saveIni() end
		if sb.tog[1] and getPadState(h, keys.player.SPRINT) == 255 and (isCharOnFoot(ped) or isCharInWater(ped)) then
			setGameKeyUpDown(keys.player.SPRINT, 255, sb.delay[1]) 
		end
		if not isPauseMenuActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() and not sampIsScoreboardOpen() then
			if isCharOnAnyBike(ped) then
				local veh = storeCarCharIsInNoSave(ped)
				local model = getCarModel(veh)
				if sb.tog[2] and isKeyDown(sb.key[2]) then
					if not isCarInAirProper(veh) then
						if bike[model] then 
							setGameKeyUpDown(keys.vehicle.ACCELERATE, 255, 0)
						elseif moto[model] then 
							setGameKeyUpDown(keys.vehicle.STEERUP_STEERDOWN, -128, 0)
						end
					end
				end
			end
		end	
	end
end

function onScriptTerminate(scr, quitGame) 
	if scr == script.this then 
		if sb.autosave then 
			saveIni() 
		end 
	end
end

function blankIni()
	sb = table.deepcopy(blank)
	saveIni()
	loadIni()
end

function loadIni() 
	local f = io.open(cfg, "r") 
	if f then 
		sb = decodeJson(f:read("*all")) 
		f:close() 
	end
end

function saveIni()
	if type(sb) == "table" then 
		local f = io.open(cfg, "w") 
		f:close() 
		if f then 
			f = io.open(cfg, "r+") 
			f:write(encodeJson(sb)) 
			f:close() 
		end 
	end
end

function setGameKeyUpDown(key, value, delay)
	setGameKeyState(key, value) 
	wait(delay) 
	setGameKeyState(key, 0)
end