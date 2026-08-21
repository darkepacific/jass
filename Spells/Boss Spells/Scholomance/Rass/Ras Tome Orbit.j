globals
    // =========================
    // TOME MODELS
    // =========================

    // constant string RTO_TOME_MODEL_1 = "Objects\\InventoryItems\\tome\\tome.mdl"
    // constant string RTO_TOME_MODEL_2 = "Objects\\InventoryItems\\tomeBlue\\tomeBlue.mdl"
    // constant string RTO_TOME_MODEL_3 = "Objects\\InventoryItems\\tomeGreen\\tomeGreen.mdl"

    // constant string RTO_TOME_MODEL_3 = "war3mapImported\\Spell_Book_Item.mdx"
    // constant string RTO_TOME_MODEL_4 = "war3mapImported\\Book_GulDan_item.mdx"
    // constant string RTO_TOME_MODEL_3 = "Objects\\InventoryItems\\tomeBrown\\tomeBrown.mdl"
    
    constant string RTO_TOME_MODEL_1 = "war3mapImported\\DarkEnchantedBook.mdx"
    constant string RTO_TOME_MODEL_2 = "war3mapImported\\DarkEnchantedBook.mdx"
    constant string RTO_TOME_MODEL_3 = "war3mapImported\\DarkEnchantedBook.mdx"

    // =========================
    // MODES
    // =========================

    constant integer RTO_MODE_OFF    = 0
    constant integer RTO_MODE_WINDUP = 1
    constant integer RTO_MODE_ORBIT  = 2
    constant integer RTO_MODE_THROW  = 3


    // =========================
    // ORBIT CONFIG
    // =========================

    // Change anywhere from 3 to 6.
    constant integer RTO_TOME_COUNT = 5

    constant real RTO_RADIUS = 200.00
    constant real RTO_PERIOD = 0.03

    // Radians per second.
    constant real RTO_ORBIT_SPEED = 1.60

    constant real RTO_BASE_HEIGHT = 120.00
    constant real RTO_HEIGHT_VARIATION = 25.00

    constant real RTO_BOB_HEIGHT = 18.00
    constant real RTO_BOB_SPEED = 2.50

    constant real RTO_TOME_SCALE = 1.25


    // =========================
    // WIND-UP CONFIG
    // =========================

    // Time for books to rise from the ground into orbit.
    constant real RTO_WINDUP_TIME = 1.00

    // Slightly above actual terrain level so the models do not clip.
    constant real RTO_WINDUP_START_HEIGHT = 5.00


    // =========================
    // THROW CONFIG
    // =========================

    // Units traveled per second.
    // Since all books use the same velocity, closer books arrive first.
    constant real RTO_THROW_SPEED = 850.00

    // Additional arc while flying toward the target.
    constant real RTO_THROW_ARC_HEIGHT = 100.00

    // Prevents extremely close books from impacting instantly.
    constant real RTO_THROW_MIN_TIME = 0.10

    // Height above terrain where the book actually impacts.
    constant real RTO_THROW_TARGET_HEIGHT = 25.00


    // =========================
    // IMPACT CONFIG
    // =========================

    constant real RTO_IMPACT_RADIUS = 175.00

    // Damage PER BOOK.
    // 5 books = maximum 350 damage if the player eats every impact.
    constant real RTO_IMPACT_DAMAGE = 350.00

    constant string RTO_IMPACT_MODEL = "war3mapImported\\ArcaneExplosion.mdx" 
    // constant string RTO_IMPACT_MODEL2 = "war3mapImported\\ArcaneMissileComplete.mdx"
    constant string RTO_IMPACT_MODEL2 = "war3mapImported\\EnergyBurstNoSound.mdx"
    constant string RTO_IMPACT_MODEL3 = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
    // constant string RTO_IMPACT_MODEL3 = "Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl"
    // constant string RTO_IMPACT_MODEL3 = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"

    // =========================
    // INTERNAL STATE
    // =========================

    effect array RTO_TomeEffect

    real array RTO_TomeX
    real array RTO_TomeY
    real array RTO_TomeZ

    real RTO_CenterX = 0.00
    real RTO_CenterY = 0.00

    real RTO_OrbitAngle = 0.00
    real RTO_Time = 0.00

    integer RTO_ActiveCount = 0
    integer RTO_Mode = RTO_MODE_OFF


    // =========================
    // WIND-UP STATE
    // =========================

    real RTO_WindupElapsed = 0.00


    // =========================
    // THROW STATE
    // =========================

    unit RTO_DamageSource = null

    real RTO_TargetX = 0.00
    real RTO_TargetY = 0.00
    real RTO_TargetZ = 0.00

    real RTO_ThrowElapsed = 0.00

    real array RTO_ThrowStartX
    real array RTO_ThrowStartY
    real array RTO_ThrowStartZ

    real array RTO_ThrowDuration

    boolean array RTO_TomeImpacted

    integer RTO_ThrowRemaining = 0
