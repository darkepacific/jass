//===========================================================================
// MAOKI BOATS - v10 MULTI-ROUTE
//
// Expands the proven v9.1 boat system to four independent, non-intersecting
// routes:
//
//   Route 8  = Maoki WE 8   =  8 platforms, moves east/west
//   Route 9  = Maoki NS 9   =  9 platforms, moves north/south
//   Route 10 = Maoki WE 10  = 10 platforms, moves east/west
//   Route 11 = Maoki WE 11  = 11 platforms, moves east/west
//
// IMPORTANT EDITOR SETUP
// ----------------------
// 1. GUI variable:
//      MaokiBoatData    Hashtable    NOT an array
//
// 2. These four regions must exist:
//      Maoki WE 8
//      Maoki NS 9
//      Maoki WE 10
//      Maoki WE 11
//
//    Each route region should contain ONLY its water/platform lane.
//    Stop each route region at permanent walkable land / the shared iceberg.
//
// 3. Invisible Platforms ('OTip'):
//      Maoki WE 8  -> exactly  8
//      Maoki NS 9  -> exactly  9
//      Maoki WE 10 -> exactly 10
//      Maoki WE 11 -> exactly 11
//
//    ALL must start ALIVE in the editor.
//
// 4. There must be ZERO preplaced 'YTpc' Ground Pathing Blockers inside
//    those four route regions. V10 creates the blockers at runtime.
//
// 5. EXPAND the existing "Maoki Boats" region so it contains ALL FOUR
//    complete boat routes plus their boarding/disembarking approaches.
//    It may contain extra nearby land; that is okay. This region is only
//    used to maintain the shared candidate-unit list.
//
// PATHING WORKAROUND (same proven v9.1 method)
// --------------------------------------------
// All OTip platforms begin alive so WC3 initializes walkable pathing across
// the water. One second after map initialization, this trigger:
//   - validates all four route layouts BEFORE changing anything,
//   - kills every route platform,
//   - creates a YTpc blocker at every platform center,
//   - opens only the cells currently beneath each boat.
//
// Runtime:
//   boat over cell  = platform alive, blocker dead
//   boat away       = platform dead,  blocker alive
//
// Since the four routes do not intersect, the boats move independently.
// There is no collision/timing synchronization between routes.
//
// MOVEMENT
// --------
// Default speed: 48 world units/sec.
// Update rate: 32/sec.
// Dock wait: 2 sec.
// Each boat spans approximately two platform cells, same as v9.1.
// Boats shuttle backward on return; they do not rotate at endpoints.
// NS 9 uses a 90-degree visual yaw; the three WE routes use 0 degrees.
//
// TEST COMMANDS
// -------------
//   -boat               one-line status for all four routes
//   -boatmap            labels every managed P/B pair for 90 sec
//   -boatpause          pauses all four boats
//   -boatresume         resumes all four boats
//   -boatblockers off   diagnostic: kills every managed blocker
//   -boatblockers on    restores normal blocker management
//
// If a gg_rct_* name is undefined when compiling, reference that region once
// in a temporary/no-action GUI region event so World Editor emits the global.
//
// VALIDATION
// ----------
// Generated from the working Maoki_Long_Boat_v9_1 system.
// Not compiled inside the user's Warcraft III map.
//===========================================================================


//===========================================================================
// ROUTE HELPERS
//===========================================================================

function MLB_Base takes integer route returns integer
    return route * 100
endfunction

function MLB_RouteName takes integer route returns string
    if route == 8 then
        return "WE8"
    elseif route == 9 then
        return "NS9"
    elseif route == 10 then
        return "WE10"
    endif
    return "WE11"
endfunction

function MLB_IsVertical takes integer route returns boolean
    return route == 9
endfunction

function MLB_PathRect takes integer route returns rect
    if route == 8 then
        return gg_rct_Maoki_WE_8
    elseif route == 9 then
        return gg_rct_Maoki_NS_9
    elseif route == 10 then
        return gg_rct_Maoki_WE_10
    elseif route == 11 then
        return gg_rct_Maoki_WE_11
    endif
    return null
endfunction

function MLB_AxisOf takes destructable d, boolean vertical returns real
    if vertical then
        return GetDestructableY(d)
    endif
    return GetDestructableX(d)
endfunction

function MLB_PerpendicularOf takes destructable d, boolean vertical returns real
    if vertical then
        return GetDestructableX(d)
    endif
    return GetDestructableY(d)
endfunction

function MLB_BoolText takes boolean b returns string
    if b then
        return "yes"
    endif
    return "no"
endfunction


//===========================================================================
// DISCOVERY / SORTING
//===========================================================================

