// RoleBasedAdminSystem.dm - Admin Hierarchy & Permission Management
// Role system: Owner (MGM) → GM → Moderator → Contributor → Community Assistant
// Each role has specific permissions enforced at runtime

// ============================================================================
// ROLE DEFINITIONS & CONSTANTS
// ============================================================================

#define ROLE_OWNER "owner"           // Master GM (hardcoded, unique)
#define ROLE_GM "gm"                 // Game Master (host, grants roles)
#define ROLE_MODERATOR "moderator"   // Community moderator (soft power)
#define ROLE_AUDIO_ENGINEER "audio_engineer"  // Audio/sound system access
#define ROLE_CONTRIBUTOR "contributor"       // Streamer/special access
#define ROLE_COMMUNITY_ASSISTANT "ca"        // Helper role, learning path

// Permission bits
#define PERM_NONE 0
#define PERM_TELEPORT (1 << 0)       // Teleport players
#define PERM_SPAWN_ITEMS (1 << 1)    // Spawn items
#define PERM_KICK_PLAYER (1 << 2)    // Kick/ban
#define PERM_MUTE_PLAYER (1 << 3)    // Mute/chat commands
#define PERM_JAIL_PLAYER (1 << 4)    // Jail/restrict movement
#define PERM_GRANT_ROLES (1 << 5)    // Assign roles to others
#define PERM_STRIP_ROLES (1 << 6)    // Remove roles from others
#define PERM_MUSIC_CONTROL (1 << 7)  // Change playlists/sounds
#define PERM_HIDE_HUD (1 << 8)       // Hide UI elements
#define PERM_ADMIN_PANEL (1 << 9)    // Access admin commands
#define PERM_SERVER_CONFIG (1 << 10) // Change server settings
#define PERM_OVERRIDE_ALL (1 << 11)  // Override all restrictions

// ============================================================================
// GLOBAL ADMIN SYSTEM
// ============================================================================

/**
 * RoleBasedAdminManager
 * Centralized manager for admin roles and permissions
 */
/datum/role_based_admin_manager
	var
		owner_ckey = ""                     // Master GM (hardcoded)
		list/admin_roster = list()          // All admin ckeys
		list/role_registry = list()         // ckey -> role
		list/permission_matrix = list()     // role -> permissions bitmap
	
	proc/Initialize()
		/**
		 * Initialize admin system
		 * Set up permission matrix and read from config
		 */
		InitializePermissionMatrix()
		LoadAdminRoster()
		RegisterInitComplete("role_based_admin_system")
	
	proc/InitializePermissionMatrix()
		/**
		 * Define permissions for each role
		 */
		var/owner_perms = PERM_TELEPORT | PERM_SPAWN_ITEMS | PERM_KICK_PLAYER | PERM_MUTE_PLAYER | \
			PERM_JAIL_PLAYER | PERM_GRANT_ROLES | PERM_STRIP_ROLES | PERM_MUSIC_CONTROL | \
			PERM_HIDE_HUD | PERM_ADMIN_PANEL | PERM_SERVER_CONFIG | PERM_OVERRIDE_ALL
		permission_matrix[ROLE_OWNER] = owner_perms
		
		var/gm_perms = PERM_TELEPORT | PERM_SPAWN_ITEMS | PERM_KICK_PLAYER | PERM_MUTE_PLAYER | \
			PERM_JAIL_PLAYER | PERM_GRANT_ROLES | PERM_STRIP_ROLES | PERM_MUSIC_CONTROL | \
			PERM_ADMIN_PANEL | PERM_SERVER_CONFIG
		permission_matrix[ROLE_GM] = gm_perms
		
		var/moderator_perms = PERM_MUTE_PLAYER | PERM_JAIL_PLAYER | PERM_ADMIN_PANEL
		permission_matrix[ROLE_MODERATOR] = moderator_perms
		
		var/audio_perms = PERM_MUSIC_CONTROL | PERM_ADMIN_PANEL
		permission_matrix[ROLE_AUDIO_ENGINEER] = audio_perms
		
		var/contributor_perms = PERM_HIDE_HUD | PERM_ADMIN_PANEL
		permission_matrix[ROLE_CONTRIBUTOR] = contributor_perms
		
		var/ca_perms = PERM_MUTE_PLAYER | PERM_ADMIN_PANEL
		permission_matrix[ROLE_COMMUNITY_ASSISTANT] = ca_perms
	
	proc/LoadAdminRoster()
		/**
		 * Load admin roster from savefile (or default config)
		 * For now, initialized empty (configured via admin commands)
		 */
		// TODO: Load from admin_roster.sav
		admin_roster = list()
	
	proc/GrantRole(grantor_ckey, target_ckey, role)
		/**
		 * Assign role to player
		 * Enforces hierarchy: Only Owner/GM can grant, can't promote above self
		 * 
		 * @param grantor_ckey: Who is granting
		 * @param target_ckey: Who receives role
		 * @param role: Role to grant
		 * @return: 1 if success, 0 if denied
		 */
		var/grantor_role = role_registry[grantor_ckey]
		
		// Only Owner can assign Owner role
		if(role == ROLE_OWNER)
			if(grantor_ckey != owner_ckey)
				return 0
		
		// Only Owner/GM can grant roles
		if(grantor_role != ROLE_OWNER && grantor_role != ROLE_GM)
			return 0
		
		// GM cannot grant GM role (promote above self)
		if(grantor_role == ROLE_GM && role == ROLE_GM)
			return 0
		
		// Grant role
		role_registry[target_ckey] = role
		admin_roster += target_ckey
		
		world.log << "Role grant: [grantor_ckey] granted [role] to [target_ckey]"
		return 1
	
	proc/StripRole(stripper_ckey, target_ckey)
		/**
		 * Remove role from player
		 * Enforces hierarchy: Only Owner/GM can strip, cannot strip Owner
		 * 
		 * @param stripper_ckey: Who is stripping role
		 * @param target_ckey: Who loses role
		 * @return: 1 if success, 0 if denied
		 */
		var/stripper_role = role_registry[stripper_ckey]
		var/target_role = role_registry[target_ckey]
		
		// Cannot strip Owner role
		if(target_role == ROLE_OWNER)
			return 0
		
		// Only Owner can strip GM
		if(target_role == ROLE_GM && stripper_role != ROLE_OWNER)
			return 0
		
		// Only Owner/GM can strip
		if(stripper_role != ROLE_OWNER && stripper_role != ROLE_GM)
			return 0
		
		// Strip role
		role_registry[target_ckey] = ""
		admin_roster -= target_ckey
		
		world.log << "Role strip: [stripper_ckey] stripped [target_role] from [target_ckey]"
		return 1
	
	proc/HasPermission(ckey, permission)
		/**
		 * Check if player has specific permission
		 * 
		 * @param ckey: Player ckey
		 * @param permission: Permission bit (PERM_*)
		 * @return: 1 if has permission, 0 if not
		 */
		var/role = role_registry[ckey]
		if(!role) return 0
		
		var/perms = permission_matrix[role]
		return (perms & permission) ? 1 : 0
	
	proc/GetPlayerRole(ckey)
		/**
		 * Get player's current role
		 * 
		 * @param ckey: Player ckey
		 * @return: Role string or empty
		 */
		if(role_registry[ckey])
			return role_registry[ckey]
		return ""

