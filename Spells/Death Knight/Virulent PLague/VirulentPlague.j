function CastVirulentPlague takes unit source, unit target returns nothing
    local integer str
    local integer int
    local real dmg = 0.00
    local location udg_Temp_Unit_Point
    local integer lvl = GetUnitAbilityLevel( source, 'A03J')
    
    call Debug("|cc055c315Attempted to Plague Target|r")
    if ( lvl > 0 ) then
        set str =  GetHeroStatBJ(bj_HEROSTAT_STR, source, true) - GetHeroStatBJ(bj_HEROSTAT_STR, source, false)
        set int =  GetHeroStatBJ(bj_HEROSTAT_INT, source, true) - GetHeroStatBJ(bj_HEROSTAT_INT, source, false)
        set dmg = ( I2R(lvl) * 10 + 0.50 * I2R(str + int)  )
        if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(source)) * udg_NUM_OF_TC + 13 ]  then 
            set dmg = ( dmg * 1.40 )
        endif
        call Debug("|cc055c315Virulent Plague Dmg: |r" + R2S(dmg))

        // Add the unit to the SpellUnits
        if ( source == udg_yA_Unholy_DK ) then
            call Debug("|cc055c315Added to DK_A Plague: |r"+ GetUnitName(target) )
            call SpellUnits_CleanMissingBuff( udg_z_DK_UNHO_A, 40, 63, 'B01K')
            call SpellUnits_Add(target, udg_z_DK_UNHO_A, 40, 63) 
            set lvl = 1
        elseif ( source == udg_yH_Unholy_DK ) then
            call Debug("|cc055c315Added to DK_H Plague: |r"+ GetUnitName(target) )
            call SpellUnits_CleanMissingBuff( udg_z_DK_UNHO_H, 40, 63, 'B039')
            call SpellUnits_Add(target, udg_z_DK_UNHO_H, 40, 63) 
            set lvl = 7
        endif

        // Move the Unit
        call SetUnitOwner( gg_unit_e00H_2048, GetOwningPlayer(source), true )
        set udg_Temp_Unit_Point = GetUnitLoc(source)
        call SetUnitPositionLocFacingBJ( gg_unit_e00H_2048, udg_Temp_Unit_Point, GetUnitFacing(source) )
        call RemoveLocation (udg_Temp_Unit_Point)
        
        // Order to Cast
        call SetUnitAbilityLevel(  gg_unit_e00H_2048,'A03H', lvl )
        call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(gg_unit_e00H_2048, 'A03H'), ABILITY_RLF_PRIMARY_DAMAGE, lvl -1, dmg )
        call IssueTargetOrderBJ( gg_unit_e00H_2048, "acidbomb", target )
    endif
    set udg_Temp_Unit_Point = null
endfunction

function DoesUnitHaveVirulentPlague takes unit u, unit caster returns boolean
    if (caster == udg_yA_Unholy_DK and UnitHasBuffBJ(u, 'B01K')) then
        return true
    elseif(caster == udg_yH_Unholy_DK and UnitHasBuffBJ(u, 'B039')) then
            return true
    endif
    return false
endfunction

function SpreadPlague takes nothing returns nothing
    if (DoesUnitHaveVirulentPlague(spellUnit, spellCaster)) then
        call IssueTargetOrderBJ( gg_unit_e00H_2048, "acidbomb", spellUnit )
        call UnitDamageTargetBJ( spellCaster, spellUnit, udg_RealStatCalc, ATTACK_TYPE_SIEGE, DAMAGE_TYPE_MAGIC )
        call AddSpecialEffectTargetUnitBJ( "overhead", spellUnit, "war3mapImported\\plaguebomb_bigger.mdx" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call AddSpecialEffectTargetUnitBJ( "origin", spellUnit, "war3mapImported\\PlagueTeamForsakenMissileV1.01.mdx" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call HasFirelords( spellUnit )
    else
        if spellCaster == udg_yA_Unholy_DK then
            call SpellUnits_Remove( spellUnit, udg_z_DK_UNHO_A, 40, 63 )
        elseif spellCaster == udg_yH_Unholy_DK then
            call SpellUnits_Remove( spellUnit, udg_z_DK_UNHO_H, 40, 63 )
        endif
    endif
endfunction