// During synchronous route discovery, global parent 9000 child 0 stores
// the route currently being enumerated.
function MLB_DiscoverDeckDestructable takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer route = LoadInteger(h, 9000, 0)
    local integer base = MLB_Base(route)
    local destructable d = GetEnumDestructable()
    local integer n
    local integer typeId = GetDestructableTypeId(d)

    if typeId == 'OTip' then
        set n = LoadInteger(h, base, 40) + 1
        call SaveInteger(h, base, 40, n)
        call SaveDestructableHandle(h, base + 1, n, d)
    elseif typeId == 'YTpc' then
        // V10 expects ZERO preplaced blockers in every route region.
        call SaveInteger(h, base, 41, LoadInteger(h, base, 41) + 1)
    endif

    set d = null
    set h = null
endfunction

function MLB_SortPlatforms takes integer route returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer count = LoadInteger(h, base, 40)
    local boolean vertical = MLB_IsVertical(route)
    local integer i = 1
    local integer j
    local integer minIndex
    local real minAxis
    local real axis
    local destructable a
    local destructable b

    loop
        exitwhen i >= count
        set minIndex = i
        set a = LoadDestructableHandle(h, base + 1, i)
        set minAxis = MLB_AxisOf(a, vertical)
        set j = i + 1

        loop
            exitwhen j > count
            set b = LoadDestructableHandle(h, base + 1, j)
            set axis = MLB_AxisOf(b, vertical)
            if axis < minAxis then
                set minIndex = j
                set minAxis = axis
            endif
            set j = j + 1
        endloop

        if minIndex != i then
            set a = LoadDestructableHandle(h, base + 1, i)
            set b = LoadDestructableHandle(h, base + 1, minIndex)
            call SaveDestructableHandle(h, base + 1, i, b)
            call SaveDestructableHandle(h, base + 1, minIndex, a)
        endif

        set i = i + 1
    endloop

    set a = null
    set b = null
    set h = null
endfunction


//===========================================================================
// UNIT TRACKING
//===========================================================================

function MLB_CanRide takes unit u returns boolean
    if u == null or GetUnitTypeId(u) == 0 then
        return false
    endif

    return GetPlayerController(GetOwningPlayer(u)) == MAP_CONTROL_USER and GetWidgetLife(u) > 0.405 and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_FLYING) and not IsUnitHidden(u) and GetUnitAbilityLevel(u, 'Aloc') == 0
endfunction

function MLB_AddCandidate takes unit u returns nothing
    if u != null and GetUnitTypeId(u) != 0 and GetUnitAbilityLevel(u, 'Aloc') == 0 then
        call GroupAddUnit(LoadGroupHandle(udg_MaokiBoatData, 0, 0), u)
    endif
endfunction

function MLB_Enter takes nothing returns nothing
    call MLB_AddCandidate(GetEnteringUnit())
endfunction

function MLB_Forget takes unit u returns nothing
    call GroupRemoveUnit(LoadGroupHandle(udg_MaokiBoatData, 0, 0), u)
endfunction

function MLB_Leave takes nothing returns nothing
    local unit u = GetLeavingUnit()

    // Deferred leave events can fire after a unit has already returned.
    if not RectContainsCoords(LoadRectHandle(udg_MaokiBoatData, 0, 28), GetUnitX(u), GetUnitY(u)) then
        call MLB_Forget(u)
    endif

    set u = null
endfunction

function MLB_CleanCandidates takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local group g = LoadGroupHandle(h, 0, 0)
    local group spare = LoadGroupHandle(h, 0, 23)
    local integer n = BlzGroupGetSize(g)
    local integer i = 0
    local boolean dirty = false
    local unit u

    loop
        exitwhen i >= n or dirty
        set u = BlzGroupUnitAt(g, i)
        set dirty = u == null
        if u != null then
            set dirty = GetUnitTypeId(u) == 0
        endif
        set i = i + 1
    endloop

    if dirty then
        call GroupClear(spare)
        set i = 0

        loop
            exitwhen i >= n
            set u = BlzGroupUnitAt(g, i)
            if u != null and GetUnitTypeId(u) != 0 then
                call GroupAddUnit(spare, u)
            endif
            set i = i + 1
        endloop

        call GroupClear(g)
        call SaveGroupHandle(h, 0, 0, spare)
        call SaveGroupHandle(h, 0, 23, g)
    endif

    set u = null
    set g = null
    set spare = null
    set h = null
endfunction


//===========================================================================
// PLATFORM / BLOCKER STATE
//===========================================================================

