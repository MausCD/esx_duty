-- This is a Modifyed Version from esx_duty. Modifyed by MausCD
-- orginal: https://github.com/qalle-git/esx_duty

Config                            = {}
Config.DrawDistance               = 100.0
--language currently available DE and EN
Config.Locale                     = 'en'

local defaultsize = { x = 0.5, y = 0.5, z = 0.5 }
local defaulttype = 21

Config.Zones = {
  {
    Positions = {
      {x = 448.3 , y = -985.0 , z = 30.7}, -- Add here coords where you can go on/off duty
    },
    Out = 'offpolice', -- Add here the Off Duty Job name
    In = 'police', -- Add here the On Duty Job name
    Size  = defaultsize, -- You can change the size of the marker here when you want custom for this Job
    Type  = defaulttype,-- You can change the type of the marker here when you want custom for this Job
  },

  {
    Positions = {
      { x = 449.0 , y = -987.3 , z = 30.7 },
    },
    Out = 'offambulance',
    In = 'ambulance',
    Size  = defaultsize,
    Type = defaulttype,
  },
}