/**
 * vim: set ts=4 :
 * =============================================================================
 * Random Player Skins (Core)
 * Allows plugins to assign a 'skin' to players.
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
 * Version: 1.1.1
 */
#include <sdktools>
#include <sdkhooks>
#pragma semicolon 1

#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_PARENT_ANIMATES          (1 << 9)

new g_PlayerModels[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE,...};

#define PLUGIN_VERSION              "1.1.1"
public Plugin:myinfo = {
	name = "Custom Player Skins (Core)",
	author = "Mitchell",
	description = "Natives for custom skins to be applied to the players.",
	version = PLUGIN_VERSION,
	url = "SnBx.info"
}
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Plugin Functions
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("CPS_SetSkin", Native_SetSkin);
	CreateNative("CPS_GetSkin", Native_GetSkin);
	CreateNative("CPS_RemoveSkin", Native_RemoveSkin);

	RegPluginLibrary("CustomPlayerSkins");
	return APLRes_Success;
}

public OnPluginStart( )
{
	CreateConVar("sm_custom_player_skins_version", PLUGIN_VERSION, "Custom Player Skins Version", \
											FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_death", Event_Death);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------OnPluginEnd		(type: Plugin Function)
	Make sure to delete all the skins! And reset their colors...
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public OnPluginEnd( )
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			RemoveSkin(i);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Native_SetSkin		(type: Native)
	Core function to set the player's skin from another plugin.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Native_SetSkin(Handle:plugin, args)
{
	new client = GetNativeCell( 1 );
	if(NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
	{
		new String:sModel[PLATFORM_MAX_PATH];
		new mode = GetNativeCell( 3 );
		GetNativeString(2, sModel, PLATFORM_MAX_PATH);
		CreatePlayerModelProp(client, sModel, RenderMode:mode);
	}
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Native_GetSkin		(type: Native)
	Core function to get the player's skin from another plugin.
	This will return the reference of the entity.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Native_GetSkin(Handle:plugin, args)
{
	new client = GetNativeCell( 1 );
	if(NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
		if(IsValidEntity(g_PlayerModels[client]))
			return g_PlayerModels[client];
	return INVALID_ENT_REFERENCE;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Native_RemoveSkin		(type: Native)
	Core function to get the player's skin from another plugin.
	This will reset the player's skin (remove it).
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Native_RemoveSkin(Handle:plugin, args)
{
	new client = GetNativeCell( 1 );
	if(NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
		RemoveSkin( client );
	return INVALID_ENT_REFERENCE;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------Event_Death		(type: Event)
	When a player dies we should remove the skin, so there isn't a random
	prop floating.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	RemoveSkin(GetClientOfUserId(GetEventInt(event, "userid")));
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------CreatePlayerModelProp		(type: Public Function)
	Creates a prop that will act as the player's model via bonemerging.
	This prop is not solid, and no bullets will be affected by the skin.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
CreatePlayerModelProp( client, String:sModel[], RenderMode:mode ) {
	new Ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(Ent, "model", sModel);
	DispatchKeyValue(Ent, "disablereceiveshadows", "1");
	DispatchKeyValue(Ent, "disableshadows", "1");
	DispatchKeyValue(Ent, "solid", "0");
	DispatchKeyValue(Ent, "spawnflags", "1");
	SetEntProp(Ent, Prop_Send, "m_CollisionGroup",	   11);
	DispatchSpawn(Ent);
	SetEntProp(Ent, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_PARENT_ANIMATES);
	SetVariantString("!activator");
	AcceptEntityInput(Ent, "SetParent", client, Ent, 0);
	SetVariantString("forward");
	AcceptEntityInput(Ent, "SetParentAttachment", Ent, Ent, 0);
	SDKHook( Ent, SDKHook_SetTransmit, OnShouldProp);

	SetEntityRenderMode(client, mode);

	g_PlayerModels[client] = EntIndexToEntRef(Ent);
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------RemoveSkin		(type: Public Function)
	Remove the skin, if it exists, and also set the player back to normal.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
RemoveSkin( client ) {
	if(IsValidEntity(g_PlayerModels[client]))
		AcceptEntityInput(g_PlayerModels[client], "Kill");
	SetEntityRenderMode(client, RENDER_NORMAL);
	g_PlayerModels[client] = INVALID_ENT_REFERENCE;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------OnShouldProp		(type: SDKHooks SetTransmit Function)
	Displays the skin to everybody but thep player and anybody spectating
	first person of said player.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public Action:OnShouldProp( Ent, Client)
{
	new Target = GetEntPropEnt(Client, Prop_Send, "m_hObserverTarget");

	if((Target != -1 && NativeCheck_IsClientValid(Client)
	&& Ent == EntRefToEntIndex(g_PlayerModels[Target]))
	|| Ent == EntRefToEntIndex(g_PlayerModels[Client]))
		return Plugin_Handled;
	return Plugin_Continue;
}

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------NativeCheck_IsClientValid		(type: Public Function)
	Not sure who created this, but i ripped it from some where...
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
public NativeCheck_IsClientValid(client)
{
	if (client <= 0 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client index %i is invalid", client);
	if (!IsClientInGame(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not in game", client);
	return true;
}