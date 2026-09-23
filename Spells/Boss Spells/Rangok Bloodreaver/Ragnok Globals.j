globals
    //===========================================================================
    // RAGNOK - FEL ORBS STATE
    //===========================================================================

    trigger RFO_Periodic = null
    timer RFO_CooldownTimer = null

    unit RFO_Caster = null

    effect RFO_Orb1 = null
    effect RFO_Orb2 = null
    effect RFO_Orb3 = null

    group RFO_Group = null

    real RFO_Angle = 0.00

    integer RFO_Tick = 0
    integer RFO_DamageTick = 0


    //===========================================================================
    // RAGNOK - FEL BURST STATE
    //===========================================================================

    trigger RFB_Periodic = null
    timer RFB_CooldownTimer = null

    unit RFB_Caster = null

    effect RFB_ChargeEffect = null

    group RFB_Group = null
    group RFB_TrailHit = null

    real RFB_Angle = 0.00

    integer RFB_Step = 0
endglobals