function MLB_OpenDeck takes integer route, real boatAxis returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer count = LoadInteger(h, base, 40)
    local integer i = 1
    local real reach = LoadReal(h, base, 18) + LoadReal(h, base, 24)
    local destructable d
    local destructable blocker
    local boolean needed
    local boolean disabled = LoadBoolean(h, base, 43)

    // Pass 1: determine every required cell and remove incoming blockers.
    loop
        exitwhen i > count
        set needed = RAbsBJ(LoadReal(h, base + 2, i) - boatAxis) < reach - 0.01

        if needed != LoadBoolean(h, base + 3, i) then
            call SaveBoolean(h, base, 42, true)
        endif

        call SaveBoolean(h, base + 3, i, needed)
        set blocker = LoadDestructableHandle(h, base + 5, i)

        if needed or disabled then
            if GetDestructableLife(blocker) > 0.405 then
                call SetDestructableInvulnerable(blocker, false)
                call KillDestructable(blocker)
                call SaveBoolean(h, base, 42, true)
            endif
        endif

        set i = i + 1
    endloop

    // Pass 2: restore all required walking surfaces.
    set i = 1
    loop
        exitwhen i > count
        set d = LoadDestructableHandle(h, base + 1, i)

        if LoadBoolean(h, base + 3, i) and GetDestructableLife(d) <= 0.405 then
            call DestructableRestoreLife(d, GetDestructableMaxLife(d), false)
            call SaveBoolean(h, base, 42, true)
        endif

        set i = i + 1
    endloop

    set d = null
    set blocker = null
    set h = null
endfunction

function MLB_RescueOutgoing takes integer route, integer cell returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local boolean vertical = MLB_IsVertical(route)
    local group g = LoadGroupHandle(h, 0, 0)
    local rect path = LoadRectHandle(h, base, 46)
    local integer i = BlzGroupGetSize(g) - 1
    local real platformAxis = LoadReal(h, base + 2, cell)
    local real fixed = LoadReal(h, base, 11)
    local real boatAxis = LoadReal(h, base, 10)
    local real halfL = LoadReal(h, base, 18) - LoadReal(h, base, 26)
    local real halfW = LoadReal(h, base, 19) - LoadReal(h, base, 26)
    local real platformHalfL = LoadReal(h, base, 24)
    local real platformHalfW = LoadReal(h, base, 25)
    local real x
    local real y
    local unit u

    loop
        exitwhen i < 0
        set u = BlzGroupUnitAt(g, i)

        if MLB_CanRide(u) then
            set x = GetUnitX(u)
            set y = GetUnitY(u)

            if RectContainsCoords(path, x, y) then
                if vertical then
                    if RAbsBJ(y - platformAxis) <= platformHalfL and RAbsBJ(x - fixed) <= platformHalfW then
                        // Clamp to nearest point safely inside the N/S deck.
                        set x = RMaxBJ(fixed - halfW, RMinBJ(fixed + halfW, x))
                        set y = RMaxBJ(boatAxis - halfL, RMinBJ(boatAxis + halfL, y))
                        call SetUnitX(u, x)
                        call SetUnitY(u, y)
                    endif
                else
                    if RAbsBJ(x - platformAxis) <= platformHalfL and RAbsBJ(y - fixed) <= platformHalfW then
                        // Clamp to nearest point safely inside the W/E deck.
                        set x = RMaxBJ(boatAxis - halfL, RMinBJ(boatAxis + halfL, x))
                        set y = RMaxBJ(fixed - halfW, RMinBJ(fixed + halfW, y))
                        call SetUnitX(u, x)
                        call SetUnitY(u, y)
                    endif
                endif
            endif
        endif

        set i = i - 1
    endloop

    set u = null
    set path = null
    set g = null
    set h = null
endfunction

