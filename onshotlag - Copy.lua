local function on_shot( event )
local timer = timer or {}
local timers = {}

function timer.Exists(name)
    for k,v in pairs(timers) do
        if name == v.name then
            return true
        end
    end
    return false
end


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

-- Gui menubox 
local OSFL_ref = gui.Reference( "MISC" )
local OSFL_menuTab = gui.Tab( OSFL_ref, "osflmenu.tab", "On Shot Fake Lag" )
local OSFL_groupbox = gui.Groupbox( OSFL_menuTab, "OnShot Fakelag", 15, 15, 200, 100 )
local OSFL_enable = gui.Checkbox( OSFL_groupbox, OSFL_enable, "Enable", true )
local OSFL_value = gui.Slider( OSFL_groupbox, fakelag_amount, "Fakelag amount:", 1 ,2, 17 )
local OSFL_delay = gui.Slider( OSFL_groupbox, fakelag_delay, "Delay time in seconds", 0.05, , 1)

	 
	-- check if player is shooting 
	if OSFL_enable:gui.GetValue() == true then
		if uid == local_player_index then
			
			-- turns on only when shooting to hide onshot
			if event_name == "weapon_fire" then
				
				-- sets fakelag to user defined ticks
				gui.SetValue( "misc.fakelag.factor", fakelag_amount)
				
				-- after 16 ticks/0.25 seconds, returns fakelag factor value to 2 ticks
				timer.Simple(fakelag_delay, function()gui.SetValue( "misc.fakelag.factor", 2 )end)

			end
		end
	end
end



	-- allows script to get game events --
	callbacks.Register( "FireGameEvent", on_shot )
	client.AllowListener( "weapon_fire" ) 












































































































































































































































