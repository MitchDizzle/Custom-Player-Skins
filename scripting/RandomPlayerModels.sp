#include <sdktools>
#include <sdkhooks>
#include <CustomPlayerSkins>
#pragma semicolon 1

#define MAXMODELLENGTH				128

//Team 0 Is FFA team, and will pick a random skin from all groups
//Team 1 is spectator, this is not used.
#define MAXTEAMS          6 //Including Unassigned and Spectators.
#define MAXMODELS         50

char c_sModels[MAXTEAMS][MAXMODELS][MAXMODELLENGTH];
int c_MaxModels[MAXTEAMS];
bool canSkin = false;

#define PLUGIN_VERSION              "1.0.4"
public Plugin myinfo = {
	name = "Random Player Models (CPS)",
	author = "Mitchell",
	description = "Picks a random skin from a file, depending on the team",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2140485"
}
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Plugin Functions
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public void OnPluginStart() {
	CreateConVar("sm_cps_random_version", PLUGIN_VERSION, "Custom Player Skins Random Module Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_spawn", Event_Spawn);
}

public void OnMapStart() {
	LoadConfig();
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Event_Spawn		(type: Event)
	When the player spawns, and is alive (for some reason this is fired
	when players first join the game) then apply a skin on the player.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Action Event_Spawn(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsPlayerAlive(client) && canSkin) {
		CreateSkin(client);
	}
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------CreateSkin		(type: Public Function)
	Short little detour function to create a skin on the player
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public void CreateSkin(client) {
	int group = GetClientTeam(client);
	if(group == 0) {
		group = GetRandomGroup();
	}
	if(c_MaxModels[group] == 0) group = 0;
	int skin = GetRandomInt(0, c_MaxModels[group]-1);
	CPS_SetSkin(client, c_sModels[group][skin], CPS_NOFLAGS);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------GetRandomGroup		(type: Public Function)
	Function to find a random group that has skins in it.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public int GetRandomGroup() {
	new rndgroup = -1;
	while(rndgroup == -1) {
		rndgroup = GetRandomInt(0, MAXTEAMS-1);
		if(c_MaxModels[rndgroup] < 1) {
			rndgroup = -1;
		}
	}
	return (rndgroup == -1) ? 0 : rndgroup;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------LoadConfig		(type: Public Function)
	Loads the config from 
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public void LoadConfig() {
	SMCParser smc = new SMCParser(); 
	smc.OnKeyValue = KeyValue; 
	char sPaths[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPaths, sizeof(sPaths), "configs/randomplayermodels.cfg");
	if(!FileExists(sPaths)) {
		LogError("WARNING: This is a DIFFERENT plugin than the CustomPlayerSkins API, if you only wanted to use the API then uninstall this plugin!");
		LogError(" This plugin is only using the CustomPlayerSkins API and will have unexpected results if this is installed with another plugin that uses this API.");
		LogError(" AlliedModders Forum Post for this plugin (not CustomPlayerSkins): https://forums.alliedmods.net/showthread.php?p=2140485");
		SetFailState("RandomPlayerModels config is missing!");
	} else {
		smc.ParseFile(sPaths);
		canSkin = true;
	}
	delete smc;
} 
public SMCResult KeyValue(Handle smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	int group = StringToInt(key);
	strcopy(c_sModels[group][c_MaxModels[group]],MAXMODELLENGTH,value);
	PrecacheModel(value);
	//PrintToServer("(%s)%i-%i : %s", key, group, c_MaxModels[group], c_sModels[group][c_MaxModels[group]]);
	c_MaxModels[group]++;
}