function MLB_CloseDeck takes integer route returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer count = LoadInteger(h, base, 40)
    local integer i = 1
    local destructable d
    local destructable blocker
    local boolean disabled = LoadBoolean(h, base, 43)

    // Pass 1: rescue occupants and close outgoing platforms.
    loop
        exitwhen i > count
        set d = LoadDestructableHandle(h, base + 1, i)

        if not LoadBoolean(h, base + 3, i) and GetDestructableLife(d) > 0.405 then
            call MLB_RescueOutgoing(route, i)
            call SetDestructableInvulnerable(d, false)
            call KillDestructable(d)
            call SaveReal(h, base + 4, i, GetDestructableLife(d))
            call SaveBoolean(h, base, 42, true)

            if GetDestructableLife(d) > 0.405 and not LoadBoolean(h, base, 31) then
                call SaveBoolean(h, base, 31, true)
                call Debug("Maoki v10 " + MLB_RouteName(route) + ": platform " + I2S(i) + " remained alive after shutdown.")
            endif
        endif

        set i = i + 1
    endloop

    // Pass 2: restore blockers on every closed cell.
    set i = 1
    loop
        exitwhen i > count
        set blocker = LoadDestructableHandle(h, base + 5, i)

        if not disabled and not LoadBoolean(h, base + 3, i) then
            if GetDestructableLife(blocker) <= 0.405 then
                call DestructableRestoreLife(blocker, GetDestructableMaxLife(blocker), false)
                call SaveBoolean(h, base, 42, true)
            endif
        endif

        set i = i + 1
    endloop

    // Passes 3/4: reapply open platforms last. Same v9.1 behavior.
    if LoadBoolean(h, base, 42) then
        set i = 1
        loop
            exitwhen i > count

            if LoadBoolean(h, base + 3, i) then
                set d = LoadDestructableHandle(h, base + 1, i)

                if GetDestructableLife(d) > 0.405 then
                    call SetDestructableInvulnerable(d, false)
                    call KillDestructable(d)
                endif
            endif

            set i = i + 1
        endloop

        set i = 1
        loop
            exitwhen i > count

            if LoadBoolean(h, base + 3, i) then
                set d = LoadDestructableHandle(h, base + 1, i)
                call DestructableRestoreLife(d, GetDestructableMaxLife(d), false)
            endif

            set i = i + 1
        endloop

        call SaveBoolean(h, base, 42, false)
    endif

    set d = null
    set blocker = null
    set h = null
endfunction

function MLB_OnLivePlatform takes integer route, real x, real y returns boolean
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer count = LoadInteger(h, base, 40)
    local boolean vertical = MLB_IsVertical(route)
    local real fixed = LoadReal(h, base, 11)
    local real axis
    local integer i = 1

    if vertical then
        if RAbsBJ(x - fixed) > LoadReal(h, base, 25) then
            set h = null
            return false
        endif
        set axis = y
    else
        if RAbsBJ(y - fixed) > LoadReal(h, base, 25) then
            set h = null
            return false
        endif
        set axis = x
    endif

    loop
        exitwhen i > count

        if RAbsBJ(axis - LoadReal(h, base + 2, i)) <= LoadReal(h, base, 24) then
            if GetDestructableLife(LoadDestructableHandle(h, base + 1, i)) > 0.405 then
                set h = null
                return true
            endif
        endif

        set i = i + 1
    endloop

    set h = null
    return false
endfunction

function MLB_InBoardingBounds takes integer route, real x, real y, real oldAxis, real newAxis returns boolean
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local boolean vertical = MLB_IsVertical(route)
    local real margin = LoadReal(h, base, 27)
    local real halfL = LoadReal(h, base, 18) + margin
    local real halfW = RMinBJ(LoadReal(h, base, 19) + margin, LoadReal(h, base, 25))
    local real fixed = LoadReal(h, base, 11)
    local boolean result

    if vertical then
        set result = y >= RMinBJ(oldAxis, newAxis) - halfL and y <= RMaxBJ(oldAxis, newAxis) + halfL and RAbsBJ(x - fixed) <= halfW
    else
        set result = x >= RMinBJ(oldAxis, newAxis) - halfL and x <= RMaxBJ(oldAxis, newAxis) + halfL and RAbsBJ(y - fixed) <= halfW
    endif

    set h = null
    return result
endfunction


//===========================================================================
// BOAT MOVEMENT
//===========================================================================

