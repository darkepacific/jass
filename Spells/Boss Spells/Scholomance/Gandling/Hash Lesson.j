function Trig_Harsh_Lesson_Conditions takes nothing returns boolean
    return GetWidgetLife(gg_unit_U01S_1754) <= 3200.00
endfunction

function HarshLesson_IsValidTarget takes nothing returns boolean
    local unit u = GetFilterUnit()

    if not IsUnitEnemy(u, Player(PLAYER_NEUTRAL_AGGRESSIVE)) then
        set u = null
        return false
    endif

    if not IsUnitType(u, UNIT_TYPE_HERO) then
        set u = null
        return false
    endif

    if IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
        set u = null
        return false
    endif

    if GetWidgetLife(u) <= 0.405 then
        set u = null
        return false
    endif

    set u = null
    return true
endfunction

function HarshLesson_GetTarget takes nothing returns unit
    local group g = CreateGroup()
    local unit u

    call GroupEnumUnitsInRect(g, gg_rct_Scholomance_Music, Filter(function HarshLesson_IsValidTarget))
    set u = FirstOfGroup(g)

    call DestroyGroup(g)
    set g = null

    return u
endfunction

function HarshLesson_IsUnitInRect takes unit u, rect r returns boolean
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)

    return x >= GetRectMinX(r) and x <= GetRectMaxX(r) and y >= GetRectMinY(r) and y <= GetRectMaxY(r)
endfunction

function HarshLesson_Teleport takes unit u, rect r returns nothing
    local effect e

    call SetUnitPosition(u, GetRectCenterX(r), GetRectCenterY(r))

    set e = AddSpecialEffectTarget("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", u, "origin")
    call DestroyEffect(e)

    set e = null
endfunction

function HarshLesson_CreateSkeleton takes rect r returns nothing
    call CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'u010', GetRectCenterX(r), GetRectCenterY(r), 247.00)
endfunction

function Trig_Harsh_Lesson_Actions takes nothing returns nothing
    local trigger t = GetTriggeringTrigger()
    local unit target

    call DisableTrigger(t)

    set target = HarshLesson_GetTarget()
    set udg_G_HarshLesson = target

    if target == null then
        call EnableTrigger(t)
        set t = null
        return
    endif

    call HarshLesson_Teleport(target, gg_rct_Harsh_Lesson_TP_4)

    // HARSH LESSON!
    call CreateTextTagUnitBJ("School is in SESSION!!", gg_unit_U01S_1754, 0.00, 10.00, 100.00, 60.00, 80.00, 0)
    call PlaySoundOnUnitBJ(gg_snd_13_GANDLING_SCHOOL_IS, 88.00, gg_unit_U01S_1754)
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 20.00, 90.00)
    call cleanUpText(1.5, 1.2)

    call GameTimeWait(1.00)

    // Create Skeletons
    call IssueImmediateOrder(gg_unit_U01S_1754, "instant")
    call HarshLesson_CreateSkeleton(gg_rct_HMSkeletons1)
    call HarshLesson_CreateSkeleton(gg_rct_HMSkeletons2)

    call GameTimeWait(4.00)

    // TP Back
    if target != null and HarshLesson_IsUnitInRect(target, gg_rct_Harsh_Lesson_TP_4) then
        call HarshLesson_Teleport(target, gg_rct_Harsh_Lesson_TP_Center)
    endif

    call GameTimeWait(8.00)
    call EnableTrigger(t)

    set target = null
    set t = null
endfunction

//===========================================================================
function InitTrig_Harsh_Lesson takes nothing returns nothing
    set gg_trg_Harsh_Lesson = CreateTrigger()
    call TriggerRegisterUnitEvent( gg_trg_Harsh_Lesson, gg_unit_U01S_1754, EVENT_UNIT_DAMAGED )
    call TriggerAddCondition(gg_trg_Harsh_Lesson, Condition(function Trig_Harsh_Lesson_Conditions))
    call TriggerAddAction(gg_trg_Harsh_Lesson, function Trig_Harsh_Lesson_Actions)
endfunction