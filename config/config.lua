Config = {}

Config.Framework = 'ESX' -- 'ESX' or 'qbcore'
Config.Target = 'ox_target' -- 'ox_target' or 'qb-target'
Config.Notify = 'ox_lib' -- 'ox_lib' or 'lation_ui'

Config.PoliceJobs = {'police', 'sheriff'}

Config.GeraldSpawnTime = 1800 -- seconds

Config.GeraldHeist = {
    Ped = {
        pedModel = 'a_m_m_og_boss_01',
        pedScenario = 'WORLD_HUMAN_AA_SMOKE',
        pedLocations = {
            vector4(2200.8381, 3318.1379, 46.9135, 299.0043),
            vector4(2039.8220, 3183.4048, 45.2292, 238.7847),
            vector4(892.6471, 3601.4915, 32.8242, 305.8176),
            vector4(255.6274, 3110.4580, 42.5940, 233.0965),
            vector4(-286.3155, 2537.9980, 74.6609, 313.9080),
        }
    },
    Vehicle = {
        vehModel = 'sandking2',
        vehLocations = {
            vector4(706.8346, 3086.1680, 44.1838, 276.0717),
            vector4(2490.2258, 3950.2969, 36.8370, 317.0444),
            vector4(2939.4397, 4591.3521, 49.2371, 309.2852),
            vector4(1980.9387, 4926.0210, 42.8122, 132.5208),
        }
    },
    Delivery = {
        devLocations = {
            vector4(1346.2023, 4371.7764, 44.3438, 87.0609),
            vector4(890.2477, 3652.0837, 32.8239, 167.3605),
            vector4(353.9731, 922.8640, 202.4325, 130.4885),
            vector4(127.1316, -2190.5427, 5.9937, 90.1403),
            vector4(-3245.7324, 990.4392, 12.4851, 89.9859),
        }
    },
    RewardPlayer = {
        {item = 'money', min = 320, max = 600, chance = 70},
        {item = 'weed_bag', min = 1, max = 12, chance = 50},
    },
}

return Config