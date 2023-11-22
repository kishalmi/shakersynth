huey:
    cockpit doors: 38
    left gunner door: 43
    right gunner door: 44

hip:
    cockpit doors: 38
    cargo doors: 86
    -- from mi-8mtv2/cockpit/scripts/devices_specs/cpt_mech.lua
    LeftDoorArg					= 38
    CargoDoorArg					= 86
    leftBlisterArg				  = 133
    rightBlisterArg				  = 131

u = Unit.getByName("UH1 hot beans")
v = u:getDrawArgumentValue(38)
if val > 0.1 then val = 1; end -- UH1 doors only open to 0.89

mp = GetDevice(0)
mp:get_argument_value(420) -- left cockpit door
mp:get_argument_value(422) -- right cockpit door