endglobals


//===========================================================================
// TERRAIN HEIGHT
//===========================================================================

function RTO_GetTerrainZ takes real x, real y returns real
    local location p = Location(x, y)
    local real z = GetLocationZ(p)

    call RemoveLocation(p)
    set p = null

    return z
endfunction


//===========================================================================
// RANDOM TOME MODEL
//===========================================================================

function RTO_GetRandomTomeModel takes integer count returns string
    local integer roll = GetRandomInt(1, 3)

    if count == 1 or roll == 1 then
        return RTO_TOME_MODEL_1
    elseif count == 2 or roll == 2 then
        return RTO_TOME_MODEL_2
    endif

    // if count == 1 or roll == 1 then
    //     return RTO_TOME_MODEL_1
    // elseif count == 2 or roll == 2 then
    //     return RTO_TOME_MODEL_2
    // elseif count == 3 or roll == 3 then
    //     return RTO_TOME_MODEL_3
    // elseif count == 4 or roll == 4 then
    //     return RTO_TOME_MODEL_4
    // endif

    return RTO_TOME_MODEL_3
endfunction


//===========================================================================
// DESTROY TOMES
//===========================================================================

function RTO_DestroyTomes takes nothing returns nothing
    local integer i = 1

    loop
        exitwhen i > RTO_ActiveCount

        if RTO_TomeEffect[i] != null then
            call DestroyEffect(RTO_TomeEffect[i])
            set RTO_TomeEffect[i] = null
        endif

        set RTO_TomeImpacted[i] = false

        set i = i + 1
    endloop

    set RTO_ActiveCount = 0
endfunction


//===========================================================================
// CREATE TOMES
//
// Creates all books simultaneously around the circle at ground level.
// The WINDUP state will then raise them into the air.
//===========================================================================

function RTO_CreateTomes takes nothing returns nothing
    local integer i = 1
    local integer count = RTO_TOME_COUNT
    local string model

    local real spacing
    local real angle

    local real x
    local real y
    local real z

    if count < 3 then
        set count = 3
    endif

    if count > 6 then
        set count = 6
    endif

    set RTO_ActiveCount = count
    set spacing = (bj_PI * 2.00) / I2R(count)

    loop
        exitwhen i > count

        set model = RTO_GetRandomTomeModel(i)

        set angle = RTO_OrbitAngle + (spacing * I2R(i - 1))

        set x = RTO_CenterX + (Cos(angle) * RTO_RADIUS)
        set y = RTO_CenterY + (Sin(angle) * RTO_RADIUS)

        set z = RTO_GetTerrainZ(x, y) + RTO_WINDUP_START_HEIGHT

        set RTO_TomeEffect[i] = AddSpecialEffect(model, x, y)

        call BlzSetSpecialEffectScale(RTO_TomeEffect[i], RTO_TOME_SCALE)
        call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], x, y, z)
        call BlzSetSpecialEffectYaw(RTO_TomeEffect[i], angle + (bj_PI * 0.50))

        set RTO_TomeX[i] = x
        set RTO_TomeY[i] = y
        set RTO_TomeZ[i] = z

        set RTO_TomeImpacted[i] = false

        set i = i + 1
    endloop
endfunction


//===========================================================================
// WIND-UP UPDATE
//
// Books remain around the circle and smoothly rise from ground level
// into their normal orbit height.
//===========================================================================

