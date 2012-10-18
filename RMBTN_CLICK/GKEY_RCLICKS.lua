-- Substitue gInitT empty braces with the log output if
-- you would like to have the G keys initialized with it
-- each time you activate the profile, i.e. :
-- gInitT = {[1]={[1]={y=19314,x=22369,},},[2]={},[3]={},}

gInitT = {{}, {}, {}}
gFuncT = {{}, {}, {}}

function CreateAndSaveGKeyData(mode, arg)
	local destX,destY = GetMousePosition()
	gInitT[mode][arg] = {}
	gInitT[mode][arg].x = destX
	gInitT[mode][arg].y = destY
	
	WriteBindings()

	return destX, destX
end

function CreateGKeyMouseClick(destX, destY)
	-- local destX,destY = GetMousePosition()
	-- OutputLogMessage("Create click function for(%d,%d)\n", destX, destY)
	return function ()
			origX,origY = GetMousePosition()
			-- OutputLogMessage("Origin coordinates(%d,%d)\n", origX, origY)
			-- OutputLogMessage("Destination coordinates(%d,%d)\n", destX, destY)
			MoveMouseTo(destX,destY)
			Sleep(10)
			PressAndReleaseMouseButton(3)
			Sleep(10)
			MoveMouseTo(origX,origY)
			end
end

function BindGKey(mode, arg)
	gFuncT[mode][arg] = CreateGKeyMouseClick(CreateAndSaveGKeyData(mode, arg))
end

function InitGKeys()
	for mode,mv in pairs(gInitT) do
		for key, kv in pairs(mv) do
			gFuncT[mode][key] = CreateGKeyMouseClick(kv.x, kv.y)
		end
	end
end

function WriteBindings()
	ClearLog()
	OutputLogMessage(serialize(gInitT))
end

function serialize (o)
	tSer = ""
	if type(o) == "table" then
		tSer = tSer.."{"
		for k,v in pairs(o) do
			if type(k) == "number" then
				tSer = tSer.."["..k.."]="
			else
				tSer = tSer..k.."="
			end
			tSer = tSer..serialize(v)
			tSer = tSer..","
		end
		tSer = tSer.."}"
	else
		tSer = tSer..o
	end
	return tSer
end

function OnEvent(event, arg)
	if event == "PROFILE_ACTIVATED" then
		InitGKeys()
    elseif event == "G_PRESSED" then
		mode = GetMKeyState("kb")
		if(IsModifierPressed("ctrl")) then
			BindGKey(mode, arg)
		elseif (gFuncT[mode][arg] ~= nil) then
			gFuncT[mode][arg]()	
		end
	end
	
end