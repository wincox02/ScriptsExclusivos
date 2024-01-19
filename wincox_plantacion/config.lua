Config = {}

Config.Ubicacion = {
    label = "Plantaciones Extrañas",
    positions = {
        fuera = vec3(1309.4650, 4384.4043, 42.0555),
        dentro = vec4(530.4784, 1892.4711, 33.4331, 21.7270),
        pc = vector4(539.0592, 1901.8874, 33.1154, 107.8544)
    }
}

Config.preciosplanta = {
    2000,
    4000,
    5000,
    8000,
    12000,
    15000,
    20000,
    25000,
    30000
}

Config.Plantas = {
    'bkr_prop_weed_01_small_01c',
    'bkr_prop_weed_med_01b',
    --'prop_weed_01',
    'bkr_prop_weed_lrg_01a',
    'bkr_prop_weed_lrg_01b'
}

Config.ubicaciones = {
    vector4(526.4042, 1902.5653, 32.4212, -18),
    vector4(529.4125, 1903.4120, 32.4757, -18),
    vector4(532.5001, 1904.3890, 32.5299, -18),
    vector4(527.6863, 1898.5216, 32.4188, -18),
    vector4(530.7054, 1899.4824, 32.4741, -18),
    vector4(533.7398, 1900.4220, 32.5296, -18),
    vector4(528.8231, 1895.1779, 32.4199, -18),
    vector4(531.7980, 1896.0649, 32.4741, -18),
    vector4(534.7926, 1896.7747, 32.5376, -18)
}

Config.Mejoras = { -- xm_prop_tunnel_fan_02                VENTILADOREs -- prop_fountain1    --    prop_sprink_golf_01 (19 - 5) -- prop_sprink_park_01
    ['bidones'] = {
        vector4(523.9575, 1904.2834, 32.7496, 107.9102),
        vector4(532.4595, 1907.2811, 32.9004, 106.6146)
    },
    ['aspersores'] = {
        vector4(523.9575, 1904.2834, 33.8496, 107.9102),
        vector4(532.4595, 1907.2811, 34.0004, 106.6146)
    },
    ['ventiladores'] = { -- xm_prop_tunnel_fan_02
        vector4(531.015564, 1892.31091, 37.10685, 197.43),
        vector4(539.18335, 1894.95837, 36.8285065, 197.21)
    }
}

Config.preciosMejoras = {
    Agua = 300000,
    Crecimiento = 150000
}

Config.velocidadPerdidaAgua = 0.1 -- cada 1 segundos se disminuya esto
Config.penalidadAgua = 0.1 -- cuando se queda sin agua multiplica esto por la velocidadCrecimiento
Config.velocidadCrecimiento = 0.1 -- cada 1 segundos se aumenta esto
Config.boostCrecimiento = 1.2 -- cada vez que se aumenta se multiplica por esto si es que tiene la mejora