function RTO_UpdateWindup takes nothing returns nothing
    local integer i = 1

    local real spacing
    local real angle
    local real phase

    local real t
    local real easedT

    local real x
    local real y
    local real z

    local real terrainZ
    local real individualHeight
    local real bob
    local real targetHeight

    set RTO_WindupElapsed = RTO_WindupElapsed + RTO_PERIOD
    set RTO_Time = RTO_Time + RTO_PERIOD

    set t = RTO_WindupElapsed / RTO_WINDUP_TIME

    if t > 1.00 then
        set t = 1.00
    endif

    // Smooth acceleration/deceleration.
    set easedT = 0.50 - (0.50 * Cos(t * bj_PI))

    set spacing = (bj_PI * 2.00) / I2R(RTO_ActiveCount)

    loop
        exitwhen i > RTO_ActiveCount

        set angle = RTO_OrbitAngle + (spacing * I2R(i - 1))
        set phase = spacing * I2R(i - 1)

        set x = RTO_CenterX + (Cos(angle) * RTO_RADIUS)
        set y = RTO_CenterY + (Sin(angle) * RTO_RADIUS)

        set terrainZ = RTO_GetTerrainZ(x, y)

        set individualHeight = RTO_HEIGHT_VARIATION * Sin(I2R(i) * 2.17)
        set bob = RTO_BOB_HEIGHT * Sin((RTO_Time * RTO_BOB_SPEED) + phase)

        set targetHeight = RTO_BASE_HEIGHT + individualHeight + bob

        set z = terrainZ + RTO_WINDUP_START_HEIGHT + ((targetHeight - RTO_WINDUP_START_HEIGHT) * easedT)

        call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], x, y, z)
        call BlzSetSpecialEffectYaw(RTO_TomeEffect[i], angle + (bj_PI * 0.50))

        set RTO_TomeX[i] = x
        set RTO_TomeY[i] = y
        set RTO_TomeZ[i] = z

        set i = i + 1
    endloop

    if t >= 1.00 then
        set RTO_Mode = RTO_MODE_ORBIT
    endif
endfunction


//===========================================================================
// ORBIT UPDATE
//===========================================================================

function RTO_UpdateOrbit takes nothing returns nothing
    local integer i = 1

    local real spacing
    local real angle
    local real phase

    local real x
    local real y
    local real z

    local real individualHeight
    local real bob

    set RTO_Time = RTO_Time + RTO_PERIOD

    set RTO_OrbitAngle = RTO_OrbitAngle + (RTO_ORBIT_SPEED * RTO_PERIOD)

    if RTO_OrbitAngle >= (bj_PI * 2.00) then
        set RTO_OrbitAngle = RTO_OrbitAngle - (bj_PI * 2.00)
    endif

    set spacing = (bj_PI * 2.00) / I2R(RTO_ActiveCount)

    loop
        exitwhen i > RTO_ActiveCount

        set angle = RTO_OrbitAngle + (spacing * I2R(i - 1))

        set phase = spacing * I2R(i - 1)

        set x = RTO_CenterX + (Cos(angle) * RTO_RADIUS)
        set y = RTO_CenterY + (Sin(angle) * RTO_RADIUS)

        set individualHeight = RTO_HEIGHT_VARIATION * Sin(I2R(i) * 2.17)

        set bob = RTO_BOB_HEIGHT * Sin((RTO_Time * RTO_BOB_SPEED) + phase)

        set z = RTO_GetTerrainZ(x, y) + RTO_BASE_HEIGHT + individualHeight + bob

        call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], x, y, z)

        call BlzSetSpecialEffectYaw(RTO_TomeEffect[i], angle + (bj_PI * 0.50))

        // Save current position so the throw can begin from exactly
        // wherever each book currently is.
        set RTO_TomeX[i] = x
        set RTO_TomeY[i] = y
        set RTO_TomeZ[i] = z

        set i = i + 1
    endloop
endfunction


//===========================================================================
// TOME IMPACT DAMAGE
//
// Called independently by EVERY tome when it reaches the target.
//===========================================================================

