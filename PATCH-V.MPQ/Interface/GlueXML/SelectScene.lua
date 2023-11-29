---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                1     2  3  4  5    6      7                                                  8                                                       9          10           11         12        13				14
--modelData: { sceneID, x, y, z, o, scale, alpha, [{ enabled[,omni,dirX,dirY,dirZ,ambIntensity[,ambR,ambG,ambB[,dirIntensity[,dirR,dirG,dirB]]]] }], sequence, widthSquish, heightSquish, path [,referenceID] [,cameraModel] }
--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .mdx
	referenceID:		number  - mainly used for making changes while the scene is playing | example:

	local m = selectScene_GetModel(1)	<- selectScene_GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end

	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]
--[[ LIGHT:
	enabled:			number	- appears to be 1 for lit and 0 for unlit
    omni:				number	- ?? (default of 0)
    dirX, dirY, dirZ:	numbers	- vector from the origin to where the light source should face
    ambIntensity:		number	- intensity of the ambient component of the light source
    ambR, ambG, ambB:	numbers	- color of the ambient component of the light source
    dirIntensity:		number	- intensity of the direct component of the light source
    dirR, dirG, dirB:	numbers	- color of the direct component of the light source
]]
--[[ METHODS:
	selectScene_GetModelData(referenceID / sceneID, (bool) get-all-scene-models)	table									- gets the model data table out of selectScene_ModelList (returns a table with all model datas that have the same referenceID) or if bool is true from the scene
	selectScene_GetModel(referenceID / sceneID, (bool) get-all-scene-models)		table									- gets all models with the same referenceID or the same sceneID (if bool is true)
	SetScene(sceneID)													nil										- sets the current scene to the sceneID given to the function
	selectScene_GetScene([sceneID])													sceneID, sceneData, models, modeldatas	- gets all information of the current scene [of the sceneID]
	convert_to_16_to_9([x][,y])											x, y 									- returns the x or y (or both) input within the 16:9 resolution selectscene field (useful for mouse positions across resolutions)

	some helpful globals:
	selectScene_ModelList.sceneCount	number	- the count of how many scenes exist
	selectScene_ModelList.modelCount	number	- the count of how many models exist
]]
--[[ CREDITS:
	Made by Mordred P.H.

	Thanks to:
	Soldan - helping me with all the model work
	Chase - finding a method to copy cameras on the fly
	Stoneharry - bringing me to the conclusion that blizzard frames are never fullscreen, so it works with every resolution
	Blizzard - for making it almost impossible to make it work properly
]]
-------------------------------------------------------------------------
--                   1                2
--sceneData: {time_in_seconds, background_path}   --> (index is scene id)

selectScene_ModelList = {
	loaded = false,									-- safety so anything else happens after loading (leave at 0)
	blend_start_duration = 0.75,						-- beginning fade animation duration in seconds
	max_scenes = 2,									-- number of scenes you use to shuffle through
	fade_duration = 3,								-- fade animation duration in seconds (to next scene if more than 1 exists)
	current_scene = 2,								-- current scene that gets displayed
	use_random_starting_scene = false,				-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
	shuffle_scenes_randomly = false,				-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
	select_music_path = "Interface/Selectscreen/Music/huntcraftsong_spinup.mp3",						-- path to the music / false if no music
	select_ambience_name = "Interface/Selectscreen/Music/hunt_ambient.mp3",	-- name in SoundEntries.dbc / false if no ambience
	sceneData = {
		{-1, "Interface/Selectscreen/background.blp"},
		{-1, {0.7,0.7,0.7,1}},
		{-1, "Interface/Selectscreen/background4_wide_color.blp"}
	},

	-- Scene: 1
	{1, 1.600, 1.015, 0.000, 4.237, 0.024, 0.106, _, 1, 1, 1, "World/Expansion02/doodads/scholazar/waterfalls/sholazarsouthoceanwaterfall-06.m2", _, _},
	--{1, 0.043, 0.540, 0.000, 0.000, 0.055, 1.000, _, 1, 1, 1, "Spells/Firenova_area.m2", 11, _},

	--SmashPlayer
	--{2, 0, 0.55, 0, 0, 0.08, 1, _, 1, 1, 1, "World/Expansion02/doodads/zuldrak/gundrak/gundrak_elevator_01.m2", _,_},
	--{2, 0, 0, 0, 0, 0.15, 1, _, 2, 1, 1, "Creature/Medivh/medivh.m2", 1000,_}


-- id,x,y,z,o,s,a

	{2, 1.416, 0.0028, -2.7, 6.228, 0.75, 1, _, 0, 1, 1, "world/generic/dwarf/passive doodads/excavationbannerstands/excavationbannerstand.m2", 1000,_},
	{2, 1.481, 0.128, -2.7, 6.228, 0.55, 1, _, 0, 1, 1, "world/generic/human/passive doodads/banners/allianceveteranbanner01.m2", 1000,_},
	{2, 1.183, -0.102, 0, 0.745, 0.266, 1, _, 0, 1, 1, "world/azeroth/duskwood/passivedoodads/bush/duskwoodbush03.m2", 1000,_},
	{2, -0.445, -0.14, 0, 6.17, 0.2, 1, _, 0, 1, 1, "world/azeroth/duskwood/passivedoodads/bush/duskwoodbush03.m2", 1000,_},
	{2, -1.345, -0.032, 0, 6.17, 0.3, 1, _, 0, 1, 1, "world/azeroth/duskwood/passivedoodads/bush/duskwoodbush06.m2", 1000,_},
}

