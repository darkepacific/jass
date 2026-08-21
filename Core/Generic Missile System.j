//===========================================================================
// GENERIC MISSILE SYSTEM
//
// Features:
//   - Moves an effect from point A to point B
//   - Faces the missile toward its destination
//   - Optional terrain-following height
//   - Damages enemy units it touches
//   - Each missile can only damage a given unit once
//   - Can either:
//         destroyOnHit = true  = destroy on first unit hit
//         destroyOnHit = false = pierce through units
//   - Optional impact effect on each unit struck
//   - Per-missile target filters via IsUnitTargetableEnemyParams
//
// followTerrain:
//   true  = stay "height" units above the terrain currently beneath the missile
//   false = keep the absolute world-space Z recorded at launch
//
// Target flags (true = that type IS permitted):
//   hitAir          = flying units allowed
//   hitGround       = ground units allowed
//   hitMagicImmune  = magic-immune units allowed
//   hitMechanical   = mechanical units allowed
//
// No terrain/destructible collision is performed.
//===========================================================================

globals
    constant real MS_PERIOD = 0.03125
    location MS_TerrainLoc = null
    hashtable MS_Hash = null
endglobals

//===========================================================================
// TERRAIN HEIGHT
//===========================================================================
function MS_GetTerrainZ takes real x, real y returns real
    if MS_TerrainLoc == null then
        set MS_TerrainLoc = Location(0.00, 0.00)
    endif
    call MoveLocation(MS_TerrainLoc, x, y)
    return GetLocationZ(MS_TerrainLoc)
endfunction

//===========================================================================
// IMPACT EFFECT
//===========================================================================
function MS_CreateImpact takes string model, real x, real y, real z returns nothing
    local effect fx

    if model == "" then
        return
    endif

    set fx = AddSpecialEffect(model, x, y)
    call BlzSetSpecialEffectZ(fx, z)
    call DestroyEffect(fx)
    set fx = null
endfunction

//===========================================================================
// DESTROY MISSILE
//===========================================================================
function MS_Destroy takes timer t returns nothing
    local integer id = GetHandleId(t)
    local effect missileFx = LoadEffectHandle(MS_Hash, id, 1)
    local group hitGroup = LoadGroupHandle(MS_Hash, id, 2)
    local group scanGroup = LoadGroupHandle(MS_Hash, id, 3)

    if missileFx != null then
        call DestroyEffect(missileFx)
    endif
    if hitGroup != null then
        call DestroyGroup(hitGroup)
    endif
    if scanGroup != null then
        call DestroyGroup(scanGroup)
    endif

    call FlushChildHashtable(MS_Hash, id)
    call PauseTimer(t)
    call DestroyTimer(t)

    set missileFx = null
    set hitGroup = null
    set scanGroup = null
    set t = null
endfunction

//===========================================================================
// MISSILE UPDATE
//===========================================================================
function MS_Update takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer id = GetHandleId(t)
    local unit source = LoadUnitHandle(MS_Hash, id, 0)
    local effect missileFx = LoadEffectHandle(MS_Hash, id, 1)
    local group hitGroup = LoadGroupHandle(MS_Hash, id, 2)
    local group scanGroup = LoadGroupHandle(MS_Hash, id, 3)
    local real x = LoadReal(MS_Hash, id, 10)
    local real y = LoadReal(MS_Hash, id, 11)
    local real angle = LoadReal(MS_Hash, id, 12)
    local real remaining = LoadReal(MS_Hash, id, 13)
    local real damage = LoadReal(MS_Hash, id, 14)
    local real speed = LoadReal(MS_Hash, id, 15)
    local real hitRadius = LoadReal(MS_Hash, id, 16)
    local real height = LoadReal(MS_Hash, id, 17)
    local boolean destroyOnHit = LoadBoolean(MS_Hash, id, 20)
    local boolean followTerrain = LoadBoolean(MS_Hash, id, 21)
    local boolean hitAir = LoadBoolean(MS_Hash, id, 22)
    local boolean hitGround = LoadBoolean(MS_Hash, id, 23)
    local boolean hitMagicImmune = LoadBoolean(MS_Hash, id, 24)
    local boolean hitMechanical = LoadBoolean(MS_Hash, id, 25)
    local string impactModel = LoadStr(MS_Hash, id, 30)
    local real launchZ = LoadReal(MS_Hash, id, 18)
    local real step = speed * MS_PERIOD
    local real z
    local unit u

    if step > remaining then
        set step = remaining
    endif

    set x = x + Cos(angle) * step
    set y = y + Sin(angle) * step
    set remaining = remaining - step
    if followTerrain then
        set z = MS_GetTerrainZ(x, y) + height
    else
        set z = launchZ
    endif

    call BlzSetSpecialEffectX(missileFx, x)
    call BlzSetSpecialEffectY(missileFx, y)
    call BlzSetSpecialEffectZ(missileFx, z)

    call GroupClear(scanGroup)
    call GroupEnumUnitsInRange(scanGroup, x, y, hitRadius, null)

    loop
        set u = FirstOfGroup(scanGroup)
        exitwhen u == null
        call GroupRemoveUnit(scanGroup, u)

        if IsUnitTargetableEnemyParams(u, source, hitAir, hitGround, hitMagicImmune, hitMechanical) then
            if not IsUnitInGroup(u, hitGroup) then
                call GroupAddUnit(hitGroup, u)
                if damage > 0.00 then
                    call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
                endif
                call MS_CreateImpact(impactModel, x, y, z)
                if destroyOnHit then
                    call MS_Destroy(t)
                    set source = null
                    set missileFx = null
                    set hitGroup = null
                    set scanGroup = null
                    set u = null
                    set t = null
                    return
                endif
            endif
        endif
    endloop

    call SaveReal(MS_Hash, id, 10, x)
    call SaveReal(MS_Hash, id, 11, y)
    call SaveReal(MS_Hash, id, 13, remaining)

    if remaining <= 0.00 then
        call MS_Destroy(t)
    endif

    set source = null
    set missileFx = null
    set hitGroup = null
    set scanGroup = null
    set u = null
    set t = null
