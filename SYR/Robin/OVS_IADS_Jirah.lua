local debug = false
local zone = ZONE_POLYGON:New("ZN Regiment Jirah", getGroup("Robin ZN IADS"))
DCAF.GBAD.Regiment:New("IADS Jirah", Coalition.Red, zone, "Robin Logistics-2", DCAF.GBAD.RegimentMode.Static, "Robin SA-", "Robin AAA")
                  :InitSNSZonesPrefix("Robin ZN RND")
                  :Debug(debug)
                  :Start()