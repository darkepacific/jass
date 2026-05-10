
function WraithWalkSilence takes unit u returns nothing
    local integer abl

    set abl = 'A03L'    //Path of Death
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A0DG'    //Gargoyle
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A03Y'    //Death and Decay
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A0FB'    //Death's Grasp
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A001'    //Death Coil
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A0F4'    //Carrion Swarm
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A03M'    //DeathPact
    call SpellAddTonsOfMana(abl, u)
    set abl = 'AUan'    //Animate Dead
    call SpellAddTonsOfMana(abl, u)
    set abl = 'A03J'    //Plague Bringer
    call SpellAddTonsOfMana(abl, u)
endfunction

function WraithWalkRemoveSilence takes unit u returns nothing
    local integer abl

    set abl = 'A03L'    //Path of Death
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A0DG'    //Gargoyle
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A03Y'    //Death and Decay
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A0FB'    //Death's Grasp
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A001'    //Death Coil
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A0F4'    //Carrion Swarm
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A03M'    //DeathPact
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'AUan'    //Animate Dead
    call SpellRemoveTonsOfMana(abl, u)
    set abl = 'A03J'    //Plague Bringer
    call SpellRemoveTonsOfMana(abl, u)
endfunction


