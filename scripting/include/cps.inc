//Custom Player Skins include file

#if defined _CPS_included
 #endinput
#endif
#define _CPS_included

/**
 * Sets the client's skin from the given path.
 *
 * @param client	Client index
 * @param model		User input for model path
 * @noreturn 
 * @error			Invalid client.
 */
native CPS_SetSkin( client, String:model[] );

/**
 * Gets the client's skin entity reference.
 *
 * @param client	Client index
 * @return 			Returns the entity reference of the player's skin, INVALID_ENT_REFERENCE if there is no skin.
 * @error			Invalid client.
 */
native CPS_GetSkin( client );

/**
 * Removes and resets the player and their skin.
 *
 * @param client	Client index
 * @noreturn
 * @error			Invalid client.
 */
native CPS_RemoveSkin( client );

public SharedPlugin:__pl_CPS =
{
	name = "Custom Player Skins",
	file = "CustomPlayerSkins.smx",
	required = 1,
};

#if !defined REQUIRE_PLUGIN
public __pl_CPS_SetNTVOptional()
{
	MarkNativeAsOptional("MatM_SetSkin");
}
#endif
