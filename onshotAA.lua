local inverted = false
local switch = false

function DrawUI()
    
    -- Main window
    screenX,screenY = draw.GetScreenSize()
    window = gui.Window("aawindow","AA Window",screenX/2,screenY/2,500,800)
    
    -- Base aa gui groupbox
    groupboxYaw = gui.Groupbox(window,"Base AA",20,15,200,200)
    inverterKey = gui.Keybox(groupboxYaw,"inverterKey","Inverter Key",0)
    yawAmount = gui.Slider(groupboxYaw,"yaw_offset","Yaw Offset",0,-180,180)
    fakeAmount = gui.Slider(groupboxYaw,"fakeAmount","Fake Amount (%)",100,0,100)
    
    -- Lagsync gui groupbox
    groupboxLag = gui.Groupbox(window,"Lagsync",20,230,200,200)
    lagsyncBox = gui.Combobox(groupboxLag,"lagsync_type","Lagsync Type","Off","Custom")
    delayAmount = gui.Slider(groupboxLag,"delayAmount","Delay Amount (ticks)",1,1,64)
    
    -- Lagsync builder gui groupbox
    lsCustom = gui.Groupbox(window,"Lagsync Builder",20,400,200,200)
    lsCustomYaw1 = gui.Slider(lsCustom,"yawoffset1","Yaw Offset 1",0,-180,180)
    lsCustomYaw2 = gui.Slider(lsCustom,"yawoffset2","Yaw Offset 2",0,-180,180)
    lsCustomFake1 = gui.Slider(lsCustom,"fakeoffset1","Fake Amount 1",0,0,100)
    lsCustomFake2 = gui.Slider(lsCustom,"fakeoffset2","Fake Amount 2",0,0,100)

    -- Fakelag gui groupbox
    flGroupbox = gui.Groupbox( window, "Fakelag", 240, 15, 200, 200 )
    flEnable = gui.Checkbox( flGroupbox, "enable_fakelag", "Enable", false )
    flBaseAmount = gui.Slider( flGroupbox, "fakelag_value", "Base Amount", 3 , 3, 17)
    flSpikeAmount = gui.Slider(flGroupbox, "fakelag_spike", "Spike Amount", 3, 3, 17)
    flDelay = gui.Slider( flGroupbox, "flDelay", "Hold Time (S)",0, 0, 1, 0.01)
   
    -- Doubletap gui groupbox
    dtGroupbox = gui.Groupbox( window, "Double Tap", 240, 260, 200, 200 )
    dtSettings1 = gui.Combobox( dtGroupbox, "dt_switch_1", "DT Base Setting", "Off", "Shift" , "Rapid")
    dtSettings2 = gui.Combobox( dtGroupbox, "dt_switch_2", "DT Key Setting", "Off", "Shift" , "Rapid")
    dtKeybox = gui.Keybox( dtGroupbox, "dtKey", "Doubletap Switch Key", 0)
    
    -- sets window to open with the same key as the cheat
    window:SetOpenKey(45)

end
-- Allows script to control the antiaim settings in the cheat.
function YawHandler()

    -- Converts the 1 to 180 and -1 to -180 degrees yaw value to -180 to 0 to 180
    if yawAmount:GetValue() > 0 then
        gui.SetValue("rbot.antiaim.base",yawAmount:GetValue()-180);
    else
        gui.SetValue("rbot.antiaim.base",yawAmount:GetValue()+180);
    end
    
    -- Calculates the fake value into a percentage and contains the inverter calculations
    if not inverted then
        gui.SetValue("rbot.antiaim.base.lby",fakeAmount:GetValue()/100*60*-1)
        gui.SetValue("rbot.antiaim.base.rotation",fakeAmount:GetValue()/100*58)
    else
        gui.SetValue("rbot.antiaim.base.lby",fakeAmount:GetValue()/100*60)
        gui.SetValue("rbot.antiaim.base.rotation",fakeAmount:GetValue()/100*58*-1)
    end

end

-- Inverter key
function KeyPressHandler()
   
    if inverterKey:GetValue() ~= 0 then   
        if input.IsButtonPressed(inverterKey:GetValue()) then
            inverted = not inverted;
        end
    end

end