--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .mdx
	referenceID:		number  - mainly used for making changes while the scene is playing | example:

	local m = selectScene_GetModel(1)	<- selectScene_GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end

	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]

-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-----------------------------------------------!!!!!!!!!!!!!!!!!!!- DO NOT CHANGE BELOW HERE, EXCEPT SCENESCRIPTS -!!!!!!!!!!!!!!!!!!!----------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------

local timed_update, blend_timer

function selectScene_randomScene()
	return (time() % selectScene_ModelList.max_scenes) + 1
end

-- creates a scene object that gets used internaly
function selectScene_newScene()
	local s = {parent = CreateFrame("Frame",nil,SelectScene),
				background = selectScene_ModelList.sceneData[#s_M+1 or 1][2],
				duration = selectScene_ModelList.sceneData[#s_M+1 or 1][1]}
	s.parent:SetSize(SelectScene:GetWidth(), SelectScene:GetHeight())
	s.parent:SetPoint("CENTER")
	s.parent:SetFrameStrata("MEDIUM")
	table.insert(s_M, s)
	return s
end

-- creates a new model object that gets used internally but also can be altered after loading
function selectScene_newModel(parent,alpha,light,wSquish,hSquish,camera)
	local mod = CreateFrame("Model",nil,parent)

	light = light or {1, 0, 0, -0.707, -0.707, 0.8, 0.9, 0.9, 1.0, 0.2, 0.7, 0.7, 1.0}
	mod:SetModel(camera or "Character/Human/Male/HumanMale.mdx")
	mod:SetSize(SelectScene:GetWidth() / wSquish, SelectScene:GetHeight() / hSquish)
	mod:SetPoint("CENTER")
	mod:SetCamera(1)
	mod:SetLight(unpack(light))
	mod:SetAlpha(alpha)

	return mod
end

-- starts the routine for loading all models and scenes
function selectScene_Generate_M()
	selectScene_ModelList.loaded = false
	s_M = {}
	timed_update, blend_timer = 0, 0
	selectScene_ModelList.sceneCount = #selectScene_ModelList.sceneData

	local counter = 0
	for i=1, selectScene_ModelList.sceneCount do
		local s = selectScene_newScene()

		for num, m in pairs(selectScene_ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == i then
					table.insert(s, num, selectScene_newModel(s.parent, m[7], m[8], m[10], m[11], m[14]))
					counter = counter + 1
					selectScene_ModelList.lastModelNum = num
				end
			end
		end

		s.parent:Hide()
		if i == selectScene_ModelList.current_scene then
			if type(s.background)=="table" then
				SelectScreenBackground:SetTexture(s.background[1],s.background[2],s.background[3],s.background[4])
			else
				SelectScreenBackground:SetTexture(s.background)
			end
		end
	end
	selectScene_ModelList.modelCount = counter
	selectScene_ModelList.loaded = true
end

------- updating and methods

function SelectScreen_OnLoad(self)
	local width = GlueParent:GetSize()

	if selectScene_ModelList.select_ambience_name then
		PlayGlueAmbience(selectScene_ModelList.select_ambience_name,5.0)
	end

	if selectScene_ModelList.use_random_starting_scene then
		selectScene_ModelList.current_scene = selectScene_randomScene()
	end

	-- main frame for displaying and positioning of the whole selectscreen
	SelectScene = CreateFrame("Frame","SelectScene",self)
		SelectScene:SetSize(width, (width/16)*9)
		SelectScene:SetPoint("CENTER", self, "CENTER", 0,0)
		SelectScene:SetFrameStrata("LOW")

	-- main background that changes according to the scene
	SelectScreenBackground = SelectScene:CreateTexture("SelectScreenBackground","LOW")
		SelectScreenBackground:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectScreenBackground:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)

	SelectScreenBlackBoarderTOP = self:CreateTexture("SelectScreenBlackBoarderTOP","OVERLAY")
		SelectScreenBlackBoarderTOP:SetTexture(0,0,0,1)
		SelectScreenBlackBoarderTOP:SetHeight(500)
		SelectScreenBlackBoarderTOP:SetPoint("BOTTOMLEFT", SelectScene, "TOPLEFT", 0,0)
		SelectScreenBlackBoarderTOP:SetPoint("BOTTOMRIGHT", SelectScene, "TOPRIGHT", 0,0)

	SelectScreenBlackBoarderBOTTOM = self:CreateTexture("SelectScreenBlackBoarderBOTTOM","OVERLAY")
		SelectScreenBlackBoarderBOTTOM:SetTexture(0,0,0,1)
		SelectScreenBlackBoarderBOTTOM:SetHeight(500)
		SelectScreenBlackBoarderBOTTOM:SetPoint("TOPLEFT", SelectScene, "BOTTOMLEFT", 0,0)
		SelectScreenBlackBoarderBOTTOM:SetPoint("TOPRIGHT", SelectScene, "BOTTOMRIGHT", 0,0)

	SelectScreenBlend = self:CreateTexture("SelectScreenBlend","OVERLAY")
		SelectScreenBlend:SetTexture(0,0,0,1)
		SelectScreenBlend:SetAllPoints(GlueParent)

	selectScene_Generate_M()
end

function SelectScreen_OnUpdate(self,dt)
	if selectScene_ModelList.loaded then
		if timed_update then
			if timed_update > 2 then
				for num, m in pairs(selectScene_ModelList) do
					if type(m)=="table" and num ~= "sceneData" and m[1] <= selectScene_ModelList.max_scenes then
						local mod = s_M[m[1]][num]
						mod:SetModel(m[12])
						mod:SetPosition(m[4], m[2], m[3])
						mod:SetFacing(m[5])
						mod:SetModelScale(m[6])
						mod:SetSequence(m[9])
					end
				end

				s_M[selectScene_ModelList.current_scene].parent:Show()
				Selectscreen_OnLoad()
				selectScene_Scene_OnStart(selectScene_ModelList.current_scene)
				blend_start = 0
				timed_update = false
				selectScene_ModelList.loaded = false
			else
				timed_update = timed_update + 1
			end
		end
	end

	if s_M then
		-- Start blend after the selectscreen loaded to hide the setting up frame
		if blend_start then
			if blend_start < selectScene_ModelList.blend_start_duration then
				SelectScreenBlend:SetAlpha( 1 - blend_start/selectScene_ModelList.blend_start_duration )
				blend_start = blend_start + dt
			else
				SelectScreenBlend:SetAlpha(0)
				blend_start = false
			end
		end

		local cur = s_M[selectScene_ModelList.current_scene]
		if cur.duration ~= -1 then
			-- Scene and blend timer for next scene and blends between the scenes
			if cur.duration < blend_timer then
				if selectScene_ModelList.max_scenes > 1 then
					local blend = blend_timer - cur.duration
					if blend < selectScene_ModelList.fade_duration then
						SelectScreenBlend:SetAlpha( 1 - math.abs( 1 - (blend*2 / selectScene_ModelList.fade_duration) ) )

						if blend*2 > selectScene_ModelList.fade_duration and not s_nextCset then
							s_nextC = selectScene_randomScene()
							if shuffle_scenes_randomly then
								if selectScene_ModelList.current_scene == s_nextC then
									s_nextC = ((selectScene_ModelList.current_scene+1 > selectScene_ModelList.max_scenes) and 1) or selectScene_ModelList.current_scene + 1
								end
							else
								s_nextC = ((selectScene_ModelList.current_scene+1 > selectScene_ModelList.max_scenes) and 1) or selectScene_ModelList.current_scene + 1
							end
							s_nextCset = true

							local new = s_M[s_nextC]
							cur.parent:Hide()
							new.parent:Show()
							if type(new.background)=="table" then
								SelectScreenBackground:SetTexture(new.background[1],new.background[2],new.background[3],new.background[4])
							else
								SelectScreenBackground:SetTexture(new.background)
							end
							selectScene_Scene_OnEnd(selectScene_ModelList.current_scene)
							selectScene_Scene_OnStart(s_nextC)
						end

						blend_timer = blend_timer + dt
					else
						selectScene_ModelList.current_scene = s_nextC
						s_nextCset = false
						blend_timer = 0
						SelectScreenBlend:SetAlpha(0)
					end
				else
					blend_timer = 0
					selectScene_Scene_OnEnd(selectScene_ModelList.current_scene)
					selectScene_Scene_OnStart(selectScene_ModelList.current_scene)
				end
			else
				blend_timer = blend_timer + dt
			end
		end

		selectScene_SceneUpdate(dt, selectScene_ModelList.current_scene, blend_timer, selectScene_ModelList.sceneData[selectScene_ModelList.current_scene][1])
	end
end

function selectScene_SetScene(sceneID)
	s_M[selectScene_ModelList.current_scene].parent:Hide()
	s_M[sceneID].parent:Show()
	if type(s_M[sceneID].background)=="table" then
		SelectScreenBackground:SetTexture(s_M[sceneID].background[1],s_M[sceneID].background[2],s_M[sceneID].background[3],s_M[sceneID].background[4])
	else
		SelectScreenBackground:SetTexture(s_M[sceneID].background)
	end
	selectScene_Scene_OnEnd(selectScene_ModelList.current_scene)
	selectScene_Scene_OnStart(sceneID)
	selectScene_ModelList.current_scene = sceneID
end

function selectScene_GetScene(sceneID)
	local curScene = selectScene_ModelList.current_scene
	if sceneID then
		if sceneID <= selectScene_ModelList.max_scenes and sceneID > 0 then
			curScene = sceneID
		end
	end
	return curScene, selectScene_ModelList.sceneData[curScene], selectScene_GetModel(curScene, true), selectScene_GetModelData(curScene, true)
end

function selectScene_GetModelData(refID, allSceneModels)
	local data, count = {}, 0
	if allSceneModels then
		for num, m in pairs(selectScene_ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		for num, m in pairs(selectScene_ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[13] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	end
end

function selectScene_GetModel(refID, allSceneModels)
	local data, count = {} ,0
	if allSceneModels then
		for num, m in pairs(selectScene_ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, s_M[m[1]][num])
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		local mData = selectScene_GetModelData(refID)
		if mData then
			for num, m in pairs(mData) do
				table.insert(data, num, s_M[m[1]][num])
				count = count + 1
			end
			return (count > 0 and data) or false
		else
			return false
		end
	end
end

-- overwrite GlueParent function

function selectScene_SetGlueScreen(name)
	local newFrame;
	for index, value in pairs(GlueScreenInfo) do
		local frame = _G[value];
		if ( frame ) then
			frame:Hide();
			if ( index == name ) then
				newFrame = frame;
			end
		end
	end

	if ( newFrame ) then
		newFrame:Show();
		SetCurrentScreen(name);
		SetCurrentGlueScreenName(name);
		if ( name == "select" ) then
			if select_music_path then
				--PlayMusic(select_music_path)
			end
			if select_ambience_name then
				PlayGlueAmbience(select_ambience_name,5.0)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
------									SCENE SCRIPTING PART									------
------------------------------------------------------------------------------------------------------

-- function selectScene_run right after everything is set up (run before first selectScene_Scene_OnStart())
function Selectscreen_OnLoad()
	LANTERN = 0
	FIRE = 0
	THUNDER = 0
	SelectscreenColorCorrection = CharacterSelect:CreateTexture(nil,"LOW")
		SelectscreenColorCorrection:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectscreenColorCorrection:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)
		SelectscreenColorCorrection:SetTexture(0.3,0.3,0.4,1)
		SelectscreenColorCorrection:SetBlendMode("MOD")
		SelectscreenColorCorrection:Hide()

	SelectscreenLightHit = SelectScene:CreateTexture(nil,"OVERLAY")
		SelectscreenLightHit:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectscreenLightHit:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)
		SelectscreenLightHit:SetAlpha(0.2)
		SelectscreenLightHit:SetTexture("Interface/Selectscreen/LightHit.blp")
		SelectscreenLightHit:SetBlendMode("ADD")
		SelectscreenLightHit:Hide()

	SelectscreenHighlight = CharacterSelect:CreateTexture(nil,"BACKGROUND")
		SelectscreenHighlight:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectscreenHighlight:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)
		SelectscreenHighlight:SetAlpha(0.1)
		SelectscreenHighlight:SetTexture("Interface/Selectscreen/Highlight.blp")
		SelectscreenHighlight:SetBlendMode("ADD")
		SelectscreenHighlight:Hide()

	SelectscreenLanternGradient = CharacterSelect:CreateTexture(nil,"BACKGROUND")
		SelectscreenLanternGradient:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectscreenLanternGradient:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)
		SelectscreenLanternGradient:SetAlpha(0.15)
		SelectscreenLanternGradient:SetTexture("Interface/Selectscreen/LanternGradient.blp")
		SelectscreenLanternGradient:SetBlendMode("ADD")
		SelectscreenLanternGradient:Hide()

	SelectscreenFireGradient = CharacterSelect:CreateTexture(nil,"BACKGROUND")
		SelectscreenFireGradient:SetPoint("TOPRIGHT", SelectScene, "TOPRIGHT", 0, 125)
		SelectscreenFireGradient:SetPoint("BOTTOMLEFT", SelectScene, "BOTTOMLEFT", -1, -125)
		SelectscreenFireGradient:SetAlpha(0.25)
		SelectscreenFireGradient:SetTexture("Interface/Selectscreen/FireGradient.blp")
		SelectscreenFireGradient:SetBlendMode("ADD")
		SelectscreenFireGradient:Hide()

	SelectscreenHighUpLight = CharacterSelect:CreateFontString("SelectscreenHighUpLight", "BACKGROUND", "GlueFontNormal")
		SelectscreenHighUpLight:SetPoint("TOP", 8, -125)
		SelectscreenHighUpLight:SetText("b".."y".."   ".."s_M".."o".."r"..'d'..[[r]]..'e'.."d")
		SelectscreenHighUpLight:Hide()

	local mData = selectScene_GetModelData(1,true)
	valve_timer, skull_timer = false, false
	for num,m in pairs(selectScene_GetModel(1,true)) do
		m:SetLight(1, 0, 0, 0, 0, 0.6, 1.0, 0.8, 0.8, 0.5, 1.0, 0.9, 0.8)
		if mData[num][13] == 19 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
			m:SetScript("OnUpdate", function()
				if skull_timer and skull_timer > 2 then m:SetModel("World/Generic/collision/collision_pcsize.m2"); skull_timer = false;
				elseif skull_timer then m:SetAlpha((1 - abs(skull_timer-1))*2) end end)
		elseif mData[num][13] == 18 then
			m:SetPoint("CENTER",-480,-100)
			m:SetScript("OnUpdate", function() if valve_timer and valve_timer > 3 then m:SetModel("World/generic/human/passive doodads/valves/deadminevalve.m2"); valve_timer = false; end end)
		elseif mData[num][13] == 14 or mData[num][13] == 11 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
			m:SetScript("OnAnimFinished", function() m:SetModel("World/Generic/collision/collision_pcsize.m2") end)
		elseif mData[num][13] == 13 or mData[num][13] == 12 or mData[num][13] == 10 or mData[num][13] == 20 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
		elseif mData[num][13] == 9 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 0.6, 0.6, 1.0)
			m:SetScript("OnUpdate", selectScene_musicboxUpdate)
		elseif mData[num][13] == 8 then
			local mWidth = 220
			m:SetSize(mWidth,mWidth/16*9)
			m:SetModelScale(1)
			m:SetPoint("CENTER",10,-155)
		elseif mData[num][13] == 3 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 0.6, 0.6, 1.0)
		elseif mData[num][13] == 2 then
			m:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8)
		elseif mData[num][13] == 1 then
			m:EnableMouse(true)
			m:SetScript("OnMouseDown", selectScene_mordredClicked)
			m:SetScript("OnUpdate", selectScene_mordredUpdate)
			MORDRED_STATE = "USE"
		end
	end
