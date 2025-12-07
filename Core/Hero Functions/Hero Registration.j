library HeroRegistration requires SpellUnits

    function A_Hero_Registration takes unit u returns nothing 
        call SetHeroVariable(u)
        if udg_yA_Beast_Hunter == u then 
            call TriggerRegisterUnitEvent(gg_trg_Beast_Master_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Combat_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Combat_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yA_Dark_Ranger == u then 
            call TriggerRegisterUnitEvent(gg_trg_Dark_Ranger_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Demon_Hunt == u then 
            call TriggerRegisterUnitEvent(gg_trg_Demon_Hunt_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Ele_Sham == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ele_Sham_Max, u, EVENT_UNIT_HERO_LEVEL) 
            //call AddSpecialEffectTargetUnitBJ( "origin", udg_yA_Ele_Sham, "HeroGlow.mdx" )    
        endif 
        if udg_yA_Enhance_Shaman == u then 
            call TriggerRegisterUnitEvent(gg_trg_Enhance_Shaman_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Frost_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Frost_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Marksman_Hunter == u then 
            call TriggerRegisterUnitEvent(gg_trg_Marksman_Hunter_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Prot_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Prot_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Resto_Sham == u then 
            call TriggerRegisterUnitEvent(gg_trg_Resto_Sham_Max, u, EVENT_UNIT_HERO_LEVEL) 
            //call TriggerRegisterUnitEvent( gg_trg_Resto_Sham_Death, u, EVENT_UNIT_DEATH)   
            call TriggerRegisterUnitStateEvent(gg_trg_Resto_Sham_Death, u, UNIT_STATE_LIFE, LESS_THAN_OR_EQUAL, 0.405) 
        endif 
        if udg_yA_Ret_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ret_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Shadow_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Shadow_Priest_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Shadow_Priest_Dies, u, EVENT_UNIT_DEATH) 
            call AddSpecialEffectTargetUnitBJ("origin", u, "HeroGlow.mdx") 
            call BlzSetSpecialEffectColorByPlayer(bj_lastCreatedEffect, GetOwningPlayer(u))
        endif 
        if udg_yA_Subtle_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Subtle_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yA_Destro_Warlock == u then 
            call TriggerRegisterUnitEvent(gg_trg_Destro_Warlock_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Disc_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Disc_Priest_Max, u, EVENT_UNIT_HERO_LEVEL)
            call SpellUnits_Clear(udg_z_PR_DISC_A, 40, 63)
        endif 
        if udg_yA_Arcane_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Arcane_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Arms_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Arms_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Ass_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ass_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yA_Blood_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Blood_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Bal_Druid == u then 
            call SetPlayerAbilityAvailableBJ( false, 'A03B', GetOwningPlayer(u) )
            call SetPlayerAbilityAvailableBJ( false, 'A0CZ', GetOwningPlayer(u) )
            call TriggerRegisterUnitEvent(gg_trg_Bal_Druid_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_A_Bal_Druid_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yA_Brew_Monk == u then 
            call TriggerRegisterUnitEvent(gg_trg_Brew_Monk_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Demon_Warlock == u then 
            call TriggerRegisterUnitEvent(gg_trg_Demon_Warlock_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Feral_Druid == u then 
            call TriggerRegisterUnitEvent(gg_trg_Feral_Druid_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_A_Feral_Druid_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yA_Fire_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Fire_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Frost_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Frost_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Fury_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Fury_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Holy_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Holy_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Holy_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Holy_Priest_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Prot_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Prot_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yA_Unholy_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Unholy_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call SpellUnits_Clear(udg_z_DK_UNHO_A, 40, 63)
        endif 
    endfunction 

    function H_Hero_Registration takes unit u returns nothing 
        call SetHeroVariable(u)
        if udg_yH_Beast_Hunter == u then 
            call TriggerRegisterUnitEvent(gg_trg_Beast_Master_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Combat_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Combat_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yH_Dark_Ranger == u then 
            call TriggerRegisterUnitEvent(gg_trg_Dark_Ranger_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Demon_Hunt == u then 
            call TriggerRegisterUnitEvent(gg_trg_Demon_Hunt_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Ele_Sham == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ele_Sham_Max, u, EVENT_UNIT_HERO_LEVEL) 
            //call AddSpecialEffectTargetUnitBJ( "origin", udg_yH_Ele_Sham, "HeroGlow.mdx" )       
        endif 
        if udg_yH_Enhance_Shaman == u then 
            call TriggerRegisterUnitEvent(gg_trg_Enhance_Shaman_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Frost_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Frost_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Marksman_Hunter == u then 
            call TriggerRegisterUnitEvent(gg_trg_Marksman_Hunter_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Prot_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Prot_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Resto_Sham == u then 
            call TriggerRegisterUnitEvent(gg_trg_Resto_Sham_Max, u, EVENT_UNIT_HERO_LEVEL) 
            //call TriggerRegisterUnitEvent( gg_trg_Resto_Sham_Death, u, EVENT_UNIT_DEATH)      
            call TriggerRegisterUnitStateEvent(gg_trg_Resto_Sham_Death, u, UNIT_STATE_LIFE, LESS_THAN_OR_EQUAL, 0.405) 
        endif 
        if udg_yH_Ret_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ret_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Shadow_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Shadow_Priest_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Shadow_Priest_Dies, u, EVENT_UNIT_DEATH) 
            // call AddSpecialEffectTargetUnitBJ("origin", u, "HeroGlow.mdx") //--Not needed on horde verion
        endif 
        if udg_yH_Subtle_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Subtle_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yH_Destro_Warlock == u then 
            call TriggerRegisterUnitEvent(gg_trg_Destro_Warlock_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Disc_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Disc_Priest_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call SpellUnits_Clear(udg_z_PR_DISC_H, 40, 63)
        endif 
        if udg_yH_Arcane_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Arcane_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Arms_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Arms_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Ass_Rogue == u then 
            call TriggerRegisterUnitEvent(gg_trg_Ass_Rogue_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_Rogue_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yH_Blood_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Blood_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Bal_Druid == u then 
            call SetPlayerAbilityAvailableBJ( false, 'A03B', GetOwningPlayer(u) )
            call SetPlayerAbilityAvailableBJ( false, 'A0CZ', GetOwningPlayer(u) ) 
            call TriggerRegisterUnitEvent(gg_trg_Bal_Druid_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_H_Bal_Druid_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yH_Brew_Monk == u then 
            call TriggerRegisterUnitEvent(gg_trg_Brew_Monk_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Demon_Warlock == u then 
            call TriggerRegisterUnitEvent(gg_trg_Demon_Warlock_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Feral_Druid == u then 
            call TriggerRegisterUnitEvent(gg_trg_Feral_Druid_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call TriggerRegisterUnitEvent(gg_trg_H_Feral_Druid_Dies, u, EVENT_UNIT_DEATH) 
        endif 
        if udg_yH_Fire_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Fire_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Frost_Mage == u then 
            call TriggerRegisterUnitEvent(gg_trg_Frost_Mage_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Fury_Warr == u then 
            call TriggerRegisterUnitEvent(gg_trg_Fury_Warr_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Holy_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Holy_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Holy_Priest == u then 
            call TriggerRegisterUnitEvent(gg_trg_Holy_Priest_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Prot_Pally == u then 
            call TriggerRegisterUnitEvent(gg_trg_Prot_Pally_Max, u, EVENT_UNIT_HERO_LEVEL) 
        endif 
        if udg_yH_Unholy_DK == u then 
            call TriggerRegisterUnitEvent(gg_trg_Unholy_DK_Max, u, EVENT_UNIT_HERO_LEVEL) 
            call SpellUnits_Clear(udg_z_DK_UNHO_H, 40, 63)
        endif 
    endfunction 

endlibrary