// Global admin system instance
var/global/datum/role_based_admin_manager/admin_system = null

/**
 * InitializeRoleBasedAdminSystem()
 * Boot admin system at world startup
 * Called from InitializationManager.dm
 */
proc/InitializeRoleBasedAdminSystem()
	admin_system = new /datum/role_based_admin_manager()
	admin_system.Initialize()

/**
 * GetAdminSystem()
 * Get global admin system singleton
 */
proc/GetAdminSystem()
	if(!admin_system)
		InitializeRoleBasedAdminSystem()
	return admin_system

// ============================================================================
// OWNER (MASTER GM) HARDCODING
// ============================================================================

#define HARDCODED_OWNER_CKEY "your_ckey_here"  // CHANGE THIS TO ACTUAL OWNER

/**
 * SetOwnerCkey(ckey)
 * Hardcode owner/master GM ckey
 * Should be called once at world boot
 * 
 * @param ckey: Player's ckey who is owner
 */
proc/SetOwnerCkey(ckey)
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin) return
	
	admin.owner_ckey = ckey
	admin.role_registry[ckey] = ROLE_OWNER
	admin.admin_roster += ckey
	
	world.log << "Owner/Master GM set to: [ckey]"

/**
 * IsOwner(ckey)
 * Check if player is master GM
 * 
 * @param ckey: Player ckey
 * @return: 1 if owner, 0 if not
 */
proc/IsOwner(ckey)
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	return (admin && admin.owner_ckey == ckey) ? 1 : 0

// ============================================================================
// ADMIN MODE TOGGLING
// ============================================================================

/**
 * ToggleAdminMode(mob/players/P)
 * Toggle between regular player and admin verb sets
 * Only works for players with admin role
 * Shows/hides admin verbs
 * 
 * @param P: Player mob
 */
proc/ToggleAdminMode(mob/players/P)
	if(!P) return
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin) return
	
	// Check if player has admin role
	var/role = admin.GetPlayerRole(P.ckey)
	if(!role)
		P << "<span class='danger'>ERROR: You do not have an admin role.</span>"
		return
	
	// Toggle admin mode
	if(!P.admin_mode_active)
		P.admin_mode_active = 1
		P << "<span class='good'>✦ ADMIN MODE ACTIVATED ✦</span>"
		P << "<span class='good'>You are now showing admin commands.</span>"
		P << "<span class='good'>Role: [role]</span>"
		world << "<span class='danger'>[P.name] has entered ADMIN MODE ([role])!</span>"
	else
		P.admin_mode_active = 0
		P << "<span class='info'>Admin mode deactivated.</span>"
		P << "<span class='info'>You are now appearing as a regular player.</span>"
		world << "[P.name] has exited admin mode."
	
	// Refresh verb set (add/remove admin verbs)
	UpdateAdminVerbSet(P)