end

-- update function selectScene_that gets called each frame
local last_thunder, thunder_stage = 0, 1
local thunder_strength = 0
local thunder_timer = (random(3)*2)
local noChangeScene_timer = 0

function selectScene_SceneUpdate(dt, sceneID, timer, sceneTime)
	if sceneID == 1 then
		timer = noChangeScene_timer
		if timer - last_thunder > thunder_timer then
			if thunder_strength == 1 then
				if thunder_stage == 1 then THUNDER = 0.2; selectScene_updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.1 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0.25; selectScene_updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.2 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 0.4 then THUNDER = 0.1; selectScene_updateColorCorrect(); thunder_stage = 6;
				elseif thunder_stage == 6 and timer - last_thunder - thunder_timer > 0.45 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 7;
				elseif thunder_stage == 7 and timer - last_thunder - thunder_timer > 5 then
					PlaySoundFile("Interface\\Selectscreen\\Music\\Thunder_Distant.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			elseif thunder_strength == 2 then
				if thunder_stage == 1 then THUNDER = 0.4; selectScene_updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.01 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.1 then THUNDER = 0.1; selectScene_updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 0.25 then THUNDER = 0.32; selectScene_updateColorCorrect(); thunder_stage = 6;
				elseif thunder_stage == 6 and timer - last_thunder - thunder_timer > 0.27 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 7;
				elseif thunder_stage == 7 and timer - last_thunder - thunder_timer > 3.5 then
					PlaySoundFile("Interface\\Selectscreen\\Music\\Thunder_Mid.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			elseif thunder_strength == 3 then
				if thunder_stage == 1 then THUNDER = 0.5; selectScene_updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.05 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0.4; selectScene_updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.2 then THUNDER = 0; selectScene_updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 1 then
					PlaySoundFile("Interface\\Selectscreen\\Music\\Thunder_Near.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			end
		end
		noChangeScene_timer = noChangeScene_timer + dt
	end
end

-- on end function selectScene_that gets called when the scene ends
function selectScene_Scene_OnEnd(sceneID)
	if sceneID == 1 then
		SelectscreenColorCorrection:Hide()
		SelectscreenLightHit:Hide()
		SelectscreenHighlight:Hide()
		SelectscreenLanternGradient:Hide()
		SelectscreenFireGradient:Hide()
		SelectscreenHighUpLight:Hide()
	end
end

-- on start function selectScene_that gets called when the scene starts
function selectScene_Scene_OnStart(sceneID)
	--PlayMusic("Interface/Selectscreen/Music/huntcraftsong_spinup_ambient.mp3")
	if sceneID == 1 then
		SelectscreenColorCorrection:Show()
		SelectscreenLightHit:Show()
		SelectscreenHighlight:Show()
	end
end




-- some scenescript functions

function selectScene_updateColorCorrect()
	SelectscreenColorCorrection:SetTexture(0.3 + LANTERN + FIRE*3 + THUNDER,0.3 + LANTERN + FIRE*3 + THUNDER,0.4 + FIRE*2 + THUNDER,1)
	SelectscreenHighlight:SetAlpha(0.1 - (LANTERN + FIRE))
	SelectscreenLightHit:SetAlpha(0.2 - (LANTERN + FIRE)*2 + THUNDER)
end

function selectScene_lanternClicked()
	SelectscreenLanternGradient:Show()

	local mData = selectScene_GetModelData(1,true)
	for num,m in pairs(selectScene_GetModel(1,true)) do
		if mData[num][13] == 4 or mData[num][13] == 18 then
			m:SetLight(1, 0, 0.5, 1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 5 then
			m:SetLight(1, 0, 0.5, 1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 6 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 7 then
			m:SetModel("World/Generic/human/passive doodads/lanterns/generallantern01.m2")
		end
	end

	LANTERN = 0.05
	selectScene_updateColorCorrect()
end

function selectScene_fireClicked()
	SelectscreenFireGradient:Show()

	local mData = selectScene_GetModelData(1,true)
	for num,m in pairs(selectScene_GetModel(1,true)) do
		if mData[num][13] == 8 then
			m:SetModel("World/Generic/human/passive doodads/firewood/firewoodpile01.m2")
		elseif mData[num][13] == 11 then
			m:SetModel("Spells/Firenova_area.m2")
		elseif mData[num][13] == 15 then
			m:SetLight(1, 0, -0.5, -1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 16 then
			m:SetLight(1, 0, -1, 0, 0.5, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 17 or mData[num][13] == 3 or mData[num][13] == 9 then
			m:SetLight(1, 0, -0.5, 1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		end
	end

	FIRE = 0.05
	selectScene_updateColorCorrect()
end

local musicbox_timer, mbtime = false, 185
function selectScene_musicboxUpdate(self, dt)
	if musicbox_timer then
		if time()-musicbox_timer >= 1.5 and not MBEFFECT then
			local mData = selectScene_GetModelData(1,true)
			for num,m in pairs(selectScene_GetModel(1,true)) do
				if mData[num][13] == 10 then
					m:SetModel("Spells/Heal_low_base.m2")
				elseif mData[num][13] == 13 then
					m:SetModel("Spells/Holy_precast_high_hand.m2")
				end
			end
			MBEFFECT = true
		elseif MBEFFECT and time()-musicbox_timer >= 3 then
			local mData = selectScene_GetModelData(1,true)
			for num,m in pairs(selectScene_GetModel(1,true)) do
				if mData[num][13] == 10 or mData[num][13] == 13 then
					m:SetSequenceTime(1,0)
				end
			end
		end

		if time()-musicbox_timer >= mbtime then
			local mData = selectScene_GetModelData(1,true)
			for num,m in pairs(selectScene_GetModel(1,true)) do
				if mData[num][13] == 9 then
					m:SetSequence(146)
				elseif mData[num][13] == 10 or mData[num][13] == 13 then
					m:SetModel("World/Generic/collision/collision_pcsize.m2")
					MBEFFECT = false
				end
			end
			StopMusic()
			musicbox_timer = false
			MUSICBOX_CLICKED = false
			MORDRED_STATE = "SIT_RETURN"
			mordred_timer = 0
		end
	end
end

function selectScene_musicboxClicked()
	local num,m = next(selectScene_GetModel(9))
	m:SetSequence(148)
	musicbox_timer = time()
	PlayMusic("Interface/Selectscreen/Music/dswii.mp3")

	local num,m = next(selectScene_GetModel(14))
	m:SetModel("Spells/Holy_impactdd_uber_chest.m2")
end

function selectScene_mordredClicked(self)
	local mx,my = GetCursorPosition()
	if MORDRED_STATE == "USE" then
		if mx > 0 and my < 289 and my > 197 and mx < 55 and not LANTERN_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "LANTERN"
			LANTERN_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		elseif mx > 300 and my < 470 and mx < 770 and my > 103 and not FIRE_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "FIRE"
			FIRE_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		elseif mx > 800 and my < 320 and mx < 1298 and my > 0 and not MUSICBOX_CLICKED and FIRE_CLICKED and LANTERN_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "MUSICBOX"
			MUSICBOX_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		end
	end
	if not valve_timer then
		if mx > 138 and mx < 168 and my > 225 and my < 250 then
			local num,m = next(selectScene_GetModel(18))
			m:SetModel("World/generic/human/passive doodads/valvesteam/deadminevalvesteam02.m2")
			valve_timer = 0
		end
	end
	if not skull_timer then
		if mx > 1199 and mx < 1287 and my > 156 and my < 220 then
			for num,m in pairs(selectScene_GetModel(19)) do
				m:SetModel("World/Kalimdor/silithus/passivedoodads/ahnqirajglow/quirajglow.m2")
			end
			skull_timer = 0
		end
	end
	if skull_timer and valve_timer then
		if mx > 646 and mx < 734 and my > 509 and my < 618 then
			local num,m = next(selectScene_GetModel(20))
			m:SetModel("World/generic/passivedoodads/floatingdebris/floatingboardsburning01.m2")
			SelectscreenHighUpLight:Show()
		end
	end
end

-- MOVEMENT EVENTS

function selectScene_mUse(timer, dt)
	if timer > 0.5 then
		local num,m = next(selectScene_GetModel(1))
		m:SetSequenceTime(63,1700)
		mordred_timer = -dt
		if random((time()%100)+1) == 1 then
			MORDRED_STATE = "USE_DRINK"
		end
	end
end

function selectScene_mUseDrink(timer, dt)
	if timer > 5.5 and not DRINKING then
		local num,m = next(selectScene_GetModel(1))
		m:SetSequence(63)
		MORDRED_STATE = "USE"
		mordred_timer = -dt
		DRINKING = false
	elseif timer > 4.5 and DRINKING then
		local num,m = next(selectScene_GetModel(1))
		m:SetSequence(8)
		DRINKING = false
	elseif timer > 1.5 and timer < 4 and not DRINKING then
		local num,m = next(selectScene_GetModel(1))
		m:SetSequence(61)
		DRINKING = true
	end
end

function selectScene_mLantern(timer, dt)
	local num,m = next(selectScene_GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 6.2 then m:SetFacing(m:GetFacing() + 0.04)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if z < 0.6 then m:SetPosition(z+0.006,x-0.0025,y-0.001)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 5 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(63); mAnim_set = nil; mStartA = timer; end
		if timer - mStartA > 3.5 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.75 and mAnim_set == nil then selectScene_lanternClicked(); mAnim_set = true; end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 3.2 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 6; mAnim_set = false; m:SetFacing(3.224); end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if z > 0 then m:SetPosition(z-0.006,x+0.0028,y+0.0011)
		else mAnim_set = false; MORDRED_STATE = "USE"; m:SetSequence(63); local num,mD = next(selectScene_GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); end
	end
end

function selectScene_mFire(timer, dt)
	local num,m = next(selectScene_GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 1.7 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x < 0 then m:SetPosition(z,x+0.012,y)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < math.pi then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(52); mAnim_set = nil; mStartA = timer;
		local num,mC = next(selectScene_GetModel(12)); mC:SetModel("Spells/Fire_precast_hand.m2"); end
		if timer - mStartA > 3 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.5 and mAnim_set == nil then m:SetSequence(54); mAnim_set = true; selectScene_fireClicked();
		local num,mC = next(selectScene_GetModel(12)); mC:SetModel("World/Generic/collision/collision_pcsize.m2"); end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 5 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 6; mAnim_set = false; end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x > -0.721 then m:SetPosition(z,x-0.012,y)
		else local num,mD = next(selectScene_GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); mordred_stage = 7; mAnim_set = false; end

	elseif mordred_stage == 7 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 3.224 then m:SetFacing(m:GetFacing() - 0.03)
		else mAnim_set = false; m:SetFacing(3.224); MORDRED_STATE = "USE"; m:SetSequence(63); end
	end
end

function selectScene_mMusicBox(timer, dt)
	local num,m = next(selectScene_GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 1 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x < 0.5 then m:SetPosition(z+0.006,x+0.01,y-0.0006)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 1.55 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(50); mAnim_set = nil; mStartA = timer; end
		if timer - mStartA > 3 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.5 and mAnim_set == nil then selectScene_musicboxClicked(); mAnim_set = true;
		elseif timer - mStartA > 1.5 and mAnim_set then m:SetSequenceTime(50, (3-(timer - mStartA))*1000); end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 3.5 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 6; mAnim_set = false; end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x > 0.04 then m:SetPosition(z-0.006,x-0.004,y+0.00065)
		else local num,mD = next(selectScene_GetModelData(1)); m:SetPosition(mD[4],0.04,mD[3]); mordred_stage = 7; mAnim_set = false; end

	elseif mordred_stage == 7 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > math.pi then m:SetFacing(m:GetFacing() - 0.01)
		else mordred_stage = 8; mAnim_set = false; end

	elseif mordred_stage == 8 then
		if not mAnim_set then m:SetSequence(96); MORDRED_STATE = "SIT"; mordred_timer = 0; mordred_stage = 1; end
	end
end

function selectScene_mSitReturn(timer, dt)
	if timer > 2 then
		local num,m = next(selectScene_GetModel(1))
		if mordred_stage == 1 then
			if not mAnim_set then m:SetSequence(98); mAnim_set = true; mStartA = timer; end
			if timer - mStartA > 1.5 then mordred_stage = 2; mAnim_set = false; end

		elseif mordred_stage == 2 then
			if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
			if m:GetFacing() < 5 then m:SetFacing(m:GetFacing() + 0.02)
			else mordred_stage = 3; mAnim_set = false; end

		elseif mordred_stage == 3 then
			if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
			local z,x,y = m:GetPosition()
			if x > -0.721 then m:SetPosition(z,x-0.012,y)
			else local num,mD = next(selectScene_GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); mordred_stage = 4; mAnim_set = false; end

		elseif mordred_stage == 4 then
			if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
			if m:GetFacing() > 3.224 then m:SetFacing(m:GetFacing() - 0.03)
			else mAnim_set = false; m:SetFacing(3.224); MORDRED_STATE = "USE"; m:SetSequence(63); mordred_timer = 0; end
		end
	end
end

mordred_timer = 0
function selectScene_mordredUpdate(self, dt)
	if MORDRED_STATE == "USE" then
		selectScene_mUse(mordred_timer, dt)
	elseif MORDRED_STATE == "USE_DRINK" then
		selectScene_mUseDrink(mordred_timer, dt)
	elseif MORDRED_STATE == "LANTERN" then
		selectScene_mLantern(mordred_timer, dt)
	elseif MORDRED_STATE == "FIRE" then
		selectScene_mFire(mordred_timer, dt)
	elseif MORDRED_STATE == "MUSICBOX" then
		selectScene_mMusicBox(mordred_timer, dt)
	elseif MORDRED_STATE == "SIT_RETURN" then
		selectScene_mSitReturn(mordred_timer, dt)
	end

	if MORDRED_STATE ~= "USE" and MORDRED_STATE ~= "SIT" and FIRE > 0 then
		selectScene_updateMordredLight()
	end

	mordred_timer = mordred_timer + dt
	if valve_timer then valve_timer = valve_timer + dt; end
	if skull_timer then skull_timer = skull_timer + dt; end
end

function selectScene_updateMordredLight()
	local num,m = next(selectScene_GetModel(1))
	local z,x,y = m:GetPosition()
	m:SetLight(1, 0, 0.4, x*2, 0, 0.4, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
end
