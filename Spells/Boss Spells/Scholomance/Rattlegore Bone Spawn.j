globals
    constant string RBS_BONE_MODEL = "war3mapImported\\skelemerMissile.mdx"

    constant string RBS_IMPACT_MODEL_1 = "Abilities\\Spells\\Orc\\Stampede\\StampedeMissileDeath.mdl"
    constant string RBS_IMPACT_MODEL_2 = "Abilities\\Spells\\Other\\Stampede\\MissileDeath.mdl"

    // 0.01 sec * 400 ticks = 4.00 seconds
    constant real RBS_PERIOD = 0.01
    constant integer RBS_TOTAL_TICKS = 400

    // 0.01 sec * 50 ticks = 0.50 seconds
    constant integer RBS_TRAVEL_TICKS = 80
    constant integer RBS_SPAWN_EVERY_TICKS = 40

    constant real RBS_START_HEIGHT = 40.00
    constant real RBS_ARC_HEIGHT = 450.00

    constant real RBS_IMPACT_HEIGHT = 25.00
    constant real RBS_IMPACT_SCALE = 6.35

    integer RBS_Tick = 0
    integer RBS_Count = 0

    effect array RBS_BoneEffect

    real array RBS_StartX
    real array RBS_StartY
    real array RBS_StartZ

    real array RBS_EndX
    real array RBS_EndY
    real array RBS_EndZ

    integer array RBS_StartTick
endglobals

function RBS_GetTerrainZ takes real x, real y returns real
    local location p = Location(x, y)
    local real z = GetLocationZ(p)

    call RemoveLocation(p)
    set p = null

    return z
endfunction

function RBS_CleanupAll takes nothing returns nothing
    local integer i = 1

    loop
        exitwhen i > RBS_Count

        if RBS_BoneEffect[i] != null then
            call DestroyEffect(RBS_BoneEffect[i])
            set RBS_BoneEffect[i] = null
        endif

        set i = i + 1
    endloop

    set RBS_Count = 0
endfunction

function RBS_CreateImpactAtCenter takes nothing returns nothing
    local real x = GetRectCenterX(gg_rct_Harsh_Lesson_TP_Center)
    local real y = GetRectCenterY(gg_rct_Harsh_Lesson_TP_Center)
    local real z = RBS_GetTerrainZ(x, y) + RBS_IMPACT_HEIGHT
    local real yaw = GetRandomReal(0.00, bj_PI * 2.00)

    local effect e1 = AddSpecialEffect(RBS_IMPACT_MODEL_1, x, y)
    local effect e2 = AddSpecialEffect(RBS_IMPACT_MODEL_2, x, y)

    call BlzSetSpecialEffectPosition(e1, x, y, z)
    call BlzSetSpecialEffectScale(e1, RBS_IMPACT_SCALE)
    call BlzSetSpecialEffectYaw(e1, yaw)

    call BlzSetSpecialEffectPosition(e2, x, y, z)
    call BlzSetSpecialEffectScale(e2, RBS_IMPACT_SCALE)
    call BlzSetSpecialEffectYaw(e2, yaw)

    call DestroyEffect(e1)
    call DestroyEffect(e2)

    set e1 = null
    set e2 = null
endfunction

function RBS_SpawnBoneFromRect takes rect r returns nothing
    local integer i = RBS_Count + 1

    local real sx = GetRectCenterX(r)
    local real sy = GetRectCenterY(r)
    local real sz = RBS_GetTerrainZ(sx, sy) + RBS_START_HEIGHT

    local real ex = GetRectCenterX(gg_rct_Harsh_Lesson_TP_Center)
    local real ey = GetRectCenterY(gg_rct_Harsh_Lesson_TP_Center)
    local real ez = RBS_GetTerrainZ(ex, ey) + RBS_START_HEIGHT

    set RBS_Count = i

    set RBS_BoneEffect[i] = AddSpecialEffect(RBS_BONE_MODEL, sx, sy)

    set RBS_StartX[i] = sx
    set RBS_StartY[i] = sy
    set RBS_StartZ[i] = sz

    set RBS_EndX[i] = ex
    set RBS_EndY[i] = ey
    set RBS_EndZ[i] = ez

    set RBS_StartTick[i] = RBS_Tick

    call BlzSetSpecialEffectPosition(RBS_BoneEffect[i], sx, sy, sz)
    call BlzSetSpecialEffectYaw(RBS_BoneEffect[i], Atan2(ey - sy, ex - sx))