endfunction

//===========================================================================
// GENERIC MISSILE LAUNCH
// source: unit credited with the damage
// missileModel: projectile model
// impactModel: effect created on hit. Pass "" for none.
// sx / sy: start    tx / ty: destination
// damage / speed / hitRadius / height
// PERFORMANCE NOTE: Keep hitRadius small for piercing missiles. Unit enumeration runs every MS_PERIOD while the missile is active, 
//                   so large collision radii can become expensive when many piercing missiles are active at once. 
//                   As a general rule, ~160 or less is a good normal collision radius. 
//                   Large-radius missiles are best used with destroyOnHit = true, since the expensive enumeration usually only matters until the first hit.
// destroyOnHit: true = ends on first unit struck, false = pierces
// followTerrain: true = ride terrain, false = keep launch Z
// hitAir / hitGround / hitMagicImmune / hitMechanical:
//   true = that target type IS permitted
//===========================================================================
function Missile_Launch takes unit source, string missileModel, string impactModel, real sx, real sy, real tx, real ty, real damage, real speed, real hitRadius, real height, boolean destroyOnHit, boolean followTerrain, boolean hitAir, boolean hitGround, boolean hitMagicImmune, boolean hitMechanical returns nothing
    local timer t
    local integer id
    local real dx = tx - sx
    local real dy = ty - sy
    local real distance = SquareRoot(dx * dx + dy * dy)
    local real angle
    local real launchZ
    local effect missileFx
    local group hitGroup
    local group scanGroup

    if distance <= 1.00 then
        return
    endif
    if missileModel == "" then
        return
    endif

    if MS_Hash == null then
        set MS_Hash = InitHashtable()
    endif

    set angle = Atan2(dy, dx)
    set launchZ = MS_GetTerrainZ(sx, sy) + height
    set missileFx = AddSpecialEffect(missileModel, sx, sy)
    call BlzSetSpecialEffectYaw(missileFx, angle)
    call BlzSetSpecialEffectZ(missileFx, launchZ)

    set t = CreateTimer()
    set id = GetHandleId(t)
    set hitGroup = CreateGroup()
    set scanGroup = CreateGroup()

    call SaveUnitHandle(MS_Hash, id, 0, source)
    call SaveEffectHandle(MS_Hash, id, 1, missileFx)
    call SaveGroupHandle(MS_Hash, id, 2, hitGroup)
    call SaveGroupHandle(MS_Hash, id, 3, scanGroup)
    call SaveReal(MS_Hash, id, 10, sx)
    call SaveReal(MS_Hash, id, 11, sy)
    call SaveReal(MS_Hash, id, 12, angle)
    call SaveReal(MS_Hash, id, 13, distance)
    call SaveReal(MS_Hash, id, 14, damage)
    call SaveReal(MS_Hash, id, 15, speed)
    call SaveReal(MS_Hash, id, 16, hitRadius)
    call SaveReal(MS_Hash, id, 17, height)
    call SaveReal(MS_Hash, id, 18, launchZ)
    call SaveBoolean(MS_Hash, id, 20, destroyOnHit)
    call SaveBoolean(MS_Hash, id, 21, followTerrain)
    call SaveBoolean(MS_Hash, id, 22, hitAir)
    call SaveBoolean(MS_Hash, id, 23, hitGround)
    call SaveBoolean(MS_Hash, id, 24, hitMagicImmune)
    call SaveBoolean(MS_Hash, id, 25, hitMechanical)
    call SaveStr(MS_Hash, id, 30, impactModel)

    call TimerStart(t, MS_PERIOD, true, function MS_Update)

    set missileFx = null
    set hitGroup = null
    set scanGroup = null
    set t = null
endfunction

//===========================================================================
// RECT WRAPPER - Uses the CENTER of each rect.
//===========================================================================
function Missile_LaunchFromRects takes unit source, string missileModel, string impactModel, rect startRect, rect targetRect, real damage, real speed, real hitRadius, real height, boolean destroyOnHit, boolean followTerrain, boolean hitAir, boolean hitGround, boolean hitMagicImmune, boolean hitMechanical returns nothing
    call Missile_Launch(source, missileModel, impactModel, GetRectCenterX(startRect), GetRectCenterY(startRect), GetRectCenterX(targetRect), GetRectCenterY(targetRect), damage, speed, hitRadius, height, destroyOnHit, followTerrain, hitAir, hitGround, hitMagicImmune, hitMechanical)
endfunction