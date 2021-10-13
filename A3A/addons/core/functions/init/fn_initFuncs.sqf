scriptName "initFuncs.sqf";
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Info("initFuncs started");

[] call compile preprocessFileLineNumbers QPATHTOFOLDER(Scripts\Init_UPSMON.sqf);
[] call compile preprocessFileLineNumbers QPATHTOFOLDER(vcomai\Functions\VCM_Functions\fn_VcomInit.sqf);
boxX call jn_fnc_arsenal_init;

Info("initFuncs completed");
