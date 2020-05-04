local inverted = false;
local switch = false;
function DrawUI()
    screenX,screenY = draw.GetScreenSize();
    window = gui.Window("aawindow","AA Window",screenX/2,screenY/2,500,800);
    
    groupboxyaw = gui.Groupbox(window,"Base AA",20,15,200,200);
    invert_key = gui.Keybox(groupboxyaw,"invert_key","Inverter Key",0);
    yawamount = gui.Slider(groupboxyaw,"yaw_offset","Yaw Offset",0,-180,180);
    fakeamount = gui.Slider(groupboxyaw,"fake_amount","Fake Amount (%)",100,0,100);
    
    groupboxlag = gui.Groupbox(window,"Lagsync",20,230,200,200);
    lagsyncbox = gui.Combobox(groupboxlag,"lagsync_type","Lagsync Type","Off","Custom");
    delayamount = gui.Slider(groupboxlag,"delay_amount","Delay Amount (ticks)",1,1,64);
    
    lscustom = gui.Groupbox(window,"Lagsync Builder",20,400,200,200);
    lscustomyaw1 = gui.Slider(lscustom,"yawoffset1","Yaw Offset 1",0,-180,180);
    lscustomyaw2 = gui.Slider(lscustom,"yawoffset2","Yaw Offset 2",0,-180,180);
    lscustomfake1 = gui.Slider(lscustom,"fakeoffset1","Fake Amount 1",0,0,100);
    lscustomfake2 = gui.Slider(lscustom,"fakeoffset2","Fake Amount 2",0,0,100);

    flgroupbox = gui.Groupbox( window, "Fakelag", 240, 15, 200, 200 )
    flenable = gui.Checkbox( flgroupbox, "enable_fakelag", "Enable", false )
    flbaseamount = gui.Slider( flgroupbox, "fakelag_value", "Base Amount", 3 , 3, 17)
    flspikeamount = gui.Slider(flgroupbox, "fakelag_spike", "Spike Amount", 3, 3, 17)
    fldelay = gui.Slider( flgroupbox, "fl_delay", "Hold Time (S)",0, 0, 1, 0.01)
   
    window:SetOpenKey(45);

end

function YawHandler()

    if yawamount:GetValue() > 0 then
        gui.SetValue("rbot.antiaim.base",yawamount:GetValue()-180);
    else
        gui.SetValue("rbot.antiaim.base",yawamount:GetValue()+180);
    end
    
    if not inverted then
        gui.SetValue("rbot.antiaim.base.lby",fakeamount:GetValue()/100*60*-1);
        gui.SetValue("rbot.antiaim.base.rotation",fakeamount:GetValue()/100*58);
    else
        gui.SetValue("rbot.antiaim.base.lby",fakeamount:GetValue()/100*60);
        gui.SetValue("rbot.antiaim.base.rotation",fakeamount:GetValue()/100*58*-1);
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
    if cmd.tick_count % delayamount:GetValue() == 0 then
        switch = not switch;
    end
    if lagsyncbox:GetValue() == 1 then
    
        if switch then
            yawamount:SetValue(lscustomyaw1:GetValue());
            fakeamount:SetValue(lscustomfake1:GetValue());
        else
            yawamount:SetValue(lscustomyaw2:GetValue());
            fakeamount:SetValue(lscustomfake2:GetValue());
        end
    end
        
end

function onfire( event )
	
    local event_name = event:GetName()
    local local_player_index = client.GetLocalPlayerIndex()
    local uid = client.GetPlayerIndexByUserID(event:GetInt( "userid" ))

    if flenable:GetValue() == true then
	    if uid == local_player_index then
			if event_name == "weapon_fire" then
				gui.SetValue( "misc.fakelag.factor", flspikeamount:GetValue())
				timer.Simple("delay", fldelay:GetValue(), function()gui.SetValue( "misc.fakelag.factor", flbaseamount:GetValue())end)
			end
		end
	end
end

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

DrawUI();
callbacks.Register("CreateMove",lagsync);
callbacks.Register("Draw",YawHandler);
callbacks.Register("Draw",KeyPressHandler);
callbacks.Register("Draw",GUIHandler);
callbacks.Register( "FireGameEvent", onfire );
client.AllowListener( "weapon_fire" );
callbacks.Register( "Draw", "timerTick", timer.Tick);
