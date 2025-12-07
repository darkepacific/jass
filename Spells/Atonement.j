function AtonementBuff takes unit caster, unit target returns nothing
    call SetUnitAbilityLevel( gg_unit_e03G_2001, 'A0BF', 40 )
    call IssueTargetOrder( gg_unit_e03G_2001, "innerfire", target  )
    //Talent to increase the duration of Atonement
endfunction

function Atonement takes unit caster, unit target returns nothing
    if IsUnitAlly(target , GetOwningPlayer(caster) ) then
        if caster == udg_yA_Disc_Priest then
            call AtonementBuff(caster, target)
            call SpellUnits_CleanMissingBuff( udg_z_PR_DISC_A, 40, 63, 'B030')
            call SpellUnits_Add(target, udg_z_PR_DISC_A, 40, 63) //Pencance can hold up to 24 chars
        elseif caster == udg_yH_Disc_Priest then
            call AtonementBuff(caster, target)
            call SpellUnits_CleanMissingBuff( udg_z_PR_DISC_H, 40, 63, 'B030')
            call SpellUnits_Add(target, udg_z_PR_DISC_H, 40, 63) //Pencance can hold up to 24 chars
        endif
    endif
endfunction