/**
 * UpdateAdminVerbSet(mob/players/P)
 * Add or remove admin verbs based on mode
 * Called when toggling admin mode
 * 
 * @param P: Player mob
 */
proc/UpdateAdminVerbSet(mob/players/P)
	if(!P) return
	
	if(P.admin_mode_active)
		// Add admin verbs
		P.verbs += /mob/players/proc/admin_teleport
		P.verbs += /mob/players/proc/admin_spawn_item
		P.verbs += /mob/players/proc/admin_kick_player
		P.verbs += /mob/players/proc/admin_mute_player
		P.verbs += /mob/players/proc/admin_panel
	else
		// Remove admin verbs
		P.verbs -= /mob/players/proc/admin_teleport
		P.verbs -= /mob/players/proc/admin_spawn_item
		P.verbs -= /mob/players/proc/admin_kick_player
		P.verbs -= /mob/players/proc/admin_mute_player
		P.verbs -= /mob/players/proc/admin_panel

// ============================================================================
// PLAYER ADMIN FIELDS
// ============================================================================

/**
 * Extend mob/players with admin fields
 */
/mob/players
	var
		admin_mode_active = 0   // 0=hidden, 1=showing admin verbs

// ============================================================================
// ADMIN VERBS (Stub implementations)
// ============================================================================

/**
 * admin_teleport()
 * Teleport command (requires PERM_TELEPORT)
 */
/mob/players/proc/admin_teleport()
	set name = "Admin Teleport"
	set desc = "Teleport to location or player"
	set category = "Admin"
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin || !admin.HasPermission(src.ckey, PERM_TELEPORT))
		src << "<span class='danger'>Permission denied.</span>"
		return
	
	var/target = input("Teleport to:", "Destination") as text
	if(!target) return
	
	src << "<span class='good'>Teleported to [target].</span>"
	world.log << "[src.ckey] used admin teleport to [target]"

/**
 * admin_spawn_item()
 * Spawn item command (requires PERM_SPAWN_ITEMS)
 */
/mob/players/proc/admin_spawn_item()
	set name = "Admin Spawn Item"
	set desc = "Spawn an item"
	set category = "Admin"
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin || !admin.HasPermission(src.ckey, PERM_SPAWN_ITEMS))
		src << "<span class='danger'>Permission denied.</span>"
		return
	
	var/item_type = input("Item type:", "Spawn") as text
	if(!item_type) return
	
	src << "<span class='good'>Spawned [item_type].</span>"
	world.log << "[src.ckey] spawned [item_type]"

/**
 * admin_kick_player()
 * Kick player command (requires PERM_KICK_PLAYER)
 */
/mob/players/proc/admin_kick_player()
	set name = "Admin Kick Player"
	set desc = "Kick a player from server"
	set category = "Admin"
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin || !admin.HasPermission(src.ckey, PERM_KICK_PLAYER))
		src << "<span class='danger'>Permission denied.</span>"
		return
	
	var/target = input("Kick player:", "Target") as text
	if(!target) return
	
	src << "<span class='good'>Kicked [target].</span>"
	world.log << "[src.ckey] kicked [target]"

/**
 * admin_mute_player()
 * Mute player command (requires PERM_MUTE_PLAYER)
 */
/mob/players/proc/admin_mute_player()
	set name = "Admin Mute Player"
	set desc = "Mute a player from chat"
	set category = "Admin"
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin || !admin.HasPermission(src.ckey, PERM_MUTE_PLAYER))
		src << "<span class='danger'>Permission denied.</span>"
		return
	
	var/target = input("Mute player:", "Target") as text
	if(!target) return
	
	src << "<span class='good'>Muted [target].</span>"
	world.log << "[src.ckey] muted [target]"

/**
 * admin_panel()
 * Admin panel command (requires PERM_ADMIN_PANEL)
 */
/mob/players/proc/admin_panel()
	set name = "Admin Panel"
	set desc = "Open admin control panel"
	set category = "Admin"
	
	var/datum/role_based_admin_manager/admin = GetAdminSystem()
	if(!admin || !admin.HasPermission(src.ckey, PERM_ADMIN_PANEL))
		src << "<span class='danger'>Permission denied.</span>"
		return
	
	src << "<span class='good'>Admin Panel opened.</span>"
	// TODO: Display admin panel UI
	world.log << "[src.ckey] opened admin panel"

