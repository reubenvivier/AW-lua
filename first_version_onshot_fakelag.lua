local function on_shot(event)
local shotTime = globals.CurTime()
local event_name = event:GetName()
local local_player_index = client.GetLocalPlayerIndex()
local uid = client.GetPlayerIndexByUserID(event:GetInt( 'userid' ))
 
if uid == local_player_index then
	if event_name == "weapon_fire" then
		gui.SetValue("misc.fakelag.enable", "on");
		shotTime = globals.CurTime();
	end
	
	if shotTime + 1 < globals.CurTime() then
		gui.SetValue("misc.fakelag.enable", "off");
	end
end

callbacks.Register("FireGameEvent", on_shot)
client.AllowListener("weapon_fire") 
