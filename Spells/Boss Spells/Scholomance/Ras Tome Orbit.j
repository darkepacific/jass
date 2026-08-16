globals
    // =========================
    // TOME MODELS
    // =========================

    constant string RTO_TOME_MODEL_1 = "Objects\\InventoryItems\\tome\\tome.mdl"
    constant string RTO_TOME_MODEL_2 = "Objects\\InventoryItems\\tomeBlue\\tomeBlue.mdl"
    constant string RTO_TOME_MODEL_3 = "Objects\\InventoryItems\\tomeGreen\\tomeGreen.mdl"


    // =========================
    // CONFIG
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

    constant real RTO_TOME_SCALE = 1.00


    // =========================
    // INTERNAL STATE
    // =========================

    effect array RTO_TomeEffect

    real RTO_CenterX = 0.00
    real RTO_CenterY = 0.00

    real RTO_OrbitAngle = 0.00
    real RTO_Time = 0.00

    integer RTO_ActiveCount = 0
endglobals


function RTO_GetTerrainZ takes real x, real y returns real
    local location p = Location(x, y)
    local real z = GetLocationZ(p)

    call RemoveLocation(p)
    set p = null

    return z
endfunction


function RTO_GetRandomTomeModel takes nothing returns string
    local integer roll = GetRandomInt(1, 3)

    if roll == 1 then
        return RTO_TOME_MODEL_1
    elseif roll == 2 then
        return RTO_TOME_MODEL_2
    endif

    return RTO_TOME_MODEL_3
endfunction


function RTO_DestroyTomes takes nothing returns nothing
    local integer i = 1

    loop
        exitwhen i > RTO_ActiveCount

        if RTO_TomeEffect[i] != null then
            call DestroyEffect(RTO_TomeEffect[i])
            set RTO_TomeEffect[i] = null
        endif

        set i = i + 1
    endloop

    set RTO_ActiveCount = 0
endfunction


function RTO_CreateTomes takes nothing returns nothing
    local integer i = 1
    local integer count = RTO_TOME_COUNT
    local string model

    if count < 3 then
        set count = 3
    endif

    if count > 6 then
        set count = 6
    endif

    set RTO_ActiveCount = count

    loop
        exitwhen i > count

        // Each tome independently chooses one of the three models.
        set model = RTO_GetRandomTomeModel()

        set RTO_TomeEffect[i] = AddSpecialEffect(model, RTO_CenterX, RTO_CenterY)

        call BlzSetSpecialEffectScale(RTO_TomeEffect[i], RTO_TOME_SCALE)

        set i = i + 1
    endloop

    set model = null
endfunction


function Trig_Ras_Tome_Orbit_Actions takes nothing returns nothing
    local integer i = 1

    local real spacing
    local real angle
    local real phase

    local real x
    local real y
    local real z

    local real individualHeight
    local real bob

    if RTO_ActiveCount <= 0 then
        call DisableTrigger(gg_trg_Ras_Tome_Orbit)
        return
    endif

    set RTO_Time = RTO_Time + RTO_PERIOD
    set RTO_OrbitAngle = RTO_OrbitAngle + (RTO_ORBIT_SPEED * RTO_PERIOD)

    if RTO_OrbitAngle >= (bj_PI * 2.00) then
        set RTO_OrbitAngle = RTO_OrbitAngle - (bj_PI * 2.00)
    endif

    set spacing = (bj_PI * 2.00) / I2R(RTO_ActiveCount)

    loop
        exitwhen i > RTO_ActiveCount

        // Evenly spaced around the circle.
        set angle = RTO_OrbitAngle + (spacing * I2R(i - 1))

        // Offset bobbing phase for every tome.
        set phase = spacing * I2R(i - 1)

        set x = RTO_CenterX + (Cos(angle) * RTO_RADIUS)
        set y = RTO_CenterY + (Sin(angle) * RTO_RADIUS)

        // Slightly different resting height for each tome.
        set individualHeight = RTO_HEIGHT_VARIATION * Sin(I2R(i) * 2.17)

        // Gentle vertical bob.
        set bob = RTO_BOB_HEIGHT * Sin((RTO_Time * RTO_BOB_SPEED) + phase)

        set z = RTO_GetTerrainZ(x, y) + RTO_BASE_HEIGHT + individualHeight + bob

        call BlzSetSpecialEffectPosition(RTO_TomeEffect[i], x, y, z)

        // Face in the direction of travel.
        call BlzSetSpecialEffectYaw(RTO_TomeEffect[i], angle + (bj_PI * 0.50))

        set i = i + 1
    endloop
endfunction


function RTO_Start takes real x, real y returns nothing
    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call RTO_DestroyTomes()

    set RTO_CenterX = x
    set RTO_CenterY = y

    set RTO_OrbitAngle = 0.00
    set RTO_Time = 0.00

    call RTO_CreateTomes()

    // Position immediately instead of waiting for the first timer tick.
    call Trig_Ras_Tome_Orbit_Actions()

    call EnableTrigger(gg_trg_Ras_Tome_Orbit)
endfunction


function RTO_StartAtRect takes rect r returns nothing
    call RTO_Start(GetRectCenterX(r), GetRectCenterY(r))
endfunction


function RTO_Stop takes nothing returns nothing
    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call RTO_DestroyTomes()

    set RTO_OrbitAngle = 0.00
    set RTO_Time = 0.00
endfunction


//===========================================================================
function InitTrig_Ras_Tome_Orbit takes nothing returns nothing
    set gg_trg_Ras_Tome_Orbit = CreateTrigger()

    call DisableTrigger(gg_trg_Ras_Tome_Orbit)

    call TriggerRegisterTimerEventPeriodic(gg_trg_Ras_Tome_Orbit, RTO_PERIOD)
    call TriggerAddAction(gg_trg_Ras_Tome_Orbit, function Trig_Ras_Tome_Orbit_Actions)
endfunction