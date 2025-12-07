function SetComboGen takes unit u, boolean b returns nothing 
    if u != null then 
        if(u == udg_yA_Subtle_Rogue) then 
            set udg_NEREviscerate = b 
        endif 
        if(u == udg_yH_Subtle_Rogue) then 
            set udg_BEREviscerate = b 
        endif 
        if(u == udg_yA_Combat_Rogue) then 
            set udg_WREviscerate = b 
        endif 
        if(u == udg_yH_Combat_Rogue) then 
            set udg_UREviscerate = b 
        endif 
        if(u == udg_yA_Ass_Rogue) then 
            set udg_HAssEviscerate = b 
        endif 
        if(u == udg_yH_Ass_Rogue) then 
            set udg_AAssEviscerate = b 
        endif 
    endif 
endfunction 

function TurnOffComboGen takes unit u returns nothing 
    call SetComboGen(u, false) 
endfunction 

function TurnOnComboGen takes unit u returns nothing 
    local boolean hasComboAbility = false 
    //Rupture
    if(GetUnitAbilityLevel(u, 'A04P') > 0) then 
        set hasComboAbility = true 
    endif 
    //Eviscerate
    if(GetUnitAbilityLevel(u, 'A017') > 0) then 
        set hasComboAbility = true 
    endif 
    // Gouge
    if(GetUnitAbilityLevel(u, 'A00W') > 0) then 
        set hasComboAbility = true 
    endif 
    //Slice and Dice (WR)
    if(GetUnitAbilityLevel(u, 'A0SD') > 0) then 
        set hasComboAbility = true 
    endif 
    // Slice and Dice (UD)
    if(GetUnitAbilityLevel(u, 'A09V') > 0) then 
        set hasComboAbility = true 
    endif 
    if hasComboAbility then 
        call SetComboGen(u, true) 
    endif 
endfunction 