function RTO_DoImpactDamage takes real x, real y returns nothing
    local group g = CreateGroup()
    local unit u
    local integer roll = GetRandomInt(1, 3)

    // Visual impact for this individual book.
    call DestroyEffect(AddSpecialEffect(RTO_IMPACT_MODEL, x, y))
    call DestroyEffect(AddSpecialEffect(RTO_IMPACT_MODEL2, x, y))
    call DestroyEffect(AddSpecialEffect(RTO_IMPACT_MODEL3, x, y))

    if roll == 1 then
        call PlaySoundAtXY("war3mapImported\\046_item_deathfiresgrasp_oh_01.mp3", x, y, null)
    elseif roll == 2 then
        call PlaySoundAtXY("war3mapImported\\047_item_deathfiresgrasp_oh_02.mp3", x, y, null)
    else
        call PlaySoundAtXY("war3mapImported\\048_item_deathfiresgrasp_oh_03.mp3", x, y, null)
    endif

    if RTO_DamageSource == null then
        call DestroyGroup(g)
        set g = null
        return
    endif

    call GroupEnumUnitsInRange(g, x, y, RTO_IMPACT_RADIUS, null)

    loop
        set u = FirstOfGroup(g)
        exitwhen u == null

        call GroupRemoveUnit(g, u)

        if GetWidgetLife(u) > 0.405 and IsUnitEnemy(u, GetOwningPlayer(RTO_DamageSource)) then
            // call UnitDamageTargetBJ(RTO_DamageSource, u, RTO_IMPACT_DAMAGE, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL)
            call UnitDamageTargetBJ(RTO_DamageSource, u, RTO_IMPACT_DAMAGE, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC)
        endif
    endloop

    call DestroyGroup(g)

    set u = null
    set g = null
endfunction


//===========================================================================
// THROW UPDATE
//
// All books use the same velocity.
//
// Therefore:
// nearest book  -> impacts first
// next nearest  -> impacts next
// farthest      -> impacts last
//
// Each arrival causes its own AoE damage pulse.
//===========================================================================

function RTO_UpdateThrow takes nothing returns nothing
    local integer i = 1

    local real t

    local real x
    local real y
    local real z

    set RTO_ThrowElapsed = RTO_ThrowElapsed + RTO_PERIOD

    loop
        exitwhen i > RTO_ActiveCount

        if RTO_TomeEffect[i] != null and not RTO_TomeImpacted[i] then

            set t = RTO_ThrowElapsed / RTO_ThrowDuration[i]

            if t >= 1.00 then

                // Force final position.
                call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], RTO_TargetX, RTO_TargetY, RTO_TargetZ)

                // Remove this book.
                call DestroyEffect(RTO_TomeEffect[i])
                set RTO_TomeEffect[i] = null

                set RTO_TomeImpacted[i] = true
                set RTO_ThrowRemaining = RTO_ThrowRemaining - 1

                // EACH tome gets its own impact + damage.
                call RTO_DoImpactDamage(RTO_TargetX, RTO_TargetY)

            else

                set x = RTO_ThrowStartX[i] + ((RTO_TargetX - RTO_ThrowStartX[i]) * t)
                set y = RTO_ThrowStartY[i] + ((RTO_TargetY - RTO_ThrowStartY[i]) * t)

                // Fly from current height toward ground target, with an arc.
                set z = RTO_ThrowStartZ[i] + ((RTO_TargetZ - RTO_ThrowStartZ[i]) * t) + (RTO_THROW_ARC_HEIGHT * Sin(t * bj_PI))

                call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], x, y, z)

                set RTO_TomeX[i] = x
                set RTO_TomeY[i] = y
                set RTO_TomeZ[i] = z
            endif
        endif

        set i = i + 1
    endloop

    // All books have impacted.
    if RTO_ThrowRemaining <= 0 then
        set RTO_Mode = RTO_MODE_OFF
        set RTO_ActiveCount = 0

        call DisableTrigger(gg_trg_Ras_Tome_Orbit)

        set RTO_DamageSource = null
    endif
endfunction


//===========================================================================
// MAIN PERIODIC TRIGGER
//===========================================================================

function Trig_Ras_Tome_Orbit_Actions takes nothing returns nothing

    if RTO_ActiveCount <= 0 then
        set RTO_Mode = RTO_MODE_OFF
        call DisableTrigger(gg_trg_Ras_Tome_Orbit)
        return
    endif

    if RTO_Mode == RTO_MODE_WINDUP then
        call RTO_UpdateWindup()

    elseif RTO_Mode == RTO_MODE_ORBIT then
        call RTO_UpdateOrbit()

    elseif RTO_Mode == RTO_MODE_THROW then
        call RTO_UpdateThrow()

    else
        call DisableTrigger(gg_trg_Ras_Tome_Orbit)
    endif
endfunction


//===========================================================================
// START ORBIT SEQUENCE
//
// Creates books on ground and begins the 1-second wind-up.
//===========================================================================

