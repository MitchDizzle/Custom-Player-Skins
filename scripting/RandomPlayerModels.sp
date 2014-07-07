/**
 * vim: set ts=4 :
 * =============================================================================
 * Random Player Skins (Random Module)
 * Loads a random skin from a file and applies it to the player.
 *
 * Name (C)2014 Mitchell (Mitchell Gardner).  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: 1.0.1
 */
#include <sdktools>
#include <sdkhooks>
#include <CustomPlayerSkins>
#pragma semicolon 1

#define MAXMODELLENGTH				128

//Team 0 Is FFA team, and will pick a random skin from all groups
//Team 1 is spectator, this is not used.
#define MAXTEAMS          6 //Including Unassigned and Spectators.
#define MAXMODELS         25

new String:c_sModels[MAXTEAMS][MAXMODELS][MAXMODELLENGTH];
new c_MaxModels[MAXTEAMS];

#define PLUGIN_VERSION              "1.0.1"
public Plugin:myinfo = {
	name = "Custom Player Skins (Random Module)",
	author = "Mitchell",
	description = "Picks a random skin from a file, depending on the team",
	version = PLUGIN_VERSION,
	url = "SnBx.info"
}
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Plugin Functions
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public OnPluginStart()
{
	CreateConVar("sm_cps_random_version", PLUGIN_VERSION, "Custom Player Skins Random Module Version", \
														FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_spawn", Event_Spawn);
}

public OnMapStart( )
{
	LoadConfig( );
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Event_Spawn		(type: Event)
	When the player spawns, and is alive (for some reason this is fired
	when players first join the game) then apply a skin on the player.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Action:Event_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsPlayerAlive(client))
		CreateSkin(client);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------CreateSkin		(type: Public Function)
	Short little detour function to create a skin on the player
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
CreateSkin( client )
{
	new group = GetClientTeam( client );
	if(group == 0)
		group = GetRandomGroup( );
	if(c_MaxModels[group] == 0) group = 0;
	new skin = GetRandomInt(0, c_MaxModels[group]-1);
	CPS_SetSkin(client, c_sModels[group][skin], CPS_RENDER);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------GetRandomGroup		(type: Public Function)
	Function to find a random group that has skins in it.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
GetRandomGroup( )
{
	new rndgroup = -1;
	while(rndgroup == -1)
	{
		rndgroup = GetRandomInt(0, MAXTEAMS-1);
		if(c_MaxModels[rndgroup] < 1) 
			rndgroup = -1;
	}
	return (rndgroup == -1) ? 0 : rndgroup;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------LoadConfig		(type: Public Function)
	Loads the config from 
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public LoadConfig()
{
	new Handle:SMC = SMC_CreateParser(); 
	SMC_SetReaders(SMC, NewSection, KeyValue, EndSection); 
	decl String:sPaths[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPaths, sizeof(sPaths),"configs/randomplayermodels.cfg");
	SMC_ParseFile(SMC, sPaths);
	CloseHandle(SMC);
}
public SMCResult:NewSection(Handle:smc, const String:name[], bool:opt_quotes) { }
public SMCResult:EndSection(Handle:smc) { }  
public SMCResult:KeyValue(Handle:smc, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes) 
{
	new group = StringToInt(key);
	strcopy(c_sModels[group][c_MaxModels[group]],MAXMODELLENGTH,value);
	PrecacheModel(value);
	PrintToServer("(%s)%i-%i : %s", key, group, c_MaxModels[group], c_sModels[group][c_MaxModels[group]]);
	c_MaxModels[group]++;
}