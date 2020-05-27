local inverted = false
local switch = false

function DrawUI()
    
    screenX,screenY = draw.GetScreenSize()
    window = gui.Window("aawindow","AA Window",screenX/2,screenY/2,500,800)
    
    groupbox_yaw = gui.Groupbox(window,"Base AA",20,15,200,200)
    invert_key = gui.Keybox(groupbox_yaw,"invert_key","Inverter Key",0)
    yaw_amount = gui.Slider(groupbox_yaw,"yaw_offset","Yaw Offset",0,-180,180)
    fake_amount = gui.Slider(groupbox_yaw,"fake_amount","Fake Amount (%)",100,0,100)
    
    groupbox_lag = gui.Groupbox(window,"Lagsync",20,230,200,200)
    lagsync_box = gui.Combobox(groupbox_lag,"lagsync_type","Lagsync Type","Off","Custom")
    delay_amount = gui.Slider(groupbox_lag,"delay_amount","Delay Amount (ticks)",1,1,64)
    
    ls_custom = gui.Groupbox(window,"Lagsync Builder",20,400,200,200)
    ls_custom_yaw_1 = gui.Slider(ls_custom,"yawoffset1","Yaw Offset 1",0,-180,180)
    ls_custom_yaw_2 = gui.Slider(ls_custom,"yawoffset2","Yaw Offset 2",0,-180,180)
    ls_custom_fake_1 = gui.Slider(ls_custom,"fakeoffset1","Fake Amount 1",0,0,100)
    ls_custom_fake_2 = gui.Slider(ls_custom,"fakeoffset2","Fake Amount 2",0,0,100)

    fl_groupbox = gui.Groupbox( window, "Fakelag", 240, 15, 200, 200 )
    fl_enable = gui.Checkbox( fl_groupbox, "enable_fakelag", "Enable", false )
    fl_base_amount = gui.Slider( fl_groupbox, "fakelag_value", "Base Amount", 3 , 3, 17)
    fl_spike_amount = gui.Slider(fl_groupbox, "fakelag_spike", "Spike Amount", 3, 3, 17)
    fl_delay = gui.Slider( fl_groupbox, "fl_delay", "Hold Time (S)",0, 0, 1, 0.01)
   
    dt_groupbox = gui.Groupbox( window, "Double Tap", 240, 260, 200, 200 )
    dt_settings_1 = gui.Combobox( dt_groupbox, "dt_switch_1", "DT Base Setting", "Off", "Shift" , "Rapid")
    dt_setting_2 = gui.Combobox( dt_groupbox, "dt_switch_2", "DT Key Setting", "Off", "Shift" , "Rapid")
    dt_keybox = gui.Keybox( dt_groupbox, "dt_key", "Doubletap Switch Key", 0)
    
    window:SetOpenKey(45)

end

function YawHandler()

    if yaw_amount:GetValue() > 0 then
        gui.SetValue("rbot.antiaim.base",yaw_amount:GetValue()-180);
    else
        gui.SetValue("rbot.antiaim.base",yaw_amount:GetValue()+180);
    end
    
    if not inverted then
        gui.SetValue("rbot.antiaim.base.lby",fake_amount:GetValue()/100*60*-1)
        gui.SetValue("rbot.antiaim.base.rotation",fake_amount:GetValue()/100*58)
    else
        gui.SetValue("rbot.antiaim.base.lby",fake_amount:GetValue()/100*60)
        gui.SetValue("rbot.antiaim.base.rotation",fake_amount:GetValue()/100*58*-1)
    end

end

function KeyPressHandler()
   
    if invert_key:GetValue() ~= 0 then   
        if input.IsButtonPressed(invert_key:GetValue()) then
            inverted = not inverted;
        end
    end

end

function lagsync(cmd)
  
    if cmd.tick_count % delay_amount:GetValue() == 0 then
        switch = not switch;
    end
  
    if lagsync_box:GetValue() == 1 then  
        if switch then
            yaw_amount:SetValue(ls_custom_yaw_1:GetValue())
            fake_amount:SetValue(ls_custom_fake_1:GetValue())
        else
            yaw_amount:SetValue(ls_custom_yaw_2:GetValue())
            fake_amount:SetValue(ls_custom_fake_2:GetValue())
        end
    end
        
end

local function onfire( event )
    
    local timer = timer or {}
    local timers = {}
    local event_name = event:GetName()
    local local_player_index = client.GetLocalPlayerIndex()
    local uid = client.GetPlayerIndexByUserID(event:GetInt( "userid" ))

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

    if fl_enable:GetValue() == true then
	    if uid == local_player_index then
			if event_name == "weapon_fire" then
				gui.SetValue( "misc.fakelag.factor", fl_spike_amount:GetValue())
				timer.Simple("delay", fl_delay:GetValue(), function()gui.SetValue( "misc.fakelag.factor", fl_base_amount:GetValue())end)
			end
		end
    end 

end



local function dt_key_switch()
    
    local dt_key = gui.GetValue("aawindow.dt_key")
    local dt_set_1 = gui.GetValue("aawindow.dt_switch_1")
    local dt_set_2 = gui.GetValue("aawindow.dt_switch_2")

    if input.IsButtonDown(dt_key) then
        gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.shotgun.doublefire", dt_set_2)
        gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dt_set_2)
    
    else
        gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.shotgun.doublefire", dt_set_1)
        gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dt_set_1)
    end

end

local weapon_dt = {
    [1] = "hpistol",
    [2] = "pistol",
    [3] = "pistol",
    [4] = "pistol",
    [7] = "rifle",
    [8] = "rifle",
    [10] = "rifle",
    [11] = "asniper",
    [13] = "rifle",
    [14] = "lmg",
    [16] = "rifle",
    [17] = "smg",
    [19] = "smg",
    [23] = "smg",
    [24] = "smg",
    [25] = "shotgun",
    [26] = "smg",
    [28] = "lmg",
    [30] = "pistol",
    [32] = "pistol",
    [33] = "smg",
    [34] = "smg",
    [36] = "pistol",
    [38] = "asniper",
    [39] = "rifle",
    [60] = "rifle",
    [61] = "pistol",
    [63] = "pistol",
}

local current_dt = false
local history_dt = false
local local_player = nil
local player_weapon = nil


function dt_movement_fix()
    
    local local_player = entities.GetLocalPlayer()
    local player_weapon = local_player:GetWeaponID()
    local current_dt = (weapon_dt[player_weapon] ~= nil and gui.GetValue("rbot.accuracy.weapon." .. weapon_dt[player_weapon] .. ".doublefire") ~= 0 or false)
    
    if current_dt == true then
        history_dt = true
    elseif current_dt == false and history_dt == true then
        if math.sqrt(local_player:GetPropFloat("localdata", "m_vecVelocity[0]")^2 + local_player:GetPropFloat("localdata", "m_vecVelocity[1]")^2) == 0 then
            history_dt = false
        end
    end
    
    gui.SetValue("misc.fakelag.enable", not history_dt)

end



DrawUI();
callbacks.Register("CreateMove",lagsync)
callbacks.Register("Draw",YawHandler)
callbacks.Register("Draw",KeyPressHandler)
callbacks.Register("Draw",GUIHandler)
callbacks.Register("FireGameEvent", onfire)
callbacks.Register("Draw", dt_key_switch)
callbacks.Register("CreateMove", dt_movement_fix)
client.AllowListener("weapon_fire")