function RTO_Start takes real x, real y returns nothing

    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call RTO_DestroyTomes()

    set RTO_CenterX = x
    set RTO_CenterY = y

    set RTO_OrbitAngle = 0.00
    set RTO_Time = 0.00
    set RTO_WindupElapsed = 0.00

    set RTO_ThrowElapsed = 0.00
    set RTO_ThrowRemaining = 0

    set RTO_DamageSource = null

    set RTO_Mode = RTO_MODE_WINDUP

    call RTO_CreateTomes()

    call EnableTrigger(gg_trg_Ras_Tome_Orbit)
endfunction


function RTO_StartAtRect takes rect r returns nothing
    call RTO_Start(GetRectCenterX(r), GetRectCenterY(r))
endfunction


//===========================================================================
// THROW BOOKS AT TARGET POINT
//
// Pass Ras as "source" so damage is properly attributed to him.
//===========================================================================

function RTO_ThrowAtPoint takes unit source, real targetX, real targetY returns nothing
    local integer i = 1

    local real dx
    local real dy
    local real distance
    local real duration

    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl", GetUnitX(source), GetUnitY(source)))

    if RTO_ActiveCount <= 0 then
        return
    endif

    set RTO_DamageSource = source

    set RTO_TargetX = targetX
    set RTO_TargetY = targetY
    set RTO_TargetZ = RTO_GetTerrainZ(RTO_TargetX, RTO_TargetY) + RTO_THROW_TARGET_HEIGHT

    set RTO_ThrowElapsed = 0.00
    set RTO_ThrowRemaining = 0

    loop
        exitwhen i > RTO_ActiveCount

        if RTO_TomeEffect[i] != null then

            // Freeze its exact current position.
            set RTO_ThrowStartX[i] = RTO_TomeX[i]
            set RTO_ThrowStartY[i] = RTO_TomeY[i]
            set RTO_ThrowStartZ[i] = RTO_TomeZ[i]

            set dx = targetX - RTO_ThrowStartX[i]
            set dy = targetY - RTO_ThrowStartY[i]

            set distance = SquareRoot((dx * dx) + (dy * dy))

            // Constant velocity = different arrival times.
            set duration = distance / RTO_THROW_SPEED

            if duration < RTO_THROW_MIN_TIME then
                set duration = RTO_THROW_MIN_TIME
            endif

            set RTO_ThrowDuration[i] = duration
            set RTO_TomeImpacted[i] = false

            // Point the book toward its target.
            call BlzSetSpecialEffectYaw(RTO_TomeEffect[i], Atan2(dy, dx))

            set RTO_ThrowRemaining = RTO_ThrowRemaining + 1
        endif

        set i = i + 1
    endloop

    set RTO_Mode = RTO_MODE_THROW

    call EnableTrigger(gg_trg_Ras_Tome_Orbit)
endfunction


function RTO_ThrowAtRect takes unit source, rect r returns nothing
    call RTO_ThrowAtPoint(source, GetRectCenterX(r), GetRectCenterY(r))
endfunction

function RTO_ThrowAtUnit takes unit source, unit target returns nothing
    call RTO_ThrowAtPoint(source, GetUnitX( target), GetUnitY( target))
endfunction


//===========================================================================
// FORCE STOP / CLEANUP
//===========================================================================

function RTO_Stop takes nothing returns nothing

    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call RTO_DestroyTomes()

    set RTO_Mode = RTO_MODE_OFF

    set RTO_OrbitAngle = 0.00
    set RTO_Time = 0.00
    set RTO_WindupElapsed = 0.00

    set RTO_ThrowElapsed = 0.00
    set RTO_ThrowRemaining = 0

    set RTO_DamageSource = null
endfunction

// At 55% or less HP Ras will teleport to the center of the room and cast frost nova, rooting all enemies in place


//===========================================================================
function InitTrig_Ras_Tome_Orbit takes nothing returns nothing
    set gg_trg_Ras_Tome_Orbit = CreateTrigger()

    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call TriggerRegisterTimerEventPeriodic(gg_trg_Ras_Tome_Orbit, RTO_PERIOD)
    call TriggerAddAction(gg_trg_Ras_Tome_Orbit, function Trig_Ras_Tome_Orbit_Actions)
endfunction