-- Main code for lagsync
function lagsync(cmd)
  
    -- Sets switch to change every x amount of tick defined by the user
    if cmd.tick_count % delayAmount:GetValue() == 0 then
        switch = not switch;
    end
  
    -- Switches between the two values
    if lagsyncBox:GetValue() == 1 then  
        if switch then
            yawAmount:SetValue(lsCustomYaw1:GetValue())
            fakeAmount:SetValue(lsCustomFake1:GetValue())
        else
            yawAmount:SetValue(lsCustomYaw2:GetValue())
            fakeAmount:SetValue(lsCustomFake2:GetValue())
        end
    end
        
end

-- Tick timer
local function onfire( event )
    
    local timer = timer or {}
    local timers = {}
    local eventName = event:GetName()
    local localPlayerIndex = client.GetLocalPlayerIndex()
    local uid = client.GetPlayerIndexByUserID(event:GetInt( "userid" ))

    function timer.Exists(name)
        
        for k,v in pairs(timers) do
		    if name == v.name then
		    	return true
		    end
        end
        
        return false

    end
	
    function timer.shot(name, delay, func)
        
        if not timer.Exists(name) then
	    	table.insert(timers, {type = "shot", name = name, func = func, lastTime = globals.CurTime() + delay})
        end
        
    end
	
    function timer.Tick()
        
        for k, v in pairs(timers or {}) do
		    if not v.pause then
			    if v.type == "shot" then
			    	if globals.CurTime() >= v.lastTime then
				    	v.func()
				    	table.remove(timers, k)
			    	end           
		    	end
	    	end
        end
        
    end

    callbacks.Register( "Draw", "timerTick", timer.Tick);

    -- Sets fakelag to spike value for set duration
    if flEnable:GetValue() == true then
	    if uid == localPlayerIndex then
			if eventName == "weapon_fire" then
				gui.SetValue( "misc.fakelag.factor", flSpikeAmount:GetValue())
				timer.shot("delay", flDelay:GetValue(), function()gui.SetValue( "misc.fakelag.factor", flBaseAmount:GetValue())end)
			end
		end
    end 

end


-- Switches between doubletap values for weapons that support it
local function dt_key_switch()
    
    -- Doubletap values
    local dtKey = gui.GetValue("aawindow.dtKey")
    local dtSet1 = gui.GetValue("aawindow.dt_switch_1")
    local dtSet2 = gui.GetValue("aawindow.dt_switch_2")

    if input.IsButtonDown(dtKey) then
        -- When the key is held, the doubletap value is set to the user defined value
        gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.shotgun.doublefire", dtSet2)
        gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dtSet2)
    
    else
        -- This sets the doubletap to the first value
        gui.SetValue("rbot.accuracy.weapon.pistol.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.hpistol.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.smg.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.asniper.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.rifle.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.shotgun.doublefire", dtSet1)
        gui.SetValue("rbot.accuracy.weapon.lmg.doublefire", dtSet1)
    end

end


-- Allocating weapon IDs to weapon groups
local weaponDt = {
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


local currentDt = false
local historyDt = false
local localPlayer = nil
local playerWeapon = nil


function dtMovementFix()
    
    -- Gets the information of the player and their current doubletap value
    local localPlayer = entities.GetLocalPlayer()
    local playerWeapon = localPlayer:GetWeaponID()
    local currentDt = (weaponDt[playerWeapon] ~= nil and gui.GetValue("rbot.accuracy.weapon." .. weaponDt[playerWeapon] .. ".doublefire") ~= 0 or false)
    
    if currentDt == true then 
        historyDt = true

    -- This allows the program to see when doubletap is togged from on to off.
    elseif currentDt == false and historyDt == true then
       
        -- Turns fakelag on only when the players velocity is 0
        if math.sqrt(localPlayer:GetPropFloat("localdata", "m_vecVelocity[0]")^2 + localPlayer:GetPropFloat("localdata", "m_vecVelocity[1]")^2) == 0 then
            historyDt = false
        end
    end
    
    gui.SetValue("misc.fakelag.enable", not historyDt)

end



DrawUI();
callbacks.Register("CreateMove",lagsync)
callbacks.Register("Draw",YawHandler)
callbacks.Register("Draw",KeyPressHandler)
callbacks.Register("Draw",GUIHandler)
callbacks.Register("FireGameEvent", onfire)
callbacks.Register("Draw", dt_key_switch)
callbacks.Register("CreateMove", dtMovementFix)
client.AllowListener("weapon_fire")
