globals
    //===========================================================================
    // RATTLEGORE BONE PILE CONFIG
    //===========================================================================

    // How often a new pile attempts to spawn.
    constant real RBP_SPAWN_PERIOD = 5.00

    // How frequently Rattlegore checks for nearby piles.
    constant real RBP_CHECK_PERIOD = 0.10

    // How often Rattlegore reissues his move order toward the nearest pile
    // while he does NOT currently have Bone Armor.
    constant real RBP_SEEK_PERIOD = 4.5

    // Maximum number of bone piles that may exist at once.
    // Consuming a pile opens a slot for another to spawn.
    constant integer RBP_MAX_ACTIVE_PILES = 5

    // Rattlegore consumes a pile when within this distance.
    constant real RBP_PICKUP_RANGE = 130.00

    // Don't spawn a new pile directly underneath Rattlegore.
    constant real RBP_MIN_SPAWN_DISTANCE = 300.00

    // Prevent piles from appearing too close together.
    // 300 also prevents two 140-radius pickup zones from substantially overlapping.
    constant real RBP_MIN_PILE_DISTANCE = 300.00

    // Maximum random positions attempted before giving up on that spawn tick.
    constant integer RBP_SPAWN_ATTEMPTS = 12

    // Region weighting.
    constant integer RBP_CINEMATIC_REGION_CHANCE = 35

    // Models.
    constant string RBP_REMAINS_MODEL = "Doodads\\Ashenvale\\Props\\ScorchedRemains\\ScorchedRemains1.mdl"
    constant string RBP_BONE_MODEL    = "war3mapImported\\Bone Guard.mdx"

    constant string RBP_ABSORB_EFFECT_1 = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    constant string RBP_ABSORB_EFFECT_2 = "war3mapImported\\Soul Armor Necro_opt.mdx"

    // Existing Bone Armor dummy system.
    constant integer RBP_BONE_ARMOR_ABILITY = 'A0BF'
    constant integer RBP_BONE_ARMOR_LEVEL   = 44


    //===========================================================================
    // INTERNAL STATE
    //===========================================================================

    timer RBP_SpawnTimer = null
    timer RBP_CheckTimer = null

    integer RBP_Count = 0
    real RBP_SeekElapsed = 0.00
    boolean RBP_Running = false

    real array RBP_X
    real array RBP_Y

    effect array RBP_Remains
    effect array RBP_Bones
endglobals


//===========================================================================
// Returns true if a candidate spawn position is far enough from Rattlegore
// and all existing bone piles.
//===========================================================================
function RBP_IsSpawnPointValid takes real x, real y returns boolean
    local integer i = 0
    local real dx
    local real dy
    local real distSq

    // Don't spawn directly underneath Rattlegore.
    if udg_Rattlegore != null then
        set dx = x - GetUnitX(udg_Rattlegore)
        set dy = y - GetUnitY(udg_Rattlegore)

        if dx * dx + dy * dy < RBP_MIN_SPAWN_DISTANCE * RBP_MIN_SPAWN_DISTANCE then
            return false
        endif
    endif

    // Don't overlap existing piles.
    loop
        exitwhen i >= RBP_Count

        set dx = x - RBP_X[i]
        set dy = y - RBP_Y[i]
        set distSq = dx * dx + dy * dy

        if distSq < RBP_MIN_PILE_DISTANCE * RBP_MIN_PILE_DISTANCE then
            return false
        endif

        set i = i + 1
    endloop

    return true
endfunction


//===========================================================================
// Creates one bone pile.
//===========================================================================
function RBP_CreatePile takes real x, real y returns nothing
    local integer i = RBP_Count

    if RBP_Count >= RBP_MAX_ACTIVE_PILES then
        return
    endif

    set RBP_X[i] = x
    set RBP_Y[i] = y

    set RBP_Remains[i] = AddSpecialEffect(RBP_REMAINS_MODEL, x, y)
    set RBP_Bones[i]   = AddSpecialEffect(RBP_BONE_MODEL, x, y)

    set RBP_Count = RBP_Count + 1
endfunction


