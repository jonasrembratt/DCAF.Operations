local guard = DCAF.Frequencies:Get("Guard", nil, nil)
FREQ = {
    Top_Dog = DCAF.Frequencies:AddNew("Top Dog", guard.Freq, guard.Mod, "The elusive high-up command"),
    UN_Polaris = DCAF.Frequencies:AddNew("UN/POlaris", 355.25, AM, "Used by units of the UN 'Polaris' base & HQ (Tbilisi)"),
    UN_Orion = DCAF.Frequencies:AddNew("UN/Orion", 356.25, AM, "Used by units of the UN 'Orion' base (Zugdidi)"),
    UN_Horizon = DCAF.Frequencies:AddNew("UN/Horizon ", 357.25, AM, "Used by units of the UN 'Orion' logistical hub (Batumi)"),
    NATO_Center = DCAF.Frequencies:AddNew("NATO Center", 322.30, AM, "Used in some stories to allow traffic between AI aircraft and NFZ 'ATC'"),
    Rostov_Control = DCAF.Frequencies:AddNew("Rostov Control", 322.30, AM, "Used in some stories to allow traffic between AI aircraft and 'ATC'"),
    TbilisiApproach = DCAF.Frequencies:AddNew("Tbilisi Approach", 267.60, AM, "Tbilisi Approach (also controls Vaziani AB)"),
}