function MLB_TickRoute takes integer route returns nothing
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local boolean vertical = MLB_IsVertical(route)
    local group g = LoadGroupHandle(h, 0, 0)
    local rect path = LoadRectHandle(h, base, 46)
    local real oldAxis = LoadReal(h, base, 10)
    local real newAxis = oldAxis
    local real fixed = LoadReal(h, base, 11)
    local real dt = LoadReal(h, base, 21)
    local real waiting = LoadReal(h, base, 16)
    local real direction = LoadReal(h, base, 15)
    local real lowStop = LoadReal(h, base, 13)
    local real highStop = LoadReal(h, base, 14)
    local real delta
    local real x
    local real y
    local real effectX
    local real effectY
    local integer i
    local unit u

    call SaveInteger(h, base, 30, 1)

    if waiting > 0.0 then
        call SaveReal(h, base, 16, waiting - dt)
    else
        set newAxis = oldAxis + direction * LoadReal(h, base, 20) * dt

        if newAxis >= highStop then
            set newAxis = highStop
            call SaveReal(h, base, 15, -1.0)
            call SaveReal(h, base, 16, LoadReal(h, base, 22))
        elseif newAxis <= lowStop then
            set newAxis = lowStop
            call SaveReal(h, base, 15, 1.0)
            call SaveReal(h, base, 16, LoadReal(h, base, 22))
        endif
    endif

    call MLB_OpenDeck(route, newAxis)
    call SaveInteger(h, base, 30, 2)

    set delta = newAxis - oldAxis
    set i = BlzGroupGetSize(g) - 1

    loop
        exitwhen i < 0
        set u = BlzGroupUnitAt(g, i)

        if u != null then
            set x = GetUnitX(u)
            set y = GetUnitY(u)

            if GetUnitTypeId(u) == 0 then
                call MLB_Forget(u)
            elseif MLB_CanRide(u) then
                if RectContainsCoords(path, x, y) and MLB_InBoardingBounds(route, x, y, oldAxis, newAxis) and MLB_OnLivePlatform(route, x, y) then
                    if delta != 0.0 then
                        // Preserve walking orders; move only on this route's axis.
                        if vertical then
                            call SetUnitY(u, y + delta)
                        else
                            call SetUnitX(u, x + delta)
                        endif
                    endif
                endif
            endif
        endif

        set i = i - 1
    endloop

    call SaveReal(h, base, 10, newAxis)

    if vertical then
        set effectX = fixed
        set effectY = newAxis
    else
        set effectX = newAxis
        set effectY = fixed
    endif

    call BlzSetSpecialEffectPosition(LoadEffectHandle(h, base, 1), effectX, effectY, LoadReal(h, base, 12))

    call SaveInteger(h, base, 30, 3)
    call MLB_CloseDeck(route)
    call SaveInteger(h, base, 30, 4)
    call SaveInteger(h, base, 29, LoadInteger(h, base, 29) + 1)

    set u = null
    set path = null
    set g = null
    set h = null
endfunction

function MLB_Tick takes nothing returns nothing
    local integer route = 8

    call MLB_CleanCandidates()

    loop
        exitwhen route > 11
        call MLB_TickRoute(route)
        set route = route + 1
    endloop
endfunction


//===========================================================================
// ROUTE SETUP
//===========================================================================

// Phase 1. Discover and validate geometry only.
// NO platform is killed here. This prevents one bad route from leaving a
// partially-mutated setup before all four regions have been validated.
function MLB_DiscoverRoute takes integer route returns boolean
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer expected = route
    local boolean vertical = MLB_IsVertical(route)
    local rect path = MLB_PathRect(route)
    local destructable d
    local real firstAxis
    local real fixed
    local real pitch
    local real axis
    local integer i = 1

    if path == null then
        call Debug("Maoki v10: missing route region for " + MLB_RouteName(route) + ".")
        set h = null
        return false
    endif

    call SaveInteger(h, base, 40, 0)
    call SaveInteger(h, base, 41, 0)
    call SaveInteger(h, 9000, 0, route)
    call EnumDestructablesInRect(path, null, function MLB_DiscoverDeckDestructable)

    if LoadInteger(h, base, 40) != expected or LoadInteger(h, base, 41) != 0 then
        call Debug("Maoki v10 " + MLB_RouteName(route) + ": expected " + I2S(expected) + " OTip platforms and 0 preplaced YTpc blockers. Found " + I2S(LoadInteger(h, base, 40)) + " platforms and " + I2S(LoadInteger(h, base, 41)) + " blockers.")
        set path = null
        set h = null
        return false
    endif

    call MLB_SortPlatforms(route)

    set d = LoadDestructableHandle(h, base + 1, 1)
    set firstAxis = MLB_AxisOf(d, vertical)
    set fixed = MLB_PerpendicularOf(d, vertical)
    set pitch = MLB_AxisOf(LoadDestructableHandle(h, base + 1, 2), vertical) - firstAxis

    if pitch <= 0.02 then
        call Debug("Maoki v10 " + MLB_RouteName(route) + ": invalid platform spacing.")
        set d = null
        set path = null
        set h = null
        return false
    endif

    // Deliberately NO GetDestructableLife startup guard.
    // The editor setup is authoritative: all OTip platforms start alive.
    set i = 1
    loop
        exitwhen i > expected
        set d = LoadDestructableHandle(h, base + 1, i)
        set axis = MLB_AxisOf(d, vertical)

        if RAbsBJ(MLB_PerpendicularOf(d, vertical) - fixed) > 1.0 or RAbsBJ(axis - firstAxis - I2R(i - 1) * pitch) > 1.0 then
            call Debug("Maoki v10 " + MLB_RouteName(route) + ": platform " + I2S(i) + " is not evenly aligned.")
            set d = null
            set path = null
            set h = null
            return false
        endif

        call SaveReal(h, base + 2, i, axis)
        call SaveReal(h, base + 4, i, -1.0)
        set i = i + 1
    endloop

    // Route configuration. Same defaults as the working v9.1 route.
    call SaveBoolean(h, base, 44, vertical)
    call SaveRectHandle(h, base, 46, path)

    call SaveReal(h, base, 11, fixed)
    call SaveReal(h, base, 17, pitch)

    // Deck = 2 platform spacings long x 1 spacing wide.
    call SaveReal(h, base, 18, pitch)
    call SaveReal(h, base, 19, pitch * 0.5)

    // Platform logical half-size = half one spacing.
    call SaveReal(h, base, 24, pitch * 0.5)
    call SaveReal(h, base, 25, pitch * 0.5)

    call SaveReal(h, base, 20, 48.0)      // speed
    call SaveReal(h, base, 21, 0.03125)   // period
    call SaveReal(h, base, 22, 2.0)       // dock wait
    call SaveReal(h, base, 26, RMaxBJ(0.01, RMinBJ(8.0, 0.25 * pitch)))
    call SaveReal(h, base, 27, 16.0)      // boarding tolerance

    // Starts centered on cells 1/2; far stop centered on final two cells.
    call SaveReal(h, base, 13, 0.5 * (LoadReal(h, base + 2, 1) + LoadReal(h, base + 2, 2)))
    call SaveReal(h, base, 14, 0.5 * (LoadReal(h, base + 2, expected - 1) + LoadReal(h, base + 2, expected)))

    set d = null
    set path = null
    set h = null
    return true
