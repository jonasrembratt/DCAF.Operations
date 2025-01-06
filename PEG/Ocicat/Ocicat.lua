-- //////////////////////////////////////////////////////////////////////////////////
--                                     OCICAT
--                                     *****
-------------------------------------------------------------------------------------
-- DEPENDENCIES
--   MOOSE
--   DCAF.Core
--   DCAF.CombatAirPatrol

-- ALL CAP
--local capOuter = DCAF.CombatAirPatrol:New("CAP DEFENCE")
                            -- :InitMinimumAttackRatio(1.4)
                            -- :InitMinimumRetreatRatio(1.2)
                            -- :Debug(60)
                            -- :Start(Coalition.Red, "Korat RED CAP", "RED EWR")

-- INNER CAP DEFENCES
local capInner = DCAF.CombatAirPatrol:New("CAP DEFENCE 2")
                            :InitMinimumAttackRatio(0.5)
                            :InitMinimumRetreatRatio(0.8)
                            :Start(Coalition.Red, "RED CAP-2", "RED EWR")

-- OUTER CAP DEFENCES
local capOuter = DCAF.CombatAirPatrol:New("CAP DEFENCE 1")
                            :InitMinimumAttackRatio(1.2)
                            :InitMinimumRetreatRatio(1.1)
                            -- :InitDelouseOptions(capInner)
                            :InitScramAirbase({ AIRBASE.PersianGulf.Jiroft, AIRBASE.PersianGulf.Shiraz_Intl, AIRBASE.PersianGulf.Kerman })
                            :Debug(60)
                            :Start(Coalition.Red, "RED CAP-1", "RED EWR")


Trace("\\\\\\\\\\ Ocicat.lua was loaded //////////")