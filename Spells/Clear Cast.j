function Trig_Clear_Casting_Conditions takes nothing returns boolean
    if not ((GetUnitTypeId(GetTriggerUnit()) == 'H02Q') or (GetUnitTypeId(GetTriggerUnit()) == 'H02T')) then
        return false
    endif
    
    //Arcane Missiles
    if ( GetSpellAbilityId() == 'A08A' ) then
        return true
    endif
    //Arcane Explosion
    if ( GetSpellAbilityId() == 'A00G' ) then
        return true
    endif

    //Advance Blink
    if ( GetSpellAbilityId() == 'A08B' ) then
        return true
    endif
    //Polymorph
    if ( GetSpellAbilityId() == 'A00F' ) then
        return true
    endif

    //Arcane Intellect
    if ( GetSpellAbilityId() == 'A00H' ) then
        return true
    endif
    //Slow
    if ( GetSpellAbilityId() == 'Aslo' ) then
        return true
    endif
    //Counter Spell
    if ( GetSpellAbilityId() == 'A04I' ) then
        return true
    endif

    //Teleport
    if ( GetSpellAbilityId() == 'A08D' ) then
        return true
    endif
    //Alter Time
    if ( GetSpellAbilityId() == 'A0DF' ) then
        return true
    endif
    //Ice Block
    if ( GetSpellAbilityId() == 'A08G' ) then
        return true
    endif

    if ( GetSpellAbilityId() == 'A02D' ) then
        return false
    endif
    if ( GetSpellAbilityId() == 'A02U' ) then
        return false
    endif
    return false
endfunction

function Trig_Clear_Casting_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 2 ]  then

        if GetRandomInt(1,5)  > 4 then
            // set udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ] = true

            call AddSpecialEffectTargetUnitBJ( "overhead", caster, "Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl")
            call DestroyEffectBJ( GetLastCreatedEffectBJ() )
            call AddSpecialEffectTargetUnitBJ( "origin", caster, "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdl")
            call DestroyEffectBJ( GetLastCreatedEffectBJ() )

            set udg_HeroStatCalc = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(caster, GetSpellAbilityId()), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(caster, GetSpellAbilityId()) - 1)
            call SetUnitManaBJ(caster,  GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(udg_HeroStatCalc ) ) 

            call CreateTextTagUnitBJ( "Clear Casting", caster, 0.00, 10.00, 20.00, 60.00, 100.00, 0 )
            call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90.00 )
            call SetTextTagLifespan( GetLastCreatedTextTag(), 1.25 )
            call cleanUpText( 1.25, 0.75)
        endif
    endif
    set caster = null
endfunction


function ResetClearCasting takes nothing returns nothing
    // if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ]  then
    //     set udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ] = false
    //     set udg_HeroStatCalc = (GetUnitAbilityLevel(caster, 'A08A') * 10)
    //     set udg_HeroStatCalc = udg_HeroStatCalc + 25
    //     //set udg_HeroStatCalc = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(caster, 'A08A'), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(caster, 'A08A') - 1)
    //     call BlzSetUnitAbilityManaCost(caster, 'A08A', GetUnitAbilityLevel(caster, 'A08A') - 1, udg_HeroStatCalc)
    //     //set udg_HeroStatCalc = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(caster, 'A00G'), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(caster, 'A00G') - 1)        
    //     set udg_HeroStatCalc = (GetUnitAbilityLevel(caster, 'A00G') * 20)
    //     set udg_HeroStatCalc = udg_HeroStatCalc + 100
    //     call BlzSetUnitAbilityManaCost(caster, 'A00G', GetUnitAbilityLevel(caster, 'A00G') - 1, udg_HeroStatCalc)
    // endif
endfunction



//===========================================================================
function InitTrig_Clear_Casting takes nothing returns nothing
    set gg_trg_Clear_Casting = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Clear_Casting, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Clear_Casting, Condition( function Trig_Clear_Casting_Conditions ) )
    call TriggerAddAction( gg_trg_Clear_Casting, function Trig_Clear_Casting_Actions )
endfunction