//===========================================================================
// Removes one pile from the array.
//
// The last active pile is moved into the removed pile's slot so the arrays
// remain dense:
//
//     0 1 2 3 4
//         X
//
// becomes:
//
//     0 1 4 3
//
// This avoids holes and keeps all periodic loops extremely simple.
//===========================================================================
function RBP_RemovePile takes integer index returns nothing
    local integer last = RBP_Count - 1

    if index < 0 or index >= RBP_Count then
        return
    endif

    if RBP_Remains[index] != null then
        call DestroyEffect(RBP_Remains[index])
    endif

    if RBP_Bones[index] != null then
        call DestroyEffect(RBP_Bones[index])
    endif

    // Move the final pile into the newly empty slot.
    if index != last then
        set RBP_X[index] = RBP_X[last]
        set RBP_Y[index] = RBP_Y[last]

        set RBP_Remains[index] = RBP_Remains[last]
        set RBP_Bones[index]   = RBP_Bones[last]
    endif

    set RBP_Remains[last] = null
    set RBP_Bones[last] = null

    set RBP_X[last] = 0.00
    set RBP_Y[last] = 0.00

    set RBP_Count = last
endfunction


//===========================================================================
// Rattlegore reached a bone pile.
//===========================================================================
function RBP_ConsumePile takes integer index returns nothing
    local real x
    local real y

    if udg_Rattlegore == null then
        return
    endif

    set x = GetUnitX(udg_Rattlegore)
    set y = GetUnitY(udg_Rattlegore)


    // The ground pile is consumed immediately.
    call RBP_RemovePile(index)

    // Absorption visuals on Rattlegore.
    call DestroyEffect(AddSpecialEffect(RBP_ABSORB_EFFECT_1, x, y))
    call DestroyEffect(AddSpecialEffect(RBP_ABSORB_EFFECT_2, x, y))

    // Check BEFORE removing/altering anything.
    if GetBoneShieldLevel(udg_Rattlegore) > 0 then

        // Rattlegore already possesses Bone Armor.
        // Reaching another pile causes him to immediately attempt Bonestorm.
        //
        // Bonestorm itself handles:
        //   - checking whether Bone Armor still exists
        //   - damage
        //   - consuming Bone Armor
        //   - converting its damage into an absorption shield
        call BlzEndUnitAbilityCooldown(udg_Rattlegore, 'A0FJ')
        call IssueImmediateOrder(udg_Rattlegore, "battleroar")
    endif

    // Give him the full +30 armor through the existing armor dummy.
    call SetUnitAbilityLevel(gg_unit_e03G_2001, RBP_BONE_ARMOR_ABILITY, RBP_BONE_ARMOR_LEVEL)
    call IssueTargetOrder(gg_unit_e03G_2001, "innerfire", udg_Rattlegore)

endfunction


//===========================================================================
// Orders Rattlegore toward the closest pile.
//
// This is only called while he does NOT currently have Bone Armor.
//===========================================================================
function RBP_SeekNearestPile takes nothing returns nothing
    local integer i = 0
    local integer nearest = -1

    local real rx
    local real ry
    local real dx
    local real dy
    local real distSq
    local real nearestDistSq = 999999999.00

    if udg_Rattlegore == null then
        return
    endif

    if RBP_Count <= 0 then
        return
    endif

    // Once he has Bone Armor, stop deliberately seeking additional piles.
    if GetBoneShieldLevel(udg_Rattlegore) > 0 then
        return
    endif

    set rx = GetUnitX(udg_Rattlegore)
    set ry = GetUnitY(udg_Rattlegore)

    loop
        exitwhen i >= RBP_Count

        set dx = RBP_X[i] - rx
        set dy = RBP_Y[i] - ry
        set distSq = dx * dx + dy * dy

        if distSq < nearestDistSq then
            set nearestDistSq = distSq
            set nearest = i
        endif

        set i = i + 1
    endloop

    if nearest >= 0 then
        call IssuePointOrder(udg_Rattlegore, "move", RBP_X[nearest], RBP_Y[nearest])
    endif
endfunction