endfunction

// Phase 2. All four routes already passed validation.
// Now apply the v9.1 startup workaround and create the boat.
function MLB_ActivateRoute takes integer route returns boolean
    local hashtable h = udg_MaokiBoatData
    local integer base = MLB_Base(route)
    local integer count = LoadInteger(h, base, 40)
    local boolean vertical = MLB_IsVertical(route)
    local destructable d
    local destructable blocker
    local effect boat
    local location p
    local real boatAxis = LoadReal(h, base, 13)
    local real fixed = LoadReal(h, base, 11)
    local real x
    local real y
    local real z
    local real yaw = 0.0
    local integer i = 1

    // First kill ALL initially-alive platforms on this route.
    loop
        exitwhen i > count
        set d = LoadDestructableHandle(h, base + 1, i)
        call SetDestructableInvulnerable(d, false)
        call KillDestructable(d)
        set i = i + 1
    endloop

    // Then create one runtime blocker at each exact platform center.
    call SaveInteger(h, base, 41, 0)
    set i = 1
    loop
        exitwhen i > count
        set d = LoadDestructableHandle(h, base + 1, i)
        set blocker = CreateDestructable('YTpc', GetDestructableX(d), GetDestructableY(d), 0.0, 1.0, 0)

        if blocker == null then
            call Debug("Maoki v10 " + MLB_RouteName(route) + ": failed to create runtime blocker " + I2S(i) + ".")
            set d = null
            set blocker = null
            set h = null
            return false
        endif

        call SaveDestructableHandle(h, base + 5, i, blocker)
        call SaveInteger(h, base, 41, i)
        set i = i + 1
    endloop

    call SaveReal(h, base, 10, boatAxis)
    call SaveReal(h, base, 15, 1.0)
    call SaveReal(h, base, 16, LoadReal(h, base, 22))

    if vertical then
        set x = fixed
        set y = boatAxis
        set yaw = 90.0
    else
        set x = boatAxis
        set y = fixed
    endif

    set p = Location(x, y)
    set z = GetLocationZ(p)
    call RemoveLocation(p)

    call SaveReal(h, base, 12, z)

    set boat = AddSpecialEffect("Doodads\\Northrend\\Water\\Rowboat\\Rowboat.mdl", x, y)
    call BlzSetSpecialEffectScale(boat, 1.1)
    call BlzSetSpecialEffectYaw(boat, yaw * bj_DEGTORAD)
    call BlzSetSpecialEffectPosition(boat, x, y, z)
    call SaveEffectHandle(h, base, 1, boat)

    call SaveBoolean(h, base, 42, true)

    // Open the starting two-cell deck.
    call MLB_OpenDeck(route, boatAxis)
    call MLB_CloseDeck(route)

    set p = null
    set boat = null
    set d = null
    set blocker = null
    set h = null
    return true
endfunction


//===========================================================================
// DIAGNOSTICS
//===========================================================================

