globals
    trigger FireDamageTrigger = null
    trigger FireTrailTrigger = null
    group FireGroup = null
    unit phoenix = null
endglobals

// Condition function to check if the summoned unit is the Phoenix
function Trig_Kael_Pheonix_Burn_Conditions takes nothing returns boolean
    return GetUnitTypeId(GetSummonedUnit()) == 'h02C'
endfunction

// Function to check if a unit is an enemy and alive
function IsEnemyOfKael takes nothing returns boolean
    return IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(gg_unit_Hkal_1415)) and IsUnitAliveBJ(GetFilterUnit())
endfunction

// Function to apply periodic damage from fire units
// function Trig_Kael_Phoenix_Burn_Damage takes nothing returns nothing
//     local unit fire
//     local unit enemy
//     local real fireX
//     local real fireY
//     local real enemyX
//     local real enemyY
//     local real distance
//     local group tempGroup = CreateGroup()  // Temporary group used for looping
//     local group enemyGroup = CreateGroup() // Group for detecting nearby enemies
//     local real damage = 50

//     if FireGroup == null then
//         return
//     endif

//     // Copy all units from FireGroup into tempGroup
//     call GroupAddGroup(FireGroup, tempGroup)

//     // Enumerate all enemy units within a large area (you can adjust this range if necessary)
//     call GroupEnumUnitsInRange(enemyGroup, GetUnitX(phoenix), GetUnitY(phoenix), 3000.0, Condition(function IsEnemyOfKael))

//     // Iterate through all fire units in tempGroup
//     loop
//         set fire = FirstOfGroup(tempGroup)
//         exitwhen fire == null
//         set fireX = GetUnitX(fire)
//         set fireY = GetUnitY(fire)

//         // Check each enemy in enemyGroup for proximity to the current fire unit
//         loop
//             set enemy = FirstOfGroup(enemyGroup)
//             exitwhen enemy == null
//             set enemyX = GetUnitX(enemy)
//             set enemyY = GetUnitY(enemy)
//             set distance = SquareRoot((fireX - enemyX) * (fireX - enemyX) + (fireY - enemyY) * (fireY - enemyY))

//             if distance <= 180.0 then
//                 call Debug("|cffffcc00Phoenix Burned:|r " + GetUnitName(enemy))
//                 call UnitDamageTargetBJ(fire, enemy, damage, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC)
//                 call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", enemy, "origin"))
//             endif
//             call GroupRemoveUnit(enemyGroup, enemy)
//             set enemy = null
//         endloop

//         // After processing, check if the fire unit is dead and remove it from FireGroup if needed
//         if IsUnitDeadBJ(fire) then
//             call GroupRemoveUnit(FireGroup, fire)
//         endif

//         call GroupRemoveUnit(tempGroup, fire)  // Remove from tempGroup after processing
//         set fire = null
//     endloop

//     // Clean up and destroy the temporary groups
//     call DestroyGroup(tempGroup)
//     call DestroyGroup(enemyGroup)

//     // Null local variables to avoid memory leaks
//     set tempGroup = null
//     set enemyGroup = null
//     set fire = null
//     set enemy = null
// endfunction



// Drop fire trails and add to group with timed life
function CreatePheonixFire takes unit phoenix returns nothing
    local unit fire = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'e04N', GetUnitX(phoenix), GetUnitY(phoenix), bj_UNIT_FACING)
    call UnitApplyTimedLifeBJ(5.0, 'BTLF', fire)
    call GroupAddUnit(FireGroup, fire)
    // call EnableTrigger(FireDamageTrigger)
    set fire = null
endfunction

function Trig_Kael_Phoenix_Burn_Trail takes nothing returns nothing
    if IsUnitDeadBJ(phoenix) then
        call DisableTrigger(FireTrailTrigger)
        return
    endif

    call CreatePheonixFire(phoenix)
endfunction

function Trig_Kael_Pheonix_Burn_Actions takes nothing returns nothing
    local real angle = 225.0
    local real distance = 750.0
    local integer i = 0
    local location loc
    local integer shape
    set phoenix = GetSummonedUnit()

    call Debug("Kael Phoenix Burn Triggered")
    call SetUnitInvulnerable(phoenix, true) 

    // Clear FireGroup to ensure it's empty
    if FireGroup == null then
        set FireGroup = CreateGroup()
    else
        call GroupClear(FireGroup)
    endif

    if FireTrailTrigger == null then
        set FireTrailTrigger = CreateTrigger()
        call TriggerRegisterTimerEvent(FireTrailTrigger, 0.2, true) // Runs every 0.2 seconds
        call TriggerAddAction(FireTrailTrigger, function Trig_Kael_Phoenix_Burn_Trail)
    endif
    call EnableTrigger(FireTrailTrigger)

    // if FireDamageTrigger == null then
    //     set FireDamageTrigger = CreateTrigger()
    //     call TriggerRegisterTimerEvent(FireDamageTrigger, 0.5, true) // Runs every second
    //     call TriggerAddAction(FireDamageTrigger, function Trig_Kael_Phoenix_Burn_Damage)
    // endif

    // 3 for triangle, 4 for square
    set shape = GetRandomInt(3, 4)
    loop
        exitwhen i >= shape

        set loc = PolarProjectionBJ(GetUnitLoc(phoenix), distance, angle)
        call IssuePointOrderLoc(phoenix, "move", loc)
        call RemoveLocation(loc)

        call TriggerSleepAction(1.5)
        // call CreatePheonixFire(phoenix)
        // call TriggerSleepAction(0.3)

        set angle = angle + (360/shape)
        set i = i + 1
    endloop

    call SetUnitInvulnerable(phoenix, false)
    call DisableTrigger(FireTrailTrigger)
    set loc = null
    // set phoenix = null
endfunction

//===========================================================================
// Proper initialization function
function InitTrig_Kael_Pheonix_Burn takes nothing returns nothing
    set gg_trg_Kael_Pheonix_Burn = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Kael_Pheonix_Burn, EVENT_PLAYER_UNIT_SUMMON)
    call TriggerAddCondition(gg_trg_Kael_Pheonix_Burn, Condition(function Trig_Kael_Pheonix_Burn_Conditions))
    call TriggerAddAction(gg_trg_Kael_Pheonix_Burn, function Trig_Kael_Pheonix_Burn_Actions)
endfunction