//===========================================================================
// Checks whether Rattlegore has reached any active bone pile.
//===========================================================================
function RBP_CheckProximity takes nothing returns nothing
    local integer i = 0
    local real rx
    local real ry
    local real dx
    local real dy

    if not RBP_Running then
        return
    endif

    if udg_Rattlegore == null then
        return
    endif

    set rx = GetUnitX(udg_Rattlegore)
    set ry = GetUnitY(udg_Rattlegore)

    // Check pile collisions.
    loop
        exitwhen i >= RBP_Count

        set dx = rx - RBP_X[i]
        set dy = ry - RBP_Y[i]

        if dx * dx + dy * dy <= RBP_PICKUP_RANGE * RBP_PICKUP_RANGE then

            call RBP_ConsumePile(i)

            // Only allow one pile to be consumed per 0.10 sec tick.
            // This prevents weird double-consumption if two piles happen
            // to be close to Rattlegore at the same instant.
            return
        endif

        set i = i + 1
    endloop

    // Seeking does not need to run every 0.10 sec.
    set RBP_SeekElapsed = RBP_SeekElapsed + RBP_CHECK_PERIOD

    if RBP_SeekElapsed >= RBP_SEEK_PERIOD then
        set RBP_SeekElapsed = 0.00
        call RBP_SeekNearestPile()
    endif
endfunction


//===========================================================================
// Attempts to spawn one random pile.
//===========================================================================
function RBP_SpawnPile takes nothing returns nothing
    local rect r
    local real x
    local real y
    local integer attempts = 0

    if not RBP_Running then
        return
    endif

    if udg_Rattlegore == null then
        return
    endif

    if RBP_Count >= RBP_MAX_ACTIVE_PILES then
        return
    endif

    // 35% Rattlegore Cinematic Start
    // 65% Scholomance Creeps NS
    if GetRandomInt(1, 100) <= RBP_CINEMATIC_REGION_CHANCE then
        set r = gg_rct_Rattlegore_Cinematic_Start
    else
        set r = gg_rct_Scholomance_Creeps_NS
    endif

    loop
        exitwhen attempts >= RBP_SPAWN_ATTEMPTS

        set x = GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
        set y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r))

        if RBP_IsSpawnPointValid(x, y) then
            call RBP_CreatePile(x, y)
            set r = null
            return
        endif

        set attempts = attempts + 1
    endloop

    // If every candidate was invalid, simply skip this spawn tick.
    set r = null
endfunction


//===========================================================================
// Timer callbacks.
//===========================================================================
function RBP_SpawnTimerCallback takes nothing returns nothing
    call RBP_SpawnPile()
endfunction

function RBP_CheckTimerCallback takes nothing returns nothing
    call RBP_CheckProximity()
endfunction


//===========================================================================
// PUBLIC: Clears the encounter.
//
// Call this from Rattlegore's death/reset trigger.
//===========================================================================
function RBP_Clear takes nothing returns nothing
    local integer i = 0

    set RBP_Running = false

    call PauseTimer(RBP_SpawnTimer)
    call PauseTimer(RBP_CheckTimer)

    loop
        exitwhen i >= RBP_Count

        if RBP_Remains[i] != null then
            call DestroyEffect(RBP_Remains[i])
            set RBP_Remains[i] = null
        endif

        if RBP_Bones[i] != null then
            call DestroyEffect(RBP_Bones[i])
            set RBP_Bones[i] = null
        endif

        set RBP_X[i] = 0.00
        set RBP_Y[i] = 0.00

        set i = i + 1
    endloop

    set RBP_Count = 0
    set RBP_SeekElapsed = 0.00
endfunction


//===========================================================================
// PUBLIC: Starts the encounter mechanic.
//
// Call this when the Rattlegore fight begins.
// The first pile spawns after RBP_SPAWN_PERIOD seconds.
//===========================================================================
function RBP_Start takes nothing returns nothing

    // Makes this safe if the fight is ever restarted/reset.
    call RBP_Clear()

    set RBP_Running = true
    set RBP_SeekElapsed = 0.00

    if RBP_SpawnTimer == null then
        set RBP_SpawnTimer = CreateTimer()
    endif

    if RBP_CheckTimer == null then
        set RBP_CheckTimer = CreateTimer()
    endif

    call TimerStart(RBP_SpawnTimer, RBP_SPAWN_PERIOD, true, function RBP_SpawnTimerCallback)
    call TimerStart(RBP_CheckTimer, RBP_CHECK_PERIOD, true, function RBP_CheckTimerCallback)
endfunction