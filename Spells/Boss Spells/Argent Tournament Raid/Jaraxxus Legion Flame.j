//===========================================================================
// JARAXXUS - LEGION FLAME
//
// Pure trigger-driven boss mechanic.
//
// When Jaraxxus is below 70% HP and takes damage:
//
//   - Counts living human-player heroes inside Argent Tournament Raid.
//   - Spawns Hero Count + 2 Legion Flames.
//   - Minimum 3 flames, maximum 6.
//   - Flames spawn at random positions inside the arena.
//   - Spawn logic TRIES to remain 300 range from heroes, but after several
//     attempts simply accepts the best position found.
//   - Each flame slowly moves toward the nearest living player hero.
//   - Each flame periodically damages nearby player-owned units.
//   - If a flame comes within 80 range of any hero, it explodes.
//   - Any flame still alive after 8 seconds explodes automatically.
//
// No damage is dealt to Neutral Hostile or other non-human player units.
//
// Requires:
//      udg_Jaraxxus
//      udg_LegionFlameData     Hashtable, NOT array
//
// Region:
//      gg_rct_Argent_Tournament_Raid
//
// Main flame:
//      war3mapImported\Ember Green.mdx
//
// Minor damage:
//      war3mapImported\Firebrand Shot Green.mdx
//
// Explosion:
//      war3mapImported\FelMeteor.mdx
//      war3mapImported\Pillar of Flame Fel.mdx
//===========================================================================


//===========================================================================
// ADJUSTABLE SETTINGS
//===========================================================================

function Jaraxxus_Legion_Flame_Duration takes nothing returns real
    return 8.00
endfunction

function Jaraxxus_Legion_Flame_Speed takes nothing returns real
    return 150.00
endfunction

function Jaraxxus_Legion_Flame_Damage takes nothing returns real
    return 300.00
endfunction

function Jaraxxus_Legion_Flame_Damage_Interval takes nothing returns real
    return 0.50
endfunction

function Jaraxxus_Legion_Flame_Damage_Radius takes nothing returns real
    return 200.00
endfunction

function Jaraxxus_Legion_Flame_Explosion_Damage takes nothing returns real
    return 1200.00
endfunction

function Jaraxxus_Legion_Flame_Explosion_Radius takes nothing returns real
    return 250.00
endfunction

function Jaraxxus_Legion_Flame_Trigger_Radius takes nothing returns real
    return 80.00
endfunction

function Jaraxxus_Legion_Flame_Spawn_Clearance takes nothing returns real
    return 300.00
endfunction

function Jaraxxus_Legion_Flame_Spawn_Attempts takes nothing returns integer
    // We try this many random locations before accepting the best one found.
    return 8
endfunction


//===========================================================================
// PLAYER UNIT CHECK
//===========================================================================

function Jaraxxus_Legion_Flame_Is_Player_Unit takes unit u returns boolean
    local player p

    if u == null or GetUnitTypeId(u) == 0 then
        return false
    endif

    if GetWidgetLife(u) <= 0.405 then
        return false
    endif

    set p = GetOwningPlayer(u)

    if GetPlayerController(p) != MAP_CONTROL_USER then
        set p = null
        return false
    endif

    if GetPlayerSlotState(p) != PLAYER_SLOT_STATE_PLAYING then
        set p = null
        return false
    endif

    set p = null
    return true
endfunction


//===========================================================================
// PLAYER HERO CHECK
//===========================================================================

function Jaraxxus_Legion_Flame_Is_Player_Hero takes unit u returns boolean
    if not Jaraxxus_Legion_Flame_Is_Player_Unit(u) then
        return false
    endif

    return IsUnitType(u, UNIT_TYPE_HERO)
endfunction


//===========================================================================
// COUNT VALID HEROES IN GROUP
//===========================================================================

function Jaraxxus_Legion_Flame_Count_Heroes takes group g returns integer
    local integer i = 0
    local integer n = BlzGroupGetSize(g)
    local integer count = 0
    local unit u

    loop
        exitwhen i >= n

        set u = BlzGroupUnitAt(g, i)

        if Jaraxxus_Legion_Flame_Is_Player_Hero(u) then
            set count = count + 1
        endif

        set i = i + 1
    endloop

    set u = null
    return count
