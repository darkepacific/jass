function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A039' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer charges
    local integer reqCharges = 10
    local integer abilityLevel = ( GetUnitAbilityLevelSwapped('A039', GetTriggerUnit()) - 1 )
    local unit caster = GetTriggerUnit()
    

    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 10 ]  then
        set reqCharges = 6
    endif
    
    // Check if has enough reqCharges
    set bj_forLoopAIndex = 1
    set bj_forLoopAIndexEnd = 6
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        if ( GetItemTypeId(UnitItemInSlotBJ(caster, GetForLoopIndexA())) == 'I08E'  ) then
            set udg_Temp_Item = UnitItemInSlotBJ(caster, GetForLoopIndexA())
            set charges = GetItemcharges(UnitItemInSlotBJ(caster, GetForLoopIndexA()))
            if charges >= reqCharges then
                exitwhen true
            endif
        else
        endif
        set bj_forLoopAIndex = bj_forLoopAIndex + 1
    endloop
    if charges < reqCharges then
        call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
        call SetUnitManaBJ( GetTriggerUnit(), ( GetUnitStateSwap(UNIT_STATE_MANA, GetTriggerUnit()) + I2R(BlzGetAbilityManaCost('A039', ( GetUnitAbilityLevelSwapped(GetSpellAbilityId(), GetTriggerUnit()) - 1 ))) ) )
        call ErrorMessage( "Not enough Soul Shards.", GetOwningPlayer(GetTriggerUnit()) )
    else
        // Subtract charges, if not 0  then Drop
        call SetItemcharges( udg_Temp_Item, ( GetItemcharges(udg_Temp_Item) - reqCharges ) )
        set reqCharges = GetItemcharges(udg_Temp_Item)
        set charges = reqCharges
        if ( reqCharges <= 0  ) then
            call RemoveItem( udg_Temp_Item )
        else
            call UnitRemoveItemSwapped( udg_Temp_Item, caster )
        endif
        call AddSpecialEffectTargetUnitBJ( "overhead", caster, "war3mapImported\\Void Disc.mdx" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        // Destroy Old Stone
        if caster == udg_yA_Demon_Warlock then
            call RemoveItem( udg_yA_DEMO_SS )
        elseif caster == udg_yH_Demon_Warlock then
            call RemoveItem( udg_yH_DEMO_SS )
        endif
        call UnitAddItemByIdSwapped( 'ankh', caster )
        // Set New Stone
        if caster == udg_yA_Demon_Warlock then
            set udg_yA_DEMO_SS = GetLastCreatedItem()
        elseif caster == udg_yH_Demon_Warlock then
            set udg_yH_DEMO_SS = GetLastCreatedItem()
        endif
    
        // if there were reqCharges left over, see if there is bag space for them
        if charges > 0 then
            set reqCharges = charges
            set bj_forLoopAIndex = 1
            set bj_forLoopAIndexEnd = 6
            loop
                exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
                if ( UnitItemInSlotBJ(caster, GetForLoopIndexA()) == null ) then
                    call UnitAddItemSwapped( GetLastRemovedItem(), GetTriggerUnit() )
                    exitwhen true
                else
                    if ( GetItemTypeId(UnitItemInSlotBJ(caster, GetForLoopIndexA())) == 'I08E' and BlzGetItemIntegerField(UnitItemInSlotBJ(caster, GetForLoopIndexA()), ITEM_IF_NUMBER_OF_CHARGES) < 10 ) then
                        call SetItemcharges( UnitItemInSlotBJ(caster, GetForLoopIndexA()), ( GetItemcharges(UnitItemInSlotBJ(caster, GetForLoopIndexA())) + reqCharges ) )
                        exitwhen true
                    else
                    endif
                endif
                set bj_forLoopAIndex = bj_forLoopAIndex + 1
            endloop
        endif
        // Give Item Stats
        set abilityLevel = ( GetUnitAbilityLevelSwapped('A039', caster) + 0 )
        set abilityLevel = ( abilityLevel * 2 )
        set udg_Temp_Item = GetLastCreatedItem()
        if abilityLevel == 2 then
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIrc' )
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIx2' )
        elseif abilityLevel == 4 then
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DP' )
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIx4' )
        elseif abilityLevel == 6 then
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DQ' )
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0CO' )
        elseif abilityLevel == 8 then
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DR' )
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DU' )
        elseif abilityLevel == 10 then
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DT' )
            call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DV' )
        endif
        set udg_Temp_Int = 300 + ( 150 * abilityLevel )
        set udg_TempString = "+" +  I2S(abilityLevel) +  " Strength "  +  I2S(abilityLevel) +  " Agility "   +  I2S(abilityLevel) +  " Intelligence"  + "|n|n+|cc00FFFFF" +  I2S(abilityLevel) + "% Cooldown Reduction|r"
        set udg_TempString =  udg_TempString + "|n|n|c00CC44FFNon-Stacking Passive:|r  Automatically brings the Hero back to life with " + I2S(udg_Temp_Int)  + " hit points when the Hero dies."
        call BlzSetItemDescription( udg_Temp_Item,  udg_TempString )
        call BlzSetItemExtendedTooltip( udg_Temp_Item,  udg_TempString )
        call CreateTextTagUnitBJ( "Soulstone Created!", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0 )
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90.00 )
        call SetTextTagLifespan( GetLastCreatedTextTag(), 1.25 )
        call cleanUpText( 1.25, 0.75)
    endif
endfunction

//===========================================================================
function InitTrig_Create_Soul_Stone takes nothing returns nothing
    set gg_trg_Create_Soul_Stone = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Create_Soul_Stone, EVENT_PLAYER_UNIT_SPELL_CAST )
    call TriggerAddCondition( gg_trg_Create_Soul_Stone, Condition( function Trig_Create_Soul_Stone_Conditions ) )
    call TriggerAddAction( gg_trg_Create_Soul_Stone, function Trig_Create_Soul_Stone_Actions )
endfunction

