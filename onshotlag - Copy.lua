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

-- save original values --
local oValue = gui.GetValue( "misc.fakelag.value" )
local oFakelag = gui.GetValue( "misc.fakelag.enable" )
 
-- check if player is shooting --
if OnshotFakelagEnable:gui.GetValue() == true then

	if uid == local_player_index then

		if event_name == "weapon_fire" then
			
			-- turns on fakelag --
			gui.SetValue( "misc.fakelag.value", 15 );
			gui.SetValue( "misc.fakelag.enable", "on" );
			shotTime = globals.CurTime();

		end
	
		if shotTime + 1 < globals.CurTime() then
			
			-- changes to original fakelag values 250ms after shooting --
			gui.SetValue( "misc.fakelag.enable", oFakelag );
			gui.SetValue( "misc.fakelag.value", oValue );

		end
	end
end

-- allows script to get game events --
callbacks.Register( "FireGameEvent", on_shot )
client.AllowListener( "weapon_fire" ) 