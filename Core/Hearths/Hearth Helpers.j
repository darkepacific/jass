function GetHearthStringFromNumber takes integer locationNumber, player p returns string
    // Horde Locations
    if (IsPlayerInForce(p, udg_HordePlayers)) then
        if locationNumber == 100 then
            return "The Undercity"
        elseif locationNumber == 200 then
            return "Silvermoon"
        elseif locationNumber == 800 then
            return "Deathknell"
        elseif locationNumber == 900 then
            return "Sunstrider Isle"
        elseif locationNumber == 0 then
            return "Brill"
        elseif locationNumber == 1 then
            return "Farstrider Retreat"
        elseif locationNumber == 2 then
            return "Fairbreeze Village"
        elseif locationNumber == 3 then
            return "Dawnseeker Promonotory"
        elseif locationNumber == 4 then
            return "The Sepulcher"
        elseif locationNumber == 5 then
            return "Revantusk Village"
        elseif locationNumber == 6 then
            return "Tarren Mill"
        elseif locationNumber == 7 then
            return "The Bulwark"
        elseif locationNumber == 10 then
            return "Warchief's Cove"
        elseif locationNumber == 11 then
            return "Vengance Landing"
        elseif locationNumber == 16 then
            return "Tranquillien"
        elseif locationNumber == 17 then
            return "The Forsaken Front"
        elseif locationNumber == 19 then
            return "Dragonmaw Port"
        elseif locationNumber == 20 then
            return "Bloodgulch"
        endif
    // Alliance Locations
    elseif (IsPlayerInForce(p, udg_AlliancePlayers)) then
        if locationNumber == 100 then
            return "Stromgarde"
        elseif locationNumber == 200 then
            return "Ironforge"
        elseif locationNumber == 800 then
            return "Refuge Pointe"
        elseif locationNumber == 900 then
            return "Anvilmar"
        elseif locationNumber == 0 then
            return "Greenwarden's Grove"
        elseif locationNumber == 1 then
            return "Dabyrie's Farmstead"
        elseif locationNumber == 2 then
            return "Dun Algaz"
        elseif locationNumber == 3 then
            return "Faldir's Cove"
        elseif locationNumber == 4 then
            return "Aerie Peak"
        elseif locationNumber == 5 then
            return "Stormfeather Outpost"
        elseif locationNumber == 6 then
            return "Southshore"
        elseif locationNumber == 7 then
            return "Chillwind Camp"
        elseif locationNumber == 10 then
            return "Admiral's Point"
        elseif locationNumber == 11 then
            return "Westguard Keep"
        elseif locationNumber == 16 then
            return "Thundermar"
        elseif locationNumber == 17 then
            return "Thelsamar"
        elseif locationNumber == 18 then
            return "Kharanos"
        elseif locationNumber == 19 then
            return "Highbank"
        elseif locationNumber == 20 then
            return "Thundermar"
        endif
    endif
    // Neutral Locations
    if locationNumber == 8 then
        return "Hearthglen"
    elseif locationNumber == 9 then
        return "Light's Hope"
    elseif locationNumber == 12 then
        return "The Mender's Stead"
    elseif locationNumber == 13 then
        return "Kamagua Village"
    elseif locationNumber == 14 then
        return "Dalaran"
    elseif locationNumber == 15 then
        return "Gilneas City"
    endif
    
    // Return an empty string if no match is found
    return ""
endfunction
