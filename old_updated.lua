
-- Gui menubox 
local ref = gui.Tab(gui.Reference("Misc"), "onshotfakelag.settings", "OSFL")
local groupbox = gui.Groupbox( ref, "Settings", 15, 15, 200, 100 )
	
local Enable_key = gui.Checkbox( groupbox, "Enable_key", "Enable", false )
local value = gui.Slider( groupbox, "fakelag_value", "Fakelag amount", 3 , 0, 61)
local delay = gui.Slider( groupbox, "shot_delay", "Delay time in seconds",0, 0, 5)
gui.Text( groupbox, "" )


local function on_shot( event )
	local timer = timer or {}
	local timers = {}
	
	-- creating timer function
	function timer.Exists(name)
		for k,v in pairs(timers) do
			if name == v.name then
				return true
			end
		end
		return false
	end
	
	-- simple timer
	function timer.Simple(name, delay, func)
		if not timer.Exists(name) then
			table.insert(timers, {type = "Simple", name = name, func = func, lastTime = globals.CurTime() + delay})
		end
	end
	
	function timer.Tick()
		for k, v in pairs(timers or {}) do
			if not v.pause then
				if v.type == "Simple" then
					if globals.CurTime() >= v.lastTime then
						v.func()
						table.remove(timers, k)
					end           
				end
				end
		end
	end
	
	callbacks.Register( "Draw", "timerTick", timer.Tick);
	
	-- sets script to only run when player is alive to save fps
	local event_name = event:GetName()
	local local_player_index = client.GetLocalPlayerIndex()
	local uid = client.GetPlayerIndexByUserID(event:GetInt( "userid" ))
	

	


		-- check if player is shooting 
		if gui.GetValue("misc.onshotfakelag.settings.Enable_key") == true then
			if uid == local_player_index then
				
				-- turns on only when shooting to choke onshot packets
				if event_name == "weapon_fire" then
					
					-- sets fakelag to user defined ticks
					gui.SetValue( "misc.fakelag.factor", value:GetValue())
					
					-- after user defined delay seconds, returns fakelag factor value to 2 ticks/off
					timer.Simple("delay", gui.GetValue("misc.onshotfakelag.settings.shot_delay"), function()gui.SetValue( "misc.fakelag.factor", 3 )end)
				 
				end
			end
		end
	end
	
	
	
		-- allows script to get game events --
		callbacks.Register( "FireGameEvent", on_shot )
		client.AllowListener( "weapon_fire" ) 
