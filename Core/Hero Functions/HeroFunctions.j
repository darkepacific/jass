library HeroFunctions 

    //Used in Save, cant use UnitTypeID because some heroes morph
    function ConvertHeroToString takes unit u returns string 
        if u == udg_yA_Arcane_Mage then 
            return "udg_yA_Arcane_Mage" 
        elseif u == udg_yH_Arcane_Mage then 
            return "udg_yH_Arcane_Mage" 
        elseif u == udg_yA_Arms_Warr then 
            return "udg_yA_Arms_Warr" 
        elseif u == udg_yH_Arms_Warr then 
            return "udg_yH_Arms_Warr" 
        elseif u == udg_yA_Ass_Rogue then 
            return "udg_yA_Ass_Rogue" 
        elseif u == udg_yH_Ass_Rogue then 
            return "udg_yH_Ass_Rogue" 
        elseif u == udg_yA_Bal_Druid then 
            return "udg_yA_Bal_Druid" 
        elseif u == udg_yH_Bal_Druid then 
            return "udg_yH_Bal_Druid" 
        elseif u == udg_yA_Beast_Hunter then 
            return "udg_yA_Beast_Hunter" 
        elseif u == udg_yH_Beast_Hunter then 
            return "udg_yH_Beast_Hunter" 
        elseif u == udg_yA_Blood_DK then 
            return "udg_yA_Blood_DK" 
        elseif u == udg_yH_Blood_DK then 
            return "udg_yH_Blood_DK" 
        elseif u == udg_yA_Brew_Monk then 
            return "udg_yA_Brew_Monk" 
        elseif u == udg_yH_Brew_Monk then 
            return "udg_yH_Brew_Monk" 
        elseif u == udg_yA_Combat_Rogue then 
            return "udg_yA_Combat_Rogue" 
        elseif u == udg_yH_Combat_Rogue then 
            return "udg_yH_Combat_Rogue" 
        elseif u == udg_yA_Dark_Ranger then 
            return "udg_yA_Dark_Ranger" 
        elseif u == udg_yH_Dark_Ranger then 
            return "udg_yH_Dark_Ranger" 
        elseif u == udg_yA_Demon_Hunt then 
            return "udg_yA_Demon_Hunt" 
        elseif u == udg_yH_Demon_Hunt then 
            return "udg_yH_Demon_Hunt" 
        elseif u == udg_yA_Demon_Warlock then 
            return "udg_yA_Demon_Warlock" 
        elseif u == udg_yH_Demon_Warlock then 
            return "udg_yH_Demon_Warlock" 
        elseif u == udg_yA_Destro_Warlock then 
            return "udg_yA_Destro_Warlock" 
        elseif u == udg_yH_Destro_Warlock then 
            return "udg_yH_Destro_Warlock" 
        elseif u == udg_yA_Disc_Priest then 
            return "udg_yA_Disc_Priest" 
        elseif u == udg_yH_Disc_Priest then 
            return "udg_yH_Disc_Priest" 
        elseif u == udg_yA_Ele_Sham then 
            return "udg_yA_Ele_Sham" 
        elseif u == udg_yH_Ele_Sham then 
            return "udg_yH_Ele_Sham" 
        elseif u == udg_yA_Enhance_Shaman then 
            return "udg_yA_Enhance_Shaman" 
        elseif u == udg_yH_Enhance_Shaman then 
            return "udg_yH_Enhance_Shaman" 
        elseif u == udg_yA_Feral_Druid then 
            return "udg_yA_Feral_Druid" 
        elseif u == udg_yH_Feral_Druid then 
            return "udg_yH_Feral_Druid" 
        elseif u == udg_yA_Fire_Mage then 
            return "udg_yA_Fire_Mage" 
        elseif u == udg_yH_Fire_Mage then 
            return "udg_yH_Fire_Mage" 
        elseif u == udg_yA_Frost_DK then 
            return "udg_yA_Frost_DK" 
        elseif u == udg_yH_Frost_DK then 
            return "udg_yH_Frost_DK" 
        elseif u == udg_yA_Frost_Mage then 
            return "udg_yA_Frost_Mage" 
        elseif u == udg_yH_Frost_Mage then 
            return "udg_yH_Frost_Mage" 
        elseif u == udg_yA_Fury_Warr then 
            return "udg_yA_Fury_Warr" 
        elseif u == udg_yH_Fury_Warr then 
            return "udg_yH_Fury_Warr" 
        elseif u == udg_yA_Holy_Pally then 
            return "udg_yA_Holy_Pally" 
        elseif u == udg_yH_Holy_Pally then 
            return "udg_yH_Holy_Pally" 
        elseif u == udg_yA_Holy_Priest then 
            return "udg_yA_Holy_Priest" 
        elseif u == udg_yH_Holy_Priest then 
            return "udg_yH_Holy_Priest" 
        elseif u == udg_yA_Marksman_Hunter then 
            return "udg_yA_Marksman_Hunter" 
        elseif u == udg_yH_Marksman_Hunter then 
            return "udg_yH_Marksman_Hunter" 
        elseif u == udg_yA_Prot_Pally then 
            return "udg_yA_Prot_Pally" 
        elseif u == udg_yH_Prot_Pally then 
            return "udg_yH_Prot_Pally" 
        elseif u == udg_yA_Prot_Warr then 
            return "udg_yA_Prot_Warr" 
        elseif u == udg_yH_Prot_Warr then 
            return "udg_yH_Prot_Warr" 
        elseif u == udg_yA_Resto_Sham then 
            return "udg_yA_Resto_Sham" 
        elseif u == udg_yH_Resto_Sham then 
            return "udg_yH_Resto_Sham" 
        elseif u == udg_yA_Ret_Pally then 
            return "udg_yA_Ret_Pally" 
        elseif u == udg_yH_Ret_Pally then 
            return "udg_yH_Ret_Pally" 
        elseif u == udg_yA_Shadow_Priest then 
            return "udg_yA_Shadow_Priest" 
        elseif u == udg_yH_Shadow_Priest then 
            return "udg_yH_Shadow_Priest" 
        elseif u == udg_yA_Subtle_Rogue then 
            return "udg_yA_Subtle_Rogue" 
        elseif u == udg_yH_Subtle_Rogue then 
            return "udg_yH_Subtle_Rogue" 
        elseif u == udg_yA_Unholy_DK then 
            return "udg_yA_Unholy_DK" 
        elseif u == udg_yH_Unholy_DK then 
            return "udg_yH_Unholy_DK" 
        elseif u == udg_yA_Veng_DH then 
            return "udg_yA_Veng_DH"
        elseif u == udg_yH_Veng_DH then
            return "udg_yH_Veng_DH"   
        endif 
        
        return "" 
    endfunction 

    //Used to check if the hero to be loaded is already in play
    function ConvertStringtoHero takes string s returns unit
        if s == "udg_yA_Arcane_Mage" then
            return udg_yA_Arcane_Mage
        elseif s == "udg_yH_Arcane_Mage" then
            return udg_yH_Arcane_Mage
        elseif s == "udg_yA_Arms_Warr" then
            return udg_yA_Arms_Warr
        elseif s == "udg_yH_Arms_Warr" then
            return udg_yH_Arms_Warr
        elseif s == "udg_yA_Ass_Rogue" then
            return udg_yA_Ass_Rogue
        elseif s == "udg_yH_Ass_Rogue" then
            return udg_yH_Ass_Rogue
        elseif s == "udg_yA_Bal_Druid" then
            return udg_yA_Bal_Druid
        elseif s == "udg_yH_Bal_Druid" then
            return udg_yH_Bal_Druid
        elseif s == "udg_yA_Beast_Hunter" then
            return udg_yA_Beast_Hunter
        elseif s == "udg_yH_Beast_Hunter" then
            return udg_yH_Beast_Hunter
        elseif s == "udg_yA_Blood_DK" then
            return udg_yA_Blood_DK
        elseif s == "udg_yH_Blood_DK" then
            return udg_yH_Blood_DK
        elseif s == "udg_yA_Brew_Monk" then
            return udg_yA_Brew_Monk
        elseif s == "udg_yH_Brew_Monk" then
            return udg_yH_Brew_Monk
        elseif s == "udg_yA_Combat_Rogue" then
            return udg_yA_Combat_Rogue
        elseif s == "udg_yH_Combat_Rogue" then
            return udg_yH_Combat_Rogue
        elseif s == "udg_yA_Dark_Ranger" then
            return udg_yA_Dark_Ranger
        elseif s == "udg_yH_Dark_Ranger" then
            return udg_yH_Dark_Ranger
        elseif s == "udg_yA_Demon_Hunt" then
            return udg_yA_Demon_Hunt
        elseif s == "udg_yH_Demon_Hunt" then
            return udg_yH_Demon_Hunt
        elseif s == "udg_yA_Demon_Warlock" then
            return udg_yA_Demon_Warlock
        elseif s == "udg_yH_Demon_Warlock" then
            return udg_yH_Demon_Warlock
        elseif s == "udg_yA_Destro_Warlock" then
            return udg_yA_Destro_Warlock
        elseif s == "udg_yH_Destro_Warlock" then
            return udg_yH_Destro_Warlock
        elseif s == "udg_yA_Disc_Priest" then
            return udg_yA_Disc_Priest
        elseif s == "udg_yH_Disc_Priest" then
            return udg_yH_Disc_Priest
        elseif s == "udg_yA_Ele_Sham" then
            return udg_yA_Ele_Sham
        elseif s == "udg_yH_Ele_Sham" then
            return udg_yH_Ele_Sham
        elseif s == "udg_yA_Enhance_Shaman" then
            return udg_yA_Enhance_Shaman
        elseif s == "udg_yH_Enhance_Shaman" then
            return udg_yH_Enhance_Shaman
        elseif s == "udg_yA_Feral_Druid" then
            return udg_yA_Feral_Druid
        elseif s == "udg_yH_Feral_Druid" then
            return udg_yH_Feral_Druid
        elseif s == "udg_yA_Fire_Mage" then
            return udg_yA_Fire_Mage
        elseif s == "udg_yH_Fire_Mage" then
            return udg_yH_Fire_Mage
        elseif s == "udg_yA_Frost_DK" then
            return udg_yA_Frost_DK
        elseif s == "udg_yH_Frost_DK" then
            return udg_yH_Frost_DK
        elseif s == "udg_yA_Frost_Mage" then
            return udg_yA_Frost_Mage
        elseif s == "udg_yH_Frost_Mage" then
            return udg_yH_Frost_Mage
        elseif s == "udg_yA_Fury_Warr" then
            return udg_yA_Fury_Warr
        elseif s == "udg_yH_Fury_Warr" then
            return udg_yH_Fury_Warr
        elseif s == "udg_yA_Holy_Pally" then
            return udg_yA_Holy_Pally
        elseif s == "udg_yH_Holy_Pally" then
            return udg_yH_Holy_Pally
        elseif s == "udg_yA_Holy_Priest" then
            return udg_yA_Holy_Priest
        elseif s == "udg_yH_Holy_Priest" then
            return udg_yH_Holy_Priest
        elseif s == "udg_yA_Marksman_Hunter" then
            return udg_yA_Marksman_Hunter
        elseif s == "udg_yH_Marksman_Hunter" then
            return udg_yH_Marksman_Hunter
        elseif s == "udg_yA_Prot_Pally" then
            return udg_yA_Prot_Pally
        elseif s == "udg_yH_Prot_Pally" then
            return udg_yH_Prot_Pally
        elseif s == "udg_yA_Prot_Warr" then
            return udg_yA_Prot_Warr
        elseif s == "udg_yH_Prot_Warr" then
            return udg_yH_Prot_Warr
        elseif s == "udg_yA_Resto_Sham" then
            return udg_yA_Resto_Sham
        elseif s == "udg_yH_Resto_Sham" then
            return udg_yH_Resto_Sham
        elseif s == "udg_yA_Ret_Pally" then
            return udg_yA_Ret_Pally
        elseif s == "udg_yH_Ret_Pally" then
            return udg_yH_Ret_Pally
        elseif s == "udg_yA_Shadow_Priest" then
            return udg_yA_Shadow_Priest
        elseif s == "udg_yH_Shadow_Priest" then
            return udg_yH_Shadow_Priest
        elseif s == "udg_yA_Subtle_Rogue" then
            return udg_yA_Subtle_Rogue
        elseif s == "udg_yH_Subtle_Rogue" then
            return udg_yH_Subtle_Rogue
        elseif s == "udg_yA_Unholy_DK" then
            return udg_yA_Unholy_DK
        elseif s == "udg_yH_Unholy_DK" then
            return udg_yH_Unholy_DK
        elseif s == "udg_yA_Veng_DH" then
            return udg_yA_Veng_DH
        elseif s == "udg_yH_Veng_DH" then
            return udg_yH_Veng_DH
        endif
        
        return null
    endfunction

    //Used in load gui, kept in case of future use (can probably be removed)
    function SetHeroVariableFromString takes string s, unit u returns nothing
        if s == "udg_yA_Arcane_Mage" then
            set udg_yA_Arcane_Mage = u
        elseif s == "udg_yH_Arcane_Mage" then
            set udg_yH_Arcane_Mage = u
        elseif s == "udg_yA_Arms_Warr" then
            set udg_yA_Arms_Warr = u
        elseif s == "udg_yH_Arms_Warr" then
            set udg_yH_Arms_Warr = u
        elseif s == "udg_yA_Ass_Rogue" then
            set udg_yA_Ass_Rogue = u
        elseif s == "udg_yH_Ass_Rogue" then
            set udg_yH_Ass_Rogue = u
        elseif s == "udg_yA_Bal_Druid" then
            set udg_yA_Bal_Druid = u
        elseif s == "udg_yH_Bal_Druid" then
            set udg_yH_Bal_Druid = u
        elseif s == "udg_yA_Beast_Hunter" then
            set udg_yA_Beast_Hunter = u
        elseif s == "udg_yH_Beast_Hunter" then
            set udg_yH_Beast_Hunter = u
        elseif s == "udg_yA_Blood_DK" then
            set udg_yA_Blood_DK = u
        elseif s == "udg_yH_Blood_DK" then
            set udg_yH_Blood_DK = u
        elseif s == "udg_yA_Brew_Monk" then
            set udg_yA_Brew_Monk = u
        elseif s == "udg_yH_Brew_Monk" then
            set udg_yH_Brew_Monk = u
        elseif s == "udg_yA_Combat_Rogue" then
            set udg_yA_Combat_Rogue = u
        elseif s == "udg_yH_Combat_Rogue" then
            set udg_yH_Combat_Rogue = u
        elseif s == "udg_yA_Dark_Ranger" then
            set udg_yA_Dark_Ranger = u
        elseif s == "udg_yH_Dark_Ranger" then
            set udg_yH_Dark_Ranger = u
        elseif s == "udg_yA_Demon_Hunt" then
            set udg_yA_Demon_Hunt = u
        elseif s == "udg_yH_Demon_Hunt" then
            set udg_yH_Demon_Hunt = u
        elseif s == "udg_yA_Demon_Warlock" then
            set udg_yA_Demon_Warlock = u
        elseif s == "udg_yH_Demon_Warlock" then
            set udg_yH_Demon_Warlock = u
        elseif s == "udg_yA_Destro_Warlock" then
            set udg_yA_Destro_Warlock = u
        elseif s == "udg_yH_Destro_Warlock" then
            set udg_yH_Destro_Warlock = u
        elseif s == "udg_yA_Disc_Priest" then
            set udg_yA_Disc_Priest = u
        elseif s == "udg_yH_Disc_Priest" then
            set udg_yH_Disc_Priest = u
        elseif s == "udg_yA_Ele_Sham" then
            set udg_yA_Ele_Sham = u
        elseif s == "udg_yH_Ele_Sham" then
            set udg_yH_Ele_Sham = u
        elseif s == "udg_yA_Enhance_Shaman" then
            set udg_yA_Enhance_Shaman = u
        elseif s == "udg_yH_Enhance_Shaman" then
            set udg_yH_Enhance_Shaman = u
        elseif s == "udg_yA_Feral_Druid" then
            set udg_yA_Feral_Druid = u
        elseif s == "udg_yH_Feral_Druid" then
            set udg_yH_Feral_Druid = u
        elseif s == "udg_yA_Fire_Mage" then
            set udg_yA_Fire_Mage = u
        elseif s == "udg_yH_Fire_Mage" then
            set udg_yH_Fire_Mage = u
        elseif s == "udg_yA_Frost_DK" then
            set udg_yA_Frost_DK = u
        elseif s == "udg_yH_Frost_DK" then
            set udg_yH_Frost_DK = u
        elseif s == "udg_yA_Frost_Mage" then
            set udg_yA_Frost_Mage = u
        elseif s == "udg_yH_Frost_Mage" then
            set udg_yH_Frost_Mage = u
        elseif s == "udg_yA_Fury_Warr" then
            set udg_yA_Fury_Warr = u
        elseif s == "udg_yH_Fury_Warr" then
            set udg_yH_Fury_Warr = u
        elseif s == "udg_yA_Holy_Pally" then
            set udg_yA_Holy_Pally = u
        elseif s == "udg_yH_Holy_Pally" then
            set udg_yH_Holy_Pally = u
        elseif s == "udg_yA_Holy_Priest" then
            set udg_yA_Holy_Priest = u
        elseif s == "udg_yH_Holy_Priest" then
            set udg_yH_Holy_Priest = u
        elseif s == "udg_yA_Marksman_Hunter" then
            set udg_yA_Marksman_Hunter = u
        elseif s == "udg_yH_Marksman_Hunter" then
            set udg_yH_Marksman_Hunter = u
        elseif s == "udg_yA_Prot_Pally" then
            set udg_yA_Prot_Pally = u
        elseif s == "udg_yH_Prot_Pally" then
            set udg_yH_Prot_Pally = u
        elseif s == "udg_yA_Prot_Warr" then
            set udg_yA_Prot_Warr = u
        elseif s == "udg_yH_Prot_Warr" then
            set udg_yH_Prot_Warr = u
        elseif s == "udg_yA_Resto_Sham" then
            set udg_yA_Resto_Sham = u
        elseif s == "udg_yH_Resto_Sham" then
            set udg_yH_Resto_Sham = u
        elseif s == "udg_yA_Ret_Pally" then
            set udg_yA_Ret_Pally = u
        elseif s == "udg_yH_Ret_Pally" then
            set udg_yH_Ret_Pally = u
        elseif s == "udg_yA_Shadow_Priest" then
            set udg_yA_Shadow_Priest = u
        elseif s == "udg_yH_Shadow_Priest" then
            set udg_yH_Shadow_Priest = u
        elseif s == "udg_yA_Subtle_Rogue" then
            set udg_yA_Subtle_Rogue = u
        elseif s == "udg_yH_Subtle_Rogue" then
            set udg_yH_Subtle_Rogue = u
        elseif s == "udg_yA_Unholy_DK" then
            set udg_yA_Unholy_DK = u
        elseif s == "udg_yH_Unholy_DK" then
            set udg_yH_Unholy_DK = u
        elseif s == "udg_yA_Veng_DH" then
            set udg_yA_Veng_DH = u
        elseif s == "udg_yH_Veng_DH" then
            set udg_yH_Veng_DH = u
        endif
    endfunction

    //Used for GetTitles in Save and Dialogues
    function ConvertHeroToProperName takes unit u returns string 
        if u == udg_yA_Arcane_Mage or u == udg_yH_Arcane_Mage then 
            return "Arcane Mage" 
        elseif u == udg_yA_Arms_Warr or u == udg_yH_Arms_Warr then 
            return "Arms Warrior" 
        elseif u == udg_yA_Ass_Rogue or u == udg_yH_Ass_Rogue then 
            return "Assassination Rogue" 
        elseif u == udg_yA_Bal_Druid or u == udg_yH_Bal_Druid then 
            return "Balance & Resto Druid" 
        elseif u == udg_yA_Beast_Hunter or u == udg_yH_Beast_Hunter then 
            return "Beastmaster Hunter" 
        elseif u == udg_yA_Blood_DK or u == udg_yH_Blood_DK then 
            return "Blood Death Knight" 
        elseif u == udg_yA_Brew_Monk or u == udg_yH_Brew_Monk then 
            return "Brewmaster Monk" 
        elseif u == udg_yA_Combat_Rogue or u == udg_yH_Combat_Rogue then 
            return "Combat Rogue" 
        elseif u == udg_yA_Dark_Ranger or u == udg_yH_Dark_Ranger then 
            return "Dark Ranger" 
        elseif u == udg_yA_Demon_Hunt or u == udg_yH_Demon_Hunt then 
            return "Demon Hunter" 
        elseif u == udg_yA_Demon_Warlock or u == udg_yH_Demon_Warlock then 
            return "Demonology Warlock" 
        elseif u == udg_yA_Destro_Warlock or u == udg_yH_Destro_Warlock then 
            return "Destruction Warlock" 
        elseif u == udg_yA_Disc_Priest or u == udg_yH_Disc_Priest then 
            return "Discipline Priest" 
        elseif u == udg_yA_Ele_Sham or u == udg_yH_Ele_Sham then 
            return "Elemental Shaman" 
        elseif u == udg_yA_Enhance_Shaman or u == udg_yH_Enhance_Shaman then 
            return "Enhancement Shaman" 
        elseif u == udg_yA_Feral_Druid or u == udg_yH_Feral_Druid then 
            return "Feral & Guardian Druid" 
        elseif u == udg_yA_Fire_Mage or u == udg_yH_Fire_Mage then 
            return "Fire Mage" 
        elseif u == udg_yA_Frost_DK or u == udg_yH_Frost_DK then 
            return "Frost Death Knight" 
        elseif u == udg_yA_Frost_Mage or u == udg_yH_Frost_Mage then 
            return "Frost Mage" 
        elseif u == udg_yA_Fury_Warr or u == udg_yH_Fury_Warr then 
            return "Fury Warrior" 
        elseif u == udg_yA_Holy_Pally or u == udg_yH_Holy_Pally then 
            return "Holy Paladin" 
        elseif u == udg_yA_Holy_Priest or u == udg_yH_Holy_Priest then 
            return "Holy Priest" 
        elseif u == udg_yA_Marksman_Hunter or u == udg_yH_Marksman_Hunter then 
            return "Marksman Hunter" 
        elseif u == udg_yA_Prot_Pally or u == udg_yH_Prot_Pally then 
            return "Protection Paladin" 
        elseif u == udg_yA_Prot_Warr or u == udg_yH_Prot_Warr then 
            return "Protection Warrior" 
        elseif u == udg_yA_Resto_Sham or u == udg_yH_Resto_Sham then 
            return "Restoration Shaman" 
        elseif u == udg_yA_Ret_Pally or u == udg_yH_Ret_Pally then 
            return "Retribution Paladin" 
        elseif u == udg_yA_Shadow_Priest or u == udg_yH_Shadow_Priest then 
            return "Shadow Priest" 
        elseif u == udg_yA_Subtle_Rogue or u == udg_yH_Subtle_Rogue then 
            return "Subtlety Rogue" 
        elseif u == udg_yA_Unholy_DK or u == udg_yH_Unholy_DK then 
            return "Unholy Death Knight" 
        elseif u == udg_yA_Veng_DH or u == udg_yH_Veng_DH then 
            return "Vengeance Demon Hunter"
        endif
        
        return ""
    endfunction

    function ConvertStringToHeroUnitID takes string s returns integer
        if s == "udg_yA_Arcane_Mage" then
            return 'H02Q'
        elseif s == "udg_yH_Arcane_Mage" then
            return 'H02T'
        elseif s == "udg_yA_Arms_Warr" then
            return 'H01J'
        elseif s == "udg_yH_Arms_Warr" then
            return 'H028'
        elseif s == "udg_yA_Ass_Rogue" then
            return 'E001'
        elseif s == "udg_yH_Ass_Rogue" then
            return 'E03W'
        elseif s == "udg_yA_Bal_Druid" then
            return 'E00Z'
        elseif s == "udg_yH_Bal_Druid" then
            return 'E00C'
        elseif s == "udg_yA_Beast_Hunter" then
            return 'H00L'
        elseif s == "udg_yH_Beast_Hunter" then
            return 'H003'
        elseif s == "udg_yA_Blood_DK" then
            return 'U01V'
        elseif s == "udg_yH_Blood_DK" then
            return 'U01U'
        elseif s == "udg_yA_Brew_Monk" then
            return 'N041'
        elseif s == "udg_yH_Brew_Monk" then
            return 'N041'
        elseif s == "udg_yA_Combat_Rogue" then
            return 'E01O'
        elseif s == "udg_yH_Combat_Rogue" then
            return 'E035'
        elseif s == "udg_yA_Dark_Ranger" then
            return 'H02V'
        elseif s == "udg_yH_Dark_Ranger" then
            return 'H01I'
        elseif s == "udg_yA_Demon_Hunt" then
            return 'E02C'
        elseif s == "udg_yH_Demon_Hunt" then
            return 'E02E'
        elseif s == "udg_yA_Demon_Warlock" then
            return 'E02V'
        elseif s == "udg_yH_Demon_Warlock" then
            return 'E000'
        elseif s == "udg_yA_Destro_Warlock" then
            return 'E04A'
        elseif s == "udg_yH_Destro_Warlock" then
            return 'E02Z'
        elseif s == "udg_yA_Disc_Priest" then
            return 'H03J'
        elseif s == "udg_yH_Disc_Priest" then
            return 'H03I'
        elseif s == "udg_yA_Ele_Sham" then
            return 'O00R'
        elseif s == "udg_yH_Ele_Sham" then
            return 'O006'
        elseif s == "udg_yA_Enhance_Shaman" then
            return 'O00P'
        elseif s == "udg_yH_Enhance_Shaman" then
            return 'O00J'
        elseif s == "udg_yA_Feral_Druid" then
            return 'E00F'
        elseif s == "udg_yH_Feral_Druid" then
            return 'E02I'
        elseif s == "udg_yA_Fire_Mage" then
            return 'H009'
        elseif s == "udg_yH_Fire_Mage" then
            return 'H023'
        elseif s == "udg_yA_Frost_DK" then
            return 'U02Z'
        elseif s == "udg_yH_Frost_DK" then
            return 'U039'
        elseif s == "udg_yA_Frost_Mage" then
            return 'H00A'
        elseif s == "udg_yH_Frost_Mage" then
            return 'U001'
        elseif s == "udg_yA_Fury_Warr" then
            return 'H03D'
        elseif s == "udg_yH_Fury_Warr" then
            return 'H03E'
        elseif s == "udg_yA_Holy_Pally" then
            return 'H00M'
        elseif s == "udg_yH_Holy_Pally" then
            return 'H031'
        elseif s == "udg_yA_Holy_Priest" then
            return 'H02U'
        elseif s == "udg_yH_Holy_Priest" then
            return 'H02W'
        elseif s == "udg_yA_Marksman_Hunter" then
            return 'E03K'
        elseif s == "udg_yH_Marksman_Hunter" then
            return 'E03Y'
        elseif s == "udg_yA_Prot_Pally" then
            return 'H033'
        elseif s == "udg_yH_Prot_Pally" then
            return 'H032'
        elseif s == "udg_yA_Prot_Warr" then
            return 'H010'
        elseif s == "udg_yH_Prot_Warr" then
            return 'H01T'
        elseif s == "udg_yA_Resto_Sham" then
            return 'O00G'
        elseif s == "udg_yH_Resto_Sham" then
            return 'O00N'
        elseif s == "udg_yA_Ret_Pally" then
            return 'H00K'
        elseif s == "udg_yH_Ret_Pally" then
            return 'H00R'
        elseif s == "udg_yA_Shadow_Priest" then
            return 'H00T'
        elseif s == "udg_yH_Shadow_Priest" then
            return 'H00Q'
        elseif s == "udg_yA_Subtle_Rogue" then
            return 'E00E'
        elseif s == "udg_yH_Subtle_Rogue" then
            return 'E007'
        elseif s == "udg_yA_Unholy_DK" then
            return 'U03A'
        elseif s == "udg_yH_Unholy_DK" then
            return 'U036'
        endif
        
        return 'Hamg'
    endfunction

    function SetHeroVariable takes unit u returns nothing
        local integer unitId = GetUnitTypeId(u) 
        local boolean isAlliancePlayer = IsAlliancePlayer(GetOwningPlayer(u))

        if unitId == 'H02Q' then
            set udg_yA_Arcane_Mage = u
        elseif unitId == 'H02T' then
            set udg_yH_Arcane_Mage = u
        elseif unitId == 'H01J' then
            set udg_yA_Arms_Warr = u
        elseif unitId == 'H028' then
            set udg_yH_Arms_Warr = u
        elseif unitId == 'E001' then
            set udg_yA_Ass_Rogue = u
        elseif unitId == 'E03W' then
            set udg_yH_Ass_Rogue = u
        elseif unitId == 'E00Z' then
            set udg_yA_Bal_Druid = u
        elseif unitId == 'E00C' then
            set udg_yH_Bal_Druid = u
        elseif unitId == 'H00L' then
            set udg_yA_Beast_Hunter = u
        elseif unitId == 'H003' then
            set udg_yH_Beast_Hunter = u
        elseif unitId == 'U01V' then
            set udg_yA_Blood_DK = u
        elseif unitId == 'U01U' then
            set udg_yH_Blood_DK = u
        elseif unitId == 'N041' then
            if isAlliancePlayer then
                set udg_yA_Brew_Monk = u
            else
                set udg_yH_Brew_Monk = u
            endif
        elseif unitId == 'E01O' then
            set udg_yA_Combat_Rogue = u
        elseif unitId == 'E035' then
            set udg_yH_Combat_Rogue = u
        elseif unitId == 'H02V' then
            set udg_yA_Dark_Ranger = u
        elseif unitId == 'H01I' then
            set udg_yH_Dark_Ranger = u
        elseif unitId == 'E02C' then
            set udg_yA_Demon_Hunt = u
        elseif unitId == 'E02E' then
            set udg_yH_Demon_Hunt = u
        elseif unitId == 'E02V' then
            set udg_yA_Demon_Warlock = u
        elseif unitId == 'E000' then
            set udg_yH_Demon_Warlock = u
        elseif unitId == 'E04A' then
            set udg_yA_Destro_Warlock = u
        elseif unitId == 'E02Z' then
            set udg_yH_Destro_Warlock = u
        elseif unitId == 'H03J' then
            set udg_yA_Disc_Priest = u
        elseif unitId == 'H03I' then
            set udg_yH_Disc_Priest = u
        elseif unitId == 'O00R' then
            set udg_yA_Ele_Sham = u
        elseif unitId == 'O006' then
            set udg_yH_Ele_Sham = u
        elseif unitId == 'O00P' then
            set udg_yA_Enhance_Shaman = u
        elseif unitId == 'O00J' then
            set udg_yH_Enhance_Shaman = u
        elseif unitId == 'E00F' then
            set udg_yA_Feral_Druid = u
        elseif unitId == 'E02I' then
            set udg_yH_Feral_Druid = u
        elseif unitId == 'H009' then
            set udg_yA_Fire_Mage = u
        elseif unitId == 'H023' then
            set udg_yH_Fire_Mage = u
        elseif unitId == 'U02Z' then
            set udg_yA_Frost_DK = u
        elseif unitId == 'U039' then
            set udg_yH_Frost_DK = u
        elseif unitId == 'H00A' then
            set udg_yA_Frost_Mage = u
        elseif unitId == 'U001' then
            set udg_yH_Frost_Mage = u
        elseif unitId == 'H03D' then
            set udg_yA_Fury_Warr = u
        elseif unitId == 'H03E' then
            set udg_yH_Fury_Warr = u
        elseif unitId == 'H00M' then
            set udg_yA_Holy_Pally = u
        elseif unitId == 'H031' then
            set udg_yH_Holy_Pally = u
        elseif unitId == 'H02U' then
            set udg_yA_Holy_Priest = u
        elseif unitId == 'H02W' then
            set udg_yH_Holy_Priest = u
        elseif unitId == 'E03K' then
            set udg_yA_Marksman_Hunter = u
        elseif unitId == 'E03Y' then
            set udg_yH_Marksman_Hunter = u
        elseif unitId == 'H033' then
            set udg_yA_Prot_Pally = u
        elseif unitId == 'H032' then
            set udg_yH_Prot_Pally = u
        elseif unitId == 'H010' then
            set udg_yA_Prot_Warr = u
        elseif unitId == 'H01T' then
            set udg_yH_Prot_Warr = u
        elseif unitId == 'O00G' then
            set udg_yA_Resto_Sham = u
        elseif unitId == 'O00N' then
            set udg_yH_Resto_Sham = u
        elseif unitId == 'H00K' then
            set udg_yA_Ret_Pally = u
        elseif unitId == 'H00R' then
            set udg_yH_Ret_Pally = u
        elseif unitId == 'H00T' then
            set udg_yA_Shadow_Priest = u
        elseif unitId == 'H00Q' then
            set udg_yH_Shadow_Priest = u
        elseif unitId == 'E00E' then
            set udg_yA_Subtle_Rogue = u
        elseif unitId == 'E007' then
            set udg_yH_Subtle_Rogue = u
        elseif unitId == 'U03A' then
            set udg_yA_Unholy_DK = u
        elseif unitId == 'U036' then
            set udg_yH_Unholy_DK = u
        endif
    endfunction

    function GetSlotForHeroUnitID takes integer unitId returns integer
        // Death Knight (base 110)
        if unitId == 'U01V' or unitId == 'U01U' then
            return 110 // Blood DK
        elseif unitId == 'U02Z' or unitId == 'U039' then
            return 111 // Frost DK
        elseif unitId == 'U03A' or unitId == 'U036' then
            return 112 // Unholy DK

        // Demon Hunter (base 120)
        elseif unitId == 'E02C' or unitId == 'E02E' then
            return 120 // Havoc DH
        // elseif unitId == 'E02E' then
        //     return 121 // Vengeance DH

        // Druid (base 130)
        elseif unitId == 'E00Z' or unitId == 'E00C' then
            return 130 // Balance & Resto Druid
        elseif unitId == 'E00F' or unitId == 'E02I' then
            return 131 // Feral & Guardian Druid

        // Hunter (base 140)
        elseif unitId == 'H00L' or unitId == 'H003' then
            return 140 // Beastmaster Hunter
        elseif unitId == 'H02V' or unitId == 'H01I' then
            return 141 // Dark Ranger
        elseif unitId == 'E03K' or unitId == 'E03Y' then
            return 142 // Marksman Hunter

        // Mage (base 150)
        elseif unitId == 'H02Q' or unitId == 'H02T' then
            return 150 // Arcane Mage
        elseif unitId == 'H009' or unitId == 'H023' then
            return 151 // Fire Mage
        elseif unitId == 'H00A' or unitId == 'U001' then
            return 152 // Frost Mage

        // Monk (base 160)
        elseif unitId == 'N041' then
            return 160 // Brewmaster Monk

        // Paladin (base 170)
        elseif unitId == 'H00M' or unitId == 'H031' then
            return 170 // Holy Paladin
        elseif unitId == 'H033' or unitId == 'H032' then
            return 171 // Protection Paladin
        elseif unitId == 'H00K' or unitId == 'H00R' then
            return 172 // Retribution Paladin

        // Priest (base 180)
        elseif unitId == 'H03J' or unitId == 'H03I' then
            return 180 // Discipline Priest
        elseif unitId == 'H02U' or unitId == 'H02W' then
            return 181 // Holy Priest
        elseif unitId == 'H00T' or unitId == 'H00Q' then
            return 182 // Shadow Priest

        // Rogue (base 190)
        elseif unitId == 'E001' or unitId == 'E03W' then
            return 190 // Assassination Rogue
        elseif unitId == 'E01O' or unitId == 'E035' then
            return 191 // Combat Rogue
        elseif unitId == 'E00E' or unitId == 'E007' then
            return 192 // Subtlety Rogue

        // Shaman (base 200)
        elseif unitId == 'O00R' or unitId == 'O006' then
            return 200 // Elemental Shaman
        elseif unitId == 'O00P' or unitId == 'O00J' then
            return 201 // Enhancement Shaman
        elseif unitId == 'O00G' or unitId == 'O00N' then
            return 202 // Restoration Shaman

        // Warlock (base 210)
        elseif unitId == 'E02V' or unitId == 'E000' then
            return 211 // Demonology Warlock
        elseif unitId == 'E04A' or unitId == 'E02Z' then
            return 212 // Destruction Warlock

        // Warrior (base 220)
        elseif unitId == 'H01J' or unitId == 'H028' then
            return 220 // Arms Warrior
        elseif unitId == 'H03D' or unitId == 'H03E' then
            return 221 // Fury Warrior
        elseif unitId == 'H010' or unitId == 'H01T' then
            return 222 // Protection Warrior
        endif

        return 0
    endfunction

    //Need to use U here because of shifting unittypes
    function GetSlotForHero takes unit u returns integer
        // Death Knight (base 110)
        if (u == udg_yA_Blood_DK or u == udg_yH_Blood_DK) then
            return 110
        elseif (u == udg_yA_Frost_DK or u == udg_yH_Frost_DK) then
            return 111
        elseif (u == udg_yA_Unholy_DK or u == udg_yH_Unholy_DK) then
            return 112
    
        // Demon Hunter (base 120)
        elseif (u == udg_yA_Demon_Hunt or u == udg_yH_Demon_Hunt) then
            return 120
        elseif (u == udg_yA_Havoc_DH or u == udg_yH_Havoc_DH) then
            return 121
        elseif (u == udg_yA_Veng_DH or u == udg_yH_Veng_DH) then
            return 122
    
        // Druid (base 130)
        elseif (u == udg_yA_Bal_Druid or u == udg_yH_Bal_Druid) then
            return 130
        elseif (u == udg_yA_Feral_Druid or u == udg_yH_Feral_Druid) then
            return 131
    
        // Hunter (base 140)
        elseif (u == udg_yA_Beast_Hunter or u == udg_yH_Beast_Hunter) then
            return 140
        elseif (u == udg_yA_Dark_Ranger or u == udg_yH_Dark_Ranger) then
            return 141
        elseif (u == udg_yA_Marksman_Hunter or u == udg_yH_Marksman_Hunter) then
            return 142
        elseif (u == udg_yA_Surv_Hunter or u == udg_yH_Surv_Hunter) then
            return 143
    
        // Mage (base 150)
        elseif (u == udg_yA_Arcane_Mage or u == udg_yH_Arcane_Mage) then
            return 150
        elseif (u == udg_yA_Fire_Mage or u == udg_yH_Fire_Mage) then
            return 151
        elseif (u == udg_yA_Frost_Mage or u == udg_yH_Frost_Mage) then
            return 152
    
        // Monk (base 160)
        elseif (u == udg_yA_Brew_Monk or u == udg_yH_Brew_Monk) then
            return 160
        // elseif (u == udg_yA_Mist_Monk or u == udg_yH_Mist_Monk) then
        //     return 161
        // elseif (u == udg_yA_Wind_Monk or u == udg_yH_Wind_Monk) then
        //     return 162
    
        // Paladin (base 170)
        elseif (u == udg_yA_Holy_Pally or u == udg_yH_Holy_Pally) then
            return 170
        elseif (u == udg_yA_Prot_Pally or u == udg_yH_Prot_Pally) then
            return 171
        elseif (u == udg_yA_Ret_Pally or u == udg_yH_Ret_Pally) then
            return 172
    
        // Priest (base 180)
        elseif (u == udg_yA_Disc_Priest or u == udg_yH_Disc_Priest) then
            return 180
        elseif (u == udg_yA_Holy_Priest or u == udg_yH_Holy_Priest) then
            return 181
        elseif (u == udg_yA_Shadow_Priest or u == udg_yH_Shadow_Priest) then
            return 182
    
        // Rogue (base 190)
        elseif (u == udg_yA_Ass_Rogue or u == udg_yH_Ass_Rogue) then
            return 190
        elseif (u == udg_yA_Combat_Rogue or u == udg_yH_Combat_Rogue) then
            return 191
        elseif (u == udg_yA_Subtle_Rogue or u == udg_yH_Subtle_Rogue) then
            return 192
    
        // Shaman (base 200)
        elseif (u == udg_yA_Ele_Sham or u == udg_yH_Ele_Sham) then
            return 200
        elseif (u == udg_yA_Enhance_Shaman or u == udg_yH_Enhance_Shaman) then
            return 201
        elseif (u == udg_yA_Resto_Sham or u == udg_yH_Resto_Sham) then
            return 202
        //Earth Warden
    
        // Warlock (base 210)
        elseif (u == udg_yA_Afflic_Warlock or u == udg_yH_Afflic_Warlock) then
            return 210    
        elseif (u == udg_yA_Demon_Warlock or u == udg_yH_Demon_Warlock) then
            return 211
        elseif (u == udg_yA_Destro_Warlock or u == udg_yH_Destro_Warlock) then
            return 212

        // Warrior (base 220)
        elseif (u == udg_yA_Arms_Warr or u == udg_yH_Arms_Warr) then
            return 220
        elseif (u == udg_yA_Fury_Warr or u == udg_yH_Fury_Warr) then
            return 221
        elseif (u == udg_yA_Prot_Warr or u == udg_yH_Prot_Warr) then
            return 222
        endif
    
        return 0
    endfunction    

    function GetHeroProperNameFromSlot takes integer slot returns string
        // Death Knight (base 110)
        if slot == 110 then
            return "Blood"
        elseif slot == 111 then
            return "Frost"
        elseif slot == 112 then
            return "Unholy"

        // Demon Hunter (base 120)
        elseif slot == 120 then
            return "Havoc"
        elseif slot == 121 then
            return "Vengeance"

        // Druid (base 130)
        elseif slot == 130 then
            return "Balance & Resto"
        elseif slot == 131 then
            return "Feral & Guardian"
        // elseif slot == 132 then
        //     return "Flame & Fang"

        // Hunter (base 140)
        elseif slot == 140 then
            return "Beastmaster"
        elseif slot == 141 then
            return "Dark Ranger"
        elseif slot == 142 then
            return "Marksmanship"
        elseif slot == 143 then
            return "Survival"

        // Mage (base 150)
        elseif slot == 150 then
            return "Arcane"
        elseif slot == 151 then
            return "Fire"
        elseif slot == 152 then
            return "Frost"
        // elseif slot == 153 then
        //     return "Temporal"

        // Monk (base 160)
        elseif slot == 160 then
            return "Brewmaster"
        elseif slot == 161 then
            return "Mistweaver"
        elseif slot == 162 then
            return "Windwalker"

        // Paladin (base 170)
        elseif slot == 170 then
            return "Holy"
        elseif slot == 171 then
            return "Protection"
        elseif slot == 172 then
            return "Retribution"
        // elseif slot == 173 then
        //     return "Vindication" //Shock Paladin

        // Priest (base 180)
        elseif slot == 180 then
            return "Discipline"
        elseif slot == 181 then
            return "Holy"
        elseif slot == 182 then
            return "Shadow"

        // Rogue (base 190)
        elseif slot == 190 then
            return "Assassination"
        elseif slot == 191 then
            return "Combat"
        //Subtle Rogue
        elseif slot == 192 then
            return "Subtlety"

        // Shaman (base 200)
        elseif slot == 200 then
            return "Elemental"
        elseif slot == 201 then
            return "Enhancement"
        elseif slot == 202 then
            return "Restoration"

        // Warlock (base 210)
        elseif slot == 210 then
            return "Affliction"
        elseif slot == 211 then
            return "Demonology"
        elseif slot == 212 then
            return "Destruction"
        // elseif slot == 213 then
        //     return "Hellforged" //Infernal Warlock

        // Warrior (base 220)
        elseif slot == 220 then
            return "Arms"
        elseif slot == 221 then
            return "Fury"
        elseif slot == 222 then
            return "Protection"
        endif

        return ""
    endfunction

endlibrary