endfunction


//===========================================================================
// CLOSEST HERO
//===========================================================================

function Jaraxxus_Legion_Flame_Closest_Hero takes group g, real x, real y returns unit
    local integer i = 0
    local integer n = BlzGroupGetSize(g)
    local unit u
    local unit best = null
    local real dx
    local real dy
    local real dist
    local real bestDist = 999999999.00

    loop
        exitwhen i >= n

        set u = BlzGroupUnitAt(g, i)

        if Jaraxxus_Legion_Flame_Is_Player_Hero(u) then
            set dx = GetUnitX(u) - x
            set dy = GetUnitY(u) - y
            set dist = dx * dx + dy * dy

            if dist < bestDist then
                set bestDist = dist
                set best = u
            endif
        endif

        set i = i + 1
    endloop

    set u = null
    return best
endfunction


//===========================================================================
// DISTANCE TO NEAREST HERO
//
// Used only during initial spawn selection.
//===========================================================================

function Jaraxxus_Legion_Flame_Nearest_Hero_Distance_Squared takes group g, real x, real y returns real
    local integer i = 0
    local integer n = BlzGroupGetSize(g)
    local unit u
    local real dx
    local real dy
    local real dist
    local real bestDist = 999999999.00

    loop
        exitwhen i >= n

        set u = BlzGroupUnitAt(g, i)

        if Jaraxxus_Legion_Flame_Is_Player_Hero(u) then
            set dx = GetUnitX(u) - x
            set dy = GetUnitY(u) - y
            set dist = dx * dx + dy * dy

            if dist < bestDist then
                set bestDist = dist
            endif
        endif

        set i = i + 1
    endloop

    set u = null
    return bestDist
endfunction


//===========================================================================
// MINOR DAMAGE EFFECT
//===========================================================================

function Jaraxxus_Legion_Flame_Hit_Effect takes unit u returns nothing
    local effect e

    set e = AddSpecialEffect("war3mapImported\\Firebrand Shot Green.mdx", GetUnitX(u), GetUnitY(u))
    call BlzSetSpecialEffectScale(e, 1.50)
    call DestroyEffect(e)

    set e = null
endfunction


//===========================================================================
// DAMAGE PLAYER UNITS IN AREA
//===========================================================================