endfunction

function RBS_SpawnWave takes nothing returns nothing
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons1)
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons2)
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons3)
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons4)
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons5)
    call RBS_SpawnBoneFromRect(gg_rct_HMSkeletons6)
endfunction

function RBS_UpdateBones takes nothing returns nothing
    local integer i = 1
    local integer age
    local real t
    local real x
    local real y
    local real z

    loop
        exitwhen i > RBS_Count

        if RBS_BoneEffect[i] != null then
            set age = RBS_Tick - RBS_StartTick[i]

            if age >= RBS_TRAVEL_TICKS then
                call BlzSetSpecialEffectPosition(RBS_BoneEffect[i], RBS_EndX[i], RBS_EndY[i], RBS_EndZ[i])
                call DestroyEffect(RBS_BoneEffect[i])
                set RBS_BoneEffect[i] = null
            else
                set t = I2R(age) / I2R(RBS_TRAVEL_TICKS)

                set x = RBS_StartX[i] + ((RBS_EndX[i] - RBS_StartX[i]) * t)
                set y = RBS_StartY[i] + ((RBS_EndY[i] - RBS_StartY[i]) * t)

                // Half sine arc: starts low, rises, then lands at center.
                set z = RBS_StartZ[i] + ((RBS_EndZ[i] - RBS_StartZ[i]) * t) + (RBS_ARC_HEIGHT * Sin(t * bj_PI))

                call BlzSetSpecialEffectPosition(RBS_BoneEffect[i], x, y, z)
            endif
        endif

        set i = i + 1
    endloop
endfunction

function Trig_Rattlegore_Bone_Spawn_Actions takes nothing returns nothing
    if RBS_Tick > RBS_TOTAL_TICKS then
        call RBS_CleanupAll()
        call DisableTrigger(gg_trg_Rattlegore_Bone_Spawn)
        return
    endif

    // Update existing bones first so landing bones disappear before impact.
    call RBS_UpdateBones()

    // One center explosion every 50 ticks after the first wave lands.
    // This happens at 50, 100, 150, 200, 250, 300, 350, and 400.
    if RBS_Tick > 0 and ModuloInteger(RBS_Tick, RBS_SPAWN_EVERY_TICKS) == 0 then
        call RBS_CreateImpactAtCenter()
    endif

    // Spawn 6 bones every 50 ticks, but do not spawn a new wave at tick 400.
    if RBS_Tick < RBS_TOTAL_TICKS and ModuloInteger(RBS_Tick, RBS_SPAWN_EVERY_TICKS) == 0 then
        call RBS_SpawnWave()
    endif

    set RBS_Tick = RBS_Tick + 1
endfunction

function Trig_Rattlegore_Bone_Spawn_Start takes nothing returns nothing
    call RBS_CleanupAll()

    set RBS_Tick = 0
    set RBS_Count = 0

    call EnableTrigger(gg_trg_Rattlegore_Bone_Spawn)
endfunction

//===========================================================================
function InitTrig_Rattlegore_Bone_Spawn takes nothing returns nothing
    set gg_trg_Rattlegore_Bone_Spawn = CreateTrigger()
    call DisableTrigger(gg_trg_Rattlegore_Bone_Spawn)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Rattlegore_Bone_Spawn, RBS_PERIOD)
    call TriggerAddAction(gg_trg_Rattlegore_Bone_Spawn, function Trig_Rattlegore_Bone_Spawn_Actions)
endfunction