function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A039' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Soul_Stone_Func020C takes nothing returns boolean
    if ( not ( udg_HeroStatCalc <= 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Soul_Stone_Func039Func001Func003C takes nothing returns boolean
    if ( not ( GetItemTypeId(UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA())) == 'I08E' ) ) then
        return false
    endif
    if ( not ( BlzGetItemIntegerField(UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA()), ITEM_IF_NUMBER_OF_CHARGES) < 10 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Soul_Stone_Func039Func001C takes nothing returns boolean
    if ( not ( UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA()) == null ) ) then
        return false
    endif
    return true
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer Charges
    set udg_Temp_Unit = GetTriggerUnit()
    set udg_Temp_Int = 0
    set udg_HeroStatCalc = 10
    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 10 ]  then
    set udg_HeroStatCalc = 6
    endif
    // Check if has enough charges
    set bj_forLoopAIndex = 1
    set bj_forLoopAIndexEnd = 6
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        if ( GetItemTypeId(UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA())) == 'I08E'  ) then
            set udg_Temp_Item = UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA())
            set udg_Temp_Int = GetItemCharges(UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA()))
            if udg_Temp_Int >= udg_HeroStatCalc then
            exitwhen true
            endif
        else
        endif
        set bj_forLoopAIndex = bj_forLoopAIndex + 1
    endloop
    if udg_Temp_Int < udg_HeroStatCalc then
    call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
    call SetUnitManaBJ( GetTriggerUnit(), ( GetUnitStateSwap(UNIT_STATE_MANA, GetTriggerUnit()) + I2R(BlzGetAbilityManaCost('A039', ( GetUnitAbilityLevelSwapped(GetSpellAbilityId(), GetTriggerUnit()) - 1 ))) ) )
    call ErrorMessage( "Not enough Soul Shards.", GetOwningPlayer(GetTriggerUnit()) )
    else
    // Subtract Charges, if not 0  then Drop
    call SetItemCharges( udg_Temp_Item, ( GetItemCharges(udg_Temp_Item) - udg_HeroStatCalc ) )
    set udg_HeroStatCalc = GetItemCharges(udg_Temp_Item)
    set Charges = udg_HeroStatCalc
    if ( Trig_Soul_Stone_Func020C() ) then
        call RemoveItem( udg_Temp_Item )
    else
        call UnitRemoveItemSwapped( udg_Temp_Item, udg_Temp_Unit )
    endif
    call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "war3mapImported\\Void Disc.mdx" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    // Destroy Old Stone
    if udg_Temp_Unit == udg_yA_Demon_Warlock then
    call RemoveItem( udg_yA_DEMO_SS )
    elseif udg_Temp_Unit == udg_yH_Demon_Warlock then
    call RemoveItem( udg_yH_DEMO_SS )
    endif
    call UnitAddItemByIdSwapped( 'ankh', udg_Temp_Unit )
    // Set New Stone
    if udg_Temp_Unit == udg_yA_Demon_Warlock then
    set udg_yA_DEMO_SS = GetLastCreatedItem()
    elseif udg_Temp_Unit == udg_yH_Demon_Warlock then
    set udg_yH_DEMO_SS = GetLastCreatedItem()
    endif
    
    // if there were charges left over, see if there is bag space for them
    if Charges > 0 then
    set udg_HeroStatCalc = Charges
    set bj_forLoopAIndex = 1
    set bj_forLoopAIndexEnd = 6
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        if ( Trig_Soul_Stone_Func039Func001C() ) then
            call UnitAddItemSwapped( GetLastRemovedItem(), GetTriggerUnit() )
            exitwhen true
        else
            if ( Trig_Soul_Stone_Func039Func001Func003C() ) then
                call SetItemCharges( UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA()), ( GetItemCharges(UnitItemInSlotBJ(udg_Temp_Unit, GetForLoopIndexA())) + udg_HeroStatCalc ) )
                exitwhen true
            else
            endif
        endif
        set bj_forLoopAIndex = bj_forLoopAIndex + 1
    endloop
    endif
    // Give Item Stats
    set udg_HeroStatCalc = ( GetUnitAbilityLevelSwapped('A039', udg_Temp_Unit) + 0 )
    set udg_HeroStatCalc = ( udg_HeroStatCalc * 2 )
    set udg_Temp_Item = GetLastCreatedItem()
    if udg_HeroStatCalc == 2 then
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIrc' )
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIx2' )
    elseif udg_HeroStatCalc == 4 then
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DP' )
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'AIx4' )
    elseif udg_HeroStatCalc == 6 then
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DQ' )
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0CO' )
    elseif udg_HeroStatCalc == 8 then
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DR' )
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DU' )
    elseif udg_HeroStatCalc == 10 then
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DT' )
    call BlzItemAddAbilityBJ( udg_Temp_Item, 'A0DV' )
    endif
    set udg_Temp_Int = 300 + ( 150 * udg_HeroStatCalc )
    set udg_TempString = "+" +  I2S(udg_HeroStatCalc) +  " Strength "  +  I2S(udg_HeroStatCalc) +  " Agility "   +  I2S(udg_HeroStatCalc) +  " Intelligence"  + "|n|n+|cc00FFFFF" +  I2S(udg_HeroStatCalc) + "% Cooldown Reduction|r" 
    set udg_TempString =  udg_TempString + "|n|n|c00CC44FFNon-Stacking Passive:|r  Automatically brings the Hero back to life with " + I2S(udg_Temp_Int)  + " hit points when the Hero dies."
    call BlzSetItemDescription( udg_Temp_Item,  udg_TempString )
    call BlzSetItemExtendedTooltip( udg_Temp_Item,  udg_TempString )
                call CreateTextTagUnitBJ( "Soulstone Created!", udg_Temp_Unit, 0.00, 9.00, 80.00, 40.00, 100.00, 0 )
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

