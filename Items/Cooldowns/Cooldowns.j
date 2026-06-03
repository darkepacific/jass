function Trig_Cooldowns_IsCarriedItemAbility takes unit hero, ability castAbility returns boolean
    local integer inventorySlot = 0
    local integer abilityIndex
    local integer castAbilityId
    local item carriedItem
    local ability itemAbility

    if hero == null or castAbility == null then
        set hero = null
        set castAbility = null
        return false
    endif

    set castAbilityId = BlzGetAbilityId(castAbility)
    if castAbilityId == 0 then
        set hero = null
        set castAbility = null
        return false
    endif

    loop
        exitwhen inventorySlot >= UnitInventorySize(hero)
        set carriedItem = UnitItemInSlot(hero, inventorySlot)
        if carriedItem != null then
            set abilityIndex = 0
            loop
                exitwhen abilityIndex >= 6
                set itemAbility = BlzGetItemAbilityByIndex(carriedItem, abilityIndex)
                // Prefer exact handle match, but fall back to rawcode so item casts are still caught
                // if the spell event exposes a different handle instance for the same item ability.
                if itemAbility == castAbility or (itemAbility != null and BlzGetAbilityId(itemAbility) == castAbilityId) then
                    set itemAbility = null
                    set carriedItem = null
                    set hero = null
                    set castAbility = null
                    return true
                endif
                set itemAbility = null
                set abilityIndex = abilityIndex + 1
            endloop
        endif
        set carriedItem = null
        set inventorySlot = inventorySlot + 1
    endloop

    set hero = null
    set castAbility = null
    return false
endfunction

function Trig_Cooldowns_GetAbilityBaseCooldown takes unit hero, integer abilityId returns real
    local real cooldown = 0.0

    if hero == null or abilityId == 0 then
        set hero = null
        return 0.0
    endif

    set cooldown = BlzGetUnitAbilityCooldown(hero, abilityId, 0)
    if cooldown <= 0.0 then
        set cooldown = BlzGetUnitAbilityCooldown(hero, abilityId, 1)
    endif
    if cooldown <= 0.0 then
        set cooldown = BlzGetAbilityCooldown(abilityId, 0)
    endif
    if cooldown <= 0.0 then
        set cooldown = BlzGetAbilityCooldown(abilityId, 1)
    endif

    set hero = null
    return cooldown
endfunction

function Trig_Cooldowns_Conditions takes nothing returns boolean
    //if ( GetSpellAbilityId() == 'A035' ) then  // Cat NE
      //  return false
    //endif
    //if ( GetSpellAbilityId() == 'A031' ) then // Bear NE
      //  return false
    //endif
    if ( GetSpellAbilityId() == 'ANss' ) then //Banshees/Elune's Viel
        return false
    endif
    if ( GetSpellAbilityId() == 'A02D' ) then //Hearthstone
        return false
    endif
    if ( GetSpellAbilityId() == 'A0DK' ) then //Lay On Hands
        return false
    endif
    if ( GetSpellAbilityId() == 'A02U' ) then
        return false
    endif
    if ( GetSpellAbilityId() == 'A0FW' ) then //Ressurection
        return false
    endif
    if ( GetSpellAbilityId() == 'A0G4' ) then //Ancestral
        return false
    endif
    if ( GetSpellAbilityId() == 'A0H2' ) then //Pyroblast
        return false
    endif
    if ( GetSpellAbilityId() == 'A0GO' ) then  //KilJaedens Meteor
        return false
    endif
    if ( GetSpellAbilityId() == 'A0GQ' ) then  //Gift of the Naaru
        return false
    endif
    if ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == false ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Func009C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A0AE' ) ) then
        return false
    endif
    if ( GetUnitTypeId(GetTriggerUnit()) == 'O00N' ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Func011C takes nothing returns boolean
    if ( not ( udg_CooldownRemaining < 1.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Actions takes nothing returns nothing
    local real itemCooldown
    set udg_Temp_Unit_CD = GetTriggerUnit()
    call Debug("CD's Triggered")
    if ( Trig_Cooldowns_Func009C() ) then
        call BlzStartUnitAbilityCooldown( udg_Temp_Unit_CD, GetSpellAbilityId(), 1.00 )
        return
    endif
    if (GetSpellAbilityId() == 'A03J') then
        if udg_Temp_Unit_CD == udg_yA_Unholy_DK and udg_Unholy_DK_Reset_A then
            set udg_Unholy_DK_Reset_A = false
            call BlzEndUnitAbilityCooldown( udg_Temp_Unit_CD, 'A03J' )
            return
        elseif udg_Temp_Unit_CD == udg_yH_Unholy_DK and udg_Unholy_DK_Reset_H then
            set udg_Unholy_DK_Reset_H = false
            call BlzEndUnitAbilityCooldown( udg_Temp_Unit_CD, 'A03J' )
            return
        endif
    endif
    if ( Trig_Cooldowns_IsCarriedItemAbility(udg_Temp_Unit_CD, GetSpellAbility()) ) then
        set itemCooldown = BlzGetUnitAbilityCooldownRemaining(udg_Temp_Unit_CD, GetSpellAbilityId())
        if ( itemCooldown <= 0.0 ) then
            set itemCooldown = Trig_Cooldowns_GetAbilityBaseCooldown(udg_Temp_Unit_CD, GetSpellAbilityId())
        endif
        if ( itemCooldown > 0.0 ) then
            call BlzStartUnitAbilityCooldown( udg_Temp_Unit_CD, GetSpellAbilityId(), itemCooldown )
        endif
        return
    endif
    call TriggerExecute( gg_trg_Cooldown_Maths)
    if ( Trig_Cooldowns_Func011C() ) then
        call BlzStartUnitAbilityCooldown( udg_Temp_Unit_CD, GetSpellAbilityId(), ( udg_CooldownRemaining * BlzGetUnitAbilityCooldownRemaining(udg_Temp_Unit_CD, GetSpellAbilityId()) ) )
    endif
endfunction

//===========================================================================
function InitTrig_Cooldowns takes nothing returns nothing
    set gg_trg_Cooldowns = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Cooldowns, EVENT_PLAYER_UNIT_SPELL_ENDCAST )
    call TriggerAddCondition( gg_trg_Cooldowns, Condition( function Trig_Cooldowns_Conditions ) )
    call TriggerAddAction( gg_trg_Cooldowns, function Trig_Cooldowns_Actions )
endfunction