function MLB_Label takes string label, real x, real y, real height, integer red, integer green, integer blue returns nothing
    local texttag tag = CreateTextTag()

    call SetTextTagText(tag, label, 0.018)
    call SetTextTagPos(tag, x, y, height)
    call SetTextTagColor(tag, red, green, blue, 255)
    call SetTextTagPermanent(tag, false)
    call SetTextTagLifespan(tag, 90.0)
    call SetTextTagFadepoint(tag, 80.0)

    set tag = null
endfunction

function MLB_Debug takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local player who = GetTriggerPlayer()
    local integer route = 8
    local integer base
    local integer count
    local integer i
    local integer alivePlatforms
    local integer aliveBlockers
    local integer needed

    call DisplayTimedTextToPlayer(who, 0.0, 0.0, 30.0, "Maoki v10: candidates=" + I2S(BlzGroupGetSize(LoadGroupHandle(h, 0, 0))) + " paused=" + MLB_BoolText(LoadBoolean(h, 0, 51)))

    loop
        exitwhen route > 11
        set base = MLB_Base(route)
        set count = LoadInteger(h, base, 40)
        set alivePlatforms = 0
        set aliveBlockers = 0
        set needed = 0
        set i = 1

        loop
            exitwhen i > count

            if GetDestructableLife(LoadDestructableHandle(h, base + 1, i)) > 0.405 then
                set alivePlatforms = alivePlatforms + 1
            endif

            if GetDestructableLife(LoadDestructableHandle(h, base + 5, i)) > 0.405 then
                set aliveBlockers = aliveBlockers + 1
            endif

            if LoadBoolean(h, base + 3, i) then
                set needed = needed + 1
            endif

            set i = i + 1
        endloop

        call DisplayTimedTextToPlayer(who, 0.0, 0.0, 30.0, MLB_RouteName(route) + ": cells=" + I2S(count) + " pos=" + R2S(LoadReal(h, base, 10)) + " liveP=" + I2S(alivePlatforms) + " liveB=" + I2S(aliveBlockers) + " open=" + I2S(needed) + " ticks=" + I2S(LoadInteger(h, base, 29)))
        set route = route + 1
    endloop

    set who = null
    set h = null
endfunction

function MLB_MapDebug takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local player who = GetTriggerPlayer()
    local integer route = 8
    local integer base
    local integer count
    local integer i
    local destructable p
    local destructable b
    local string prefix

    call DisplayTimedTextToPlayer(who, 0.0, 0.0, 60.0, "Maoki v10 map: GREEN=platform, YELLOW=runtime blocker. Labels last 90 sec.")

    loop
        exitwhen route > 11
        set base = MLB_Base(route)
        set count = LoadInteger(h, base, 40)
        set prefix = MLB_RouteName(route)
        set i = 1

        loop
            exitwhen i > count
            set p = LoadDestructableHandle(h, base + 1, i)
            set b = LoadDestructableHandle(h, base + 5, i)

            call MLB_Label(prefix + " P" + I2S(i), GetDestructableX(p), GetDestructableY(p), 80.0, 80, 255, 80)
            call MLB_Label(prefix + " B" + I2S(i), GetDestructableX(b), GetDestructableY(b), 112.0, 255, 230, 40)

            set i = i + 1
        endloop

        set route = route + 1
    endloop

    set p = null
    set b = null
    set who = null
    set h = null
endfunction

function MLB_PauseTest takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local string cmd = GetEventPlayerChatString()

    if cmd == "-boatpause" then
        if not LoadBoolean(h, 0, 51) then
            call PauseTimer(LoadTimerHandle(h, 0, 2))
            call SaveBoolean(h, 0, 51, true)
            call Debug("Maoki v10: all four boats PAUSED.")
        endif
    elseif cmd == "-boatresume" and LoadBoolean(h, 0, 51) then
        call SaveBoolean(h, 0, 51, false)
        call TimerStart(LoadTimerHandle(h, 0, 2), 0.03125, true, function MLB_Tick)
        call Debug("Maoki v10: all four boats resumed.")
    endif

    set h = null
endfunction

function MLB_BlockerTest takes nothing returns nothing
    local hashtable h = udg_MaokiBoatData
    local boolean disabled = GetEventPlayerChatString() == "-boatblockers off"
    local integer route = 8
    local integer base
    local real boatAxis

    loop
        exitwhen route > 11
        set base = MLB_Base(route)
        call SaveBoolean(h, base, 43, disabled)
        call SaveBoolean(h, base, 42, true)
        set boatAxis = LoadReal(h, base, 10)
        call MLB_OpenDeck(route, boatAxis)
        call MLB_CloseDeck(route)
        set route = route + 1
    endloop

    call Debug("Maoki v10: blockers disabled=" + MLB_BoolText(disabled) + " for all four routes.")

    set h = null
