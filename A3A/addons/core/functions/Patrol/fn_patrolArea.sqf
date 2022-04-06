/*
    Author: [Hazey]
    Description:
		Group Patrol Area

    Arguments:
        <Group> Group you want to run a Patrol Area.
        <Bool> Should group search buildings?
        <Number> Max Distance the unit should venture before returning home.
        <Number> Minimum Radius from Center to Patrol.
        <Number> Maximum Radius from Center to Patrol.
        <Number> Distance from nearest object to create waypoint.
        <Number> 0 - No Water, 1 - land & water, 2 - water only
        <Number> Max Gradient to create waypoint on. Used to avoid super hilly maps.
        <Number> Should be on the shore or not.

    Return Value:
    	N/A

    Scope: Any
    Environment: Any
    Public: No

    Example: 
		[_group] call A3A_fnc_patrolArea;

    License: MIT License
*/
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params [
    "_group", 
    ["_maxPatrolDistance", 200], 
    ["_minimumRadius", 50], 
    ["_patrolRadius", 0], 
    ["_objectDistance", 0], 
    ["_waterMode", 0], 
    ["_maxGradient", -1], 
    ["_shoreMode", 0]
];

// Get home position of the unit.
private _groupHomePosition = _group getVariable "PATCOM_Patrol_Home_Position";

// If this group is a Garrison patrol, we want them to stick close.
if (_group getVariable "PATCOM_Garrison_Patrol" == true) then {
    _maxPatrolDistance = _group getVariable "PATCOM_Garrison_Patrol_Distance";
};

// Add a default patrol radius if we don't have one already specified.
if (_group getVariable ["PATCOM_Patrol_Radius", 0] == 0) then {
	_group setVariable ["PATCOM_Patrol_Radius", 100 + random 150];
};

// If no patrol radius is specified in the param, use default patrol radius for the unit.
if (_patrolRadius == 0) then {
	_patrolRadius = _group getVariable "PATCOM_Patrol_Radius";
};

// This is the only place we handle civilians in this Commander.
if ((side leader _group) == civilian) then {
    [_group, "CARELESS", "NORMAL", "LINE", "BLUE", "AUTO"] call A3A_fnc_patrolSetCombatModes;
} else {
    [_group, "SAFE", "LIMITED", "COLUMN", "RED", "AUTO"] call A3A_fnc_patrolSetCombatModes;
};

// Check for current waypoints and make sure they are type MOVE for patrol
if (currentWaypoint _group == count waypoints _group || waypointType [_group, currentWaypoint _group] != "MOVE") then {
    private _searchBuildings = _group getVariable ["PATCOM_Search_Buildings", false];
    if (_searchBuildings) then {

        // Percentage chance on searching a nearby building.
        if (10 > random 100) exitWith {
            [_group] call A3A_fnc_patrolSearchBuilding;
        };
    };

    if ((leader _group) distance _groupHomePosition > _maxPatrolDistance) exitWith {
        // Return Home
        [_group, "MOVE", "PATCOM_PATROL_AREA", _groupHomePosition, -1, 50] call A3A_fnc_patrolCreateWaypoint;
    }; 
    
    // | Center Position | Min Radius | Max Radius | Min Object Distance | Water Mode | Max Gradient | ShoreMode |
    private _nextWaypointPos = [getPos (leader _group), _minimumRadius, _patrolRadius, _objectDistance, _waterMode, _maxGradient, _shoreMode] call A3A_fnc_getSafeSpawnPos;
    [_group, "MOVE", "PATCOM_PATROL_AREA", _nextWaypointPos, -1, 50] call A3A_fnc_patrolCreateWaypoint;
};