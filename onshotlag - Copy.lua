local function on_shot( event )
	local shotTime = globals.CurTime()
	local event_name = event:GetName()
	local local_player_index = client.GetLocalPlayerIndex()
	local uid = client.GetPlayerIndexByUserID(event:GetInt( "userid" ))
	
	-- Gui menubox --
	local OSFLRef = gui.Reference( "MISC" )
	local OSFLMenuTab = gui.Tab( OSFLRef, "osflmenu.tab", "On Shot Fake Lag" )
	local OSFLGroupbox = gui.Groupbox( OSFLMenuTab, "OnShot Fakelag", 15, 15, 200, 100 )
	OnshotFakelagEnable = gui.Checkbox( OSFLGroupbox, OnshotFakelagEnable, "Enable", true )
		-- 	gui.Slider( parent, misc.fakelag.factor, "Fakelag amount:", 1 ,2, 17 )
		-- make a slider that lets the user control the amount of fakelag onshot
		--
		-- make slider for amount of time fakelag is enabled
		--
		-- local fakelagDelay = gui.Slider( parent, varname, name, value, min, max )
		-- gui.Slider( parent, fakelagDelay, 1, 2, 17 )
		-- 
		--   :setDescription("Amount  of fakelag you want.")

	-- save original values --
	-- local oValue = gui.GetValue( "misc.fakelag.value" )
	-- local oFakelag = gui.GetValue( "misc.fakelag.enable" )
	 
	-- check if player is shooting --
	if OnshotFakelagEnable:gui.GetValue() == true then
	
		if uid == local_player_index then
				gui.SetValue( "misc.fakelag.enable", True
	
			-- turns on fakelag when shooting --
			if event_name == "weapon_fire" then
				
				gui.SetValue( "misc.fakelag.factor", 15 )
				gui.SetValue( "misc.fakelag.enable", "on" )
				shotTime = globals.CurTime() + fakelagDelay
	
			end
		
			-- changes to original fakelag values 250ms after shooting --
			if shotTime < globals.CurTime() thenf
				
			--	gui.SetValue( "misc.fakelag.enable", oFakelag )
				--gui.SetValue( "misc.fakelag.value", oValue )


				gui.SetValue( "misc.fakelag.enable", off)


				shotTime = globals.CurTime() + fakelagDelay
	
			end
		end
	end
	end



	-- allows script to get game events --
	callbacks.Register( "FireGameEvent", on_shot )
	client.AllowListener( "weapon_fire" ) 