globals
    unit gg_Pyroblast_Caster = null
    real gg_Pyroblast_Dmg = 0.00
endglobals


function Pyroblast_Explode_GroupDamage takes integer z_unit returns nothing
    local unit u = GetEnumUnit()
    if ( IsUnitTargetableEnemy(u, gg_Pyroblast_Caster ) ) then
        if u == udg_SpellUnits[ z_unit ] then
            // Main target takes 100% damage
            call UnitDamageTargetBJ( gg_Pyroblast_Caster, u, 2 *gg_Pyroblast_Dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
        else
            // Enemies around take 50% damage
            call UnitDamageTargetBJ( gg_Pyroblast_Caster, u, gg_Pyroblast_Dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
        endif
        call AddSpecialEffectTargetUnitBJ( "overhead", GetEnumUnit(), "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call HasFirelords( u )
    endif

    set u = null
endfunction

function Pyroblast_Explode_HU_GroupDamage takes nothing returns nothing
    call Pyroblast_Explode_GroupDamage( udg_z_MA_FIRE_A )
endfunction

function Pyroblast_Explode_BE_GroupDamage takes nothing returns nothing
    call Pyroblast_Explode_GroupDamage( udg_z_MA_FIRE_H )
endfunction