function Jaraxxus_Legion_Flame_Damage_Area takes real x, real y, real radius, real damage returns nothing
    local group g = CreateGroup()
    local unit u

    call GroupEnumUnitsInRange(g, x, y, radius, null)

    loop
        set u = FirstOfGroup(g)
        exitwhen u == null

        call GroupRemoveUnit(g, u)

        if Jaraxxus_Legion_Flame_Is_Player_Unit(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
            call Jaraxxus_Legion_Flame_Hit_Effect(u)
            call UnitDamageTarget(udg_Jaraxxus, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
        endif
    endloop

    call DestroyGroup(g)

    set u = null
    set g = null
endfunction


//===========================================================================
// EXPLODE ONE FLAME
//===========================================================================

function Jaraxxus_Legion_Flame_Explode takes timer t, integer i returns nothing
    local integer key = GetHandleId(t)
    local real x
    local real y
    local effect flame
    local effect e

    if not LoadBoolean(udg_LegionFlameData, key, 5000 + i) then
        return
    endif

    set x = LoadReal(udg_LegionFlameData, key, 1000 + i)
    set y = LoadReal(udg_LegionFlameData, key, 2000 + i)
    set flame = LoadEffectHandle(udg_LegionFlameData, key, 3000 + i)

    // Mark inactive FIRST so this flame cannot explode twice.
    call SaveBoolean(udg_LegionFlameData, key, 5000 + i, false)

    if flame != null then
        call BlzSetSpecialEffectAlpha(flame, 0)
        call DestroyEffect(flame)
    endif

    // Explosion visuals.
    set e = AddSpecialEffect("war3mapImported\\FelMeteor.mdx", x, y)
    call BlzSetSpecialEffectScale(e, 1.00)
    call DestroyEffect(e)

    set e = AddSpecialEffect("war3mapImported\\Pillar of Flame Fel.mdx", x, y)
    call BlzSetSpecialEffectScale(e, 1.00)
    call DestroyEffect(e)

    // Massive player-only AoE damage.
    call Jaraxxus_Legion_Flame_Damage_Area(x, y, Jaraxxus_Legion_Flame_Explosion_Radius(), Jaraxxus_Legion_Flame_Explosion_Damage())

    set e = null
    set flame = null
endfunction


//===========================================================================
// CLEAN UP WITHOUT EXPLOSION
//
// Used if Jaraxxus dies while the mechanic is still active.
//===========================================================================

function Jaraxxus_Legion_Flame_Cleanup takes timer t returns nothing
    local integer key = GetHandleId(t)
    local integer count = LoadInteger(udg_LegionFlameData, key, 0)
    local integer i = 1
    local effect flame
    local group heroes = LoadGroupHandle(udg_LegionFlameData, key, 3)

    loop
        exitwhen i > count

        set flame = LoadEffectHandle(udg_LegionFlameData, key, 3000 + i)

        if flame != null then
            call BlzSetSpecialEffectAlpha(flame, 0)
            call DestroyEffect(flame)
        endif

        set i = i + 1
    endloop

    if heroes != null then
        call DestroyGroup(heroes)
    endif

    call FlushChildHashtable(udg_LegionFlameData, key)
    call PauseTimer(t)
    call DestroyTimer(t)

    set heroes = null
    set flame = null
endfunction


//===========================================================================
// PERIODIC
//===========================================================================

function Jaraxxus_Legion_Flame_Periodic takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer key = GetHandleId(t)
    local integer count = LoadInteger(udg_LegionFlameData, key, 0)
    local integer i = 1
    local integer active = 0

    local group heroes = LoadGroupHandle(udg_LegionFlameData, key, 3)
    local unit target

    local real period = 0.05
    local real elapsed = LoadReal(udg_LegionFlameData, key, 1) + period
    local real damageClock = LoadReal(udg_LegionFlameData, key, 2) + period

    local real x
    local real y
    local real tx
    local real ty
    local real dx
    local real dy
    local real dist
    local real step
    local real triggerRadiusSquared = Jaraxxus_Legion_Flame_Trigger_Radius() * Jaraxxus_Legion_Flame_Trigger_Radius()

    local effect flame

    // If Jaraxxus dies, remove the mechanic immediately.
    if udg_Jaraxxus == null or GetWidgetLife(udg_Jaraxxus) <= 0.405 then
        call Jaraxxus_Legion_Flame_Cleanup(t)
        set heroes = null
        set t = null
        return
    endif

    // Refresh the current living heroes once per tick.
    call GroupClear(heroes)
    call GroupEnumUnitsInRect(heroes, gg_rct_Argent_Tournament_Raid, null)

    // All surviving flames expire together after the duration.
    if elapsed >= Jaraxxus_Legion_Flame_Duration() then
        loop
            exitwhen i > count

            if LoadBoolean(udg_LegionFlameData, key, 5000 + i) then
                call Jaraxxus_Legion_Flame_Explode(t, i)
            endif

            set i = i + 1
        endloop

        call Jaraxxus_Legion_Flame_Cleanup(t)

        set heroes = null
        set t = null
        return
    endif

    // Move every active flame toward its nearest hero.
    loop
        exitwhen i > count

        if LoadBoolean(udg_LegionFlameData, key, 5000 + i) then
            set x = LoadReal(udg_LegionFlameData, key, 1000 + i)
            set y = LoadReal(udg_LegionFlameData, key, 2000 + i)
            set flame = LoadEffectHandle(udg_LegionFlameData, key, 3000 + i)

            set target = Jaraxxus_Legion_Flame_Closest_Hero(heroes, x, y)

            if target != null then
                set tx = GetUnitX(target)
                set ty = GetUnitY(target)
                set dx = tx - x
                set dy = ty - y
                set dist = SquareRoot(dx * dx + dy * dy)

                // Proximity detonation.
                if dx * dx + dy * dy <= triggerRadiusSquared then
                    call Jaraxxus_Legion_Flame_Explode(t, i)
                else
                    set step = Jaraxxus_Legion_Flame_Speed() * period

                    // Do not overshoot the target.
                    if step > dist then
                        set step = dist
                    endif

                    if dist > 0.00 then
                        set x = x + dx / dist * step
                        set y = y + dy / dist * step
                    endif

                    call SaveReal(udg_LegionFlameData, key, 1000 + i, x)
                    call SaveReal(udg_LegionFlameData, key, 2000 + i, y)

                    if flame != null then
                        call BlzSetSpecialEffectX(flame, x)
                        call BlzSetSpecialEffectY(flame, y)
                    endif

                    // Check AGAIN after movement in case the flame crossed
                    // into detonation range during this tick.
                    set dx = GetUnitX(target) - x
                    set dy = GetUnitY(target) - y

                    if dx * dx + dy * dy <= triggerRadiusSquared then
                        call Jaraxxus_Legion_Flame_Explode(t, i)
                    endif
                endif
            endif

            if LoadBoolean(udg_LegionFlameData, key, 5000 + i) then
                set active = active + 1
            endif
        endif

        set i = i + 1
    endloop

    // Periodic aura damage from every active flame.
    if damageClock >= Jaraxxus_Legion_Flame_Damage_Interval() then
        set damageClock = damageClock - Jaraxxus_Legion_Flame_Damage_Interval()

        set i = 1

        loop
            exitwhen i > count

            if LoadBoolean(udg_LegionFlameData, key, 5000 + i) then
                set x = LoadReal(udg_LegionFlameData, key, 1000 + i)
                set y = LoadReal(udg_LegionFlameData, key, 2000 + i)
                call Jaraxxus_Legion_Flame_Damage_Area(x, y, Jaraxxus_Legion_Flame_Damage_Radius(), Jaraxxus_Legion_Flame_Damage())
            endif

            set i = i + 1
        endloop
    endif

    call SaveReal(udg_LegionFlameData, key, 1, elapsed)
    call SaveReal(udg_LegionFlameData, key, 2, damageClock)

    // If every flame was triggered early, terminate immediately.
    if active == 0 then
        call Jaraxxus_Legion_Flame_Cleanup(t)
    endif

    set flame = null
    set target = null
    set heroes = null
    set t = null
endfunction


//===========================================================================
// START
//===========================================================================

function Jaraxxus_Legion_Flame_Start takes nothing returns boolean
    local timer t
    local integer key

    local group heroes = CreateGroup()
    local integer heroCount
    local integer flameCount
    local integer i = 1
    local integer attempt

    local real minX = GetRectMinX(gg_rct_Argent_Tournament_Raid) + 32.00
    local real maxX = GetRectMaxX(gg_rct_Argent_Tournament_Raid) - 32.00
    local real minY = GetRectMinY(gg_rct_Argent_Tournament_Raid) + 32.00
    local real maxY = GetRectMaxY(gg_rct_Argent_Tournament_Raid) - 32.00

    local real x
    local real y
    local real testX
    local real testY

    local real distanceSquared
    local real bestDistanceSquared
    local real desiredDistanceSquared = Jaraxxus_Legion_Flame_Spawn_Clearance() * Jaraxxus_Legion_Flame_Spawn_Clearance()

    local effect flame

    if udg_Jaraxxus == null or GetWidgetLife(udg_Jaraxxus) <= 0.405 then
        call DestroyGroup(heroes)
        set heroes = null
        return false
    endif

    call GroupEnumUnitsInRect(heroes, gg_rct_Argent_Tournament_Raid, null)

    set heroCount = Jaraxxus_Legion_Flame_Count_Heroes(heroes)

    if heroCount <= 0 then
        call DestroyGroup(heroes)
        set heroes = null
        return false
    endif

    // Heroes + 2, minimum 3, maximum 6.
    set flameCount = heroCount + 2

    if flameCount < 3 then
        set flameCount = 3
    endif

    if flameCount > 6 then
        set flameCount = 6
    endif

    if udg_LegionFlameData == null then
        set udg_LegionFlameData = InitHashtable()
    endif

    set t = CreateTimer()
    set key = GetHandleId(t)

    call SaveInteger(udg_LegionFlameData, key, 0, flameCount)
    call SaveReal(udg_LegionFlameData, key, 1, 0.00)
    call SaveReal(udg_LegionFlameData, key, 2, 0.00)
    call SaveGroupHandle(udg_LegionFlameData, key, 3, heroes)

    loop
        exitwhen i > flameCount

        // ---------------------------------------------------------------
        // BEST-EFFORT SPAWN POSITION
        //
        // Try a few random points.
        //
        // If one satisfies the 300 clearance requirement, use it
        // immediately.
        //
        // Otherwise use whichever tested point was furthest from the
        // nearest hero.
        // ---------------------------------------------------------------

        set attempt = 0
        set bestDistanceSquared = -1.00
        set x = GetRandomReal(minX, maxX)
        set y = GetRandomReal(minY, maxY)

        loop
            exitwhen attempt >= Jaraxxus_Legion_Flame_Spawn_Attempts()

            set testX = GetRandomReal(minX, maxX)
            set testY = GetRandomReal(minY, maxY)

            set distanceSquared = Jaraxxus_Legion_Flame_Nearest_Hero_Distance_Squared(heroes, testX, testY)

            if distanceSquared > bestDistanceSquared then
                set bestDistanceSquared = distanceSquared
                set x = testX
                set y = testY
            endif

            set attempt = attempt + 1

            // Good enough. Don't overthink the placement.
            if distanceSquared >= desiredDistanceSquared then
                set attempt = Jaraxxus_Legion_Flame_Spawn_Attempts()
            endif
        endloop

        set flame = AddSpecialEffect("war3mapImported\\Ember Green.mdx", x, y)
        call BlzSetSpecialEffectScale(flame, 1.20)
        call BlzSetSpecialEffectZ(flame, BlzGetLocalSpecialEffectZ(flame) + 25.00)

        call SaveReal(udg_LegionFlameData, key, 1000 + i, x)
        call SaveReal(udg_LegionFlameData, key, 2000 + i, y)
        call SaveEffectHandle(udg_LegionFlameData, key, 3000 + i, flame)
        call SaveBoolean(udg_LegionFlameData, key, 5000 + i, true)

        set i = i + 1
    endloop

    call TimerStart(t, 0.05, true, function Jaraxxus_Legion_Flame_Periodic)

    set flame = null
    set heroes = null
    set t = null

    return true
endfunction


//===========================================================================
// DAMAGE EVENT
//===========================================================================

function Trig_Jaraxxus_Legion_Flame_Conditions takes nothing returns boolean
    if GetTriggerUnit() != udg_Jaraxxus then
        return false
    endif

    if GetUnitState(udg_Jaraxxus, UNIT_STATE_LIFE) >= GetUnitState(udg_Jaraxxus, UNIT_STATE_MAX_LIFE) * 0.70 then
        return false
    endif

    return true
endfunction


function Trig_Jaraxxus_Legion_Flame_Actions takes nothing returns nothing
    local trigger t = GetTriggeringTrigger()

    // Only consume the cooldown if there is actually at least one living
    // player hero inside the raid and Legion Flame successfully starts.
    if Jaraxxus_Legion_Flame_Start() then
        call DisableTrigger(t)
        call GameTimeWait(18.00)
        call EnableTrigger(t)
    endif

    set t = null
endfunction


//===========================================================================
function InitTrig_Jaraxxus_Legion_Flame takes nothing returns nothing
    set gg_trg_Jaraxxus_Legion_Flame = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Jaraxxus_Legion_Flame, EVENT_PLAYER_UNIT_DAMAGED)
    call TriggerAddCondition(gg_trg_Jaraxxus_Legion_Flame, Condition(function Trig_Jaraxxus_Legion_Flame_Conditions))
    call TriggerAddAction(gg_trg_Jaraxxus_Legion_Flame, function Trig_Jaraxxus_Legion_Flame_Actions)
endfunction