endfunction


//===========================================================================
// STARTUP
//===========================================================================

function MLB_Start takes nothing returns nothing
    local hashtable h
    local group candidates
    local group initial
    local region area
    local rect tracking
    local trigger t
    local timer clock
    local unit u
    local integer route = 8
    local integer i = 0

    call DestroyTimer(GetExpiredTimer())

    if udg_MaokiBoatData != null then
        call Debug("Maoki v10: already initialized; startup skipped.")
        return
    endif

    set udg_MaokiBoatData = InitHashtable()
    set h = udg_MaokiBoatData

    // -------- PHASE 1: validate ALL four routes before mutating any. --------
    set route = 8
    loop
        exitwhen route > 11

        if not MLB_DiscoverRoute(route) then
            call Debug("Maoki v10: startup aborted before any route was intentionally closed.")
            set h = null
            return
        endif

        set route = route + 1
    endloop

    // Shared candidate groups must exist before route decks are activated.
    set candidates = CreateGroup()
    call SaveGroupHandle(h, 0, 0, candidates)
    call SaveGroupHandle(h, 0, 23, CreateGroup())

    // -------- PHASE 2: close routes, create blockers, create boats. --------
    set route = 8
    loop
        exitwhen route > 11

        if not MLB_ActivateRoute(route) then
            call Debug("Maoki v10: activation failed on " + MLB_RouteName(route) + ".")
            set candidates = null
            set h = null
            return
        endif

        set route = route + 1
    endloop

    // Shared tracking area. EXPAND Maoki Boats in the editor to cover all
    // four routes and their boarding approaches.
    set area = CreateRegion()
    set tracking = Rect(GetRectMinX(gg_rct_Maoki_Boats) - 64.0, GetRectMinY(gg_rct_Maoki_Boats) - 64.0, GetRectMaxX(gg_rct_Maoki_Boats) + 64.0, GetRectMaxY(gg_rct_Maoki_Boats) + 64.0)
    call SaveRectHandle(h, 0, 28, tracking)
    call RegionAddRect(area, tracking)
    call SaveRegionHandle(h, 0, 3, area)

    set t = CreateTrigger()
    call TriggerRegisterEnterRegion(t, area, null)
    call TriggerAddAction(t, function MLB_Enter)

    set t = CreateTrigger()
    call TriggerRegisterLeaveRegion(t, area, null)
    call TriggerAddAction(t, function MLB_Leave)

    // Seed units already inside the expanded harbor tracking area.
    set initial = CreateGroup()
    call GroupEnumUnitsInRect(initial, tracking, null)

    loop
        set u = FirstOfGroup(initial)
        exitwhen u == null
        call GroupRemoveUnit(initial, u)
        call MLB_AddCandidate(u)
    endloop

    call DestroyGroup(initial)

    // Diagnostics.
    set t = CreateTrigger()
    set i = 0
    loop
        exitwhen i >= bj_MAX_PLAYER_SLOTS
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boat", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function MLB_Debug)

    set t = CreateTrigger()
    set i = 0
    loop
        exitwhen i >= bj_MAX_PLAYER_SLOTS
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boatmap", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function MLB_MapDebug)

    set t = CreateTrigger()
    set i = 0
    loop
        exitwhen i >= bj_MAX_PLAYER_SLOTS
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boatpause", true)
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boatresume", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function MLB_PauseTest)

    set t = CreateTrigger()
    set i = 0
    loop
        exitwhen i >= bj_MAX_PLAYER_SLOTS
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boatblockers off", true)
        call TriggerRegisterPlayerChatEvent(t, Player(i), "-boatblockers on", true)
        set i = i + 1
    endloop
    call TriggerAddAction(t, function MLB_BlockerTest)

    // One shared timer updates all four independent routes.
    set clock = CreateTimer()
    call SaveTimerHandle(h, 0, 2, clock)
    call TimerStart(clock, 0.03125, true, function MLB_Tick)

    call Debug("Maoki boats v10 ready: WE8, NS9, WE10, WE11. Type -boat for status.")

    set u = null
    set candidates = null
    set initial = null
    set area = null
    set tracking = null
    set t = null
    set clock = null
    set h = null
endfunction


//===========================================================================
function InitTrig_Maoki_Long_Boat takes nothing returns nothing
    // Let initially-alive OTip platforms exist through ordinary map init
    // before applying the runtime pathing workaround.
    call TimerStart(CreateTimer(), 1.0, false, function MLB_Start)
endfunction
