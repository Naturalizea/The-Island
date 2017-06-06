#charset "us-ascii"
#include <adv3.h>
#include <lookup.h>

/* The island map framwork. Generation will take an array of locations, create and link the rooms, and fill in random POI's to ensure some form of randomness
in the game. */

MapGenerator : object
{ 
    /* The static map. */
    Map = [
    ['W','W','W','W','W','W','W','W','W','W','W'],
    ['W','W','W','w','w','w','w','w','W','W','W'],
    ['W','W','w','w','b','b','b','w','w','W','W'],
    ['W','w','w','b','b','g','b','b','w','w','W'],
    ['W','w','b','b','g','g','g','b','b','w','W'],
    ['W','w','b','g','g','f','g','g','b','w','W'],
    ['W','w','b','b','g','g','g','b','b','w','W'],
    ['W','w','w','b','b','g','b','b','w','w','W'],
    ['W','W','w','w','b','b','b','w','w','W','W'],
    ['W','W','W','w','w','w','w','w','W','W','W'],
    ['W','W','W','W','W','W','W','W','W','W','W']
    ]
    
    /* The point of interest map  */
    POIMap = [
    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    [' ',' ',' ',' ','*','*','*',' ',' ',' ',' '],
    [' ',' ',' ','*','*',' ','*','*',' ',' ',' '],
    [' ',' ','*','*',' ',' ',' ','*','*',' ',' '],
    [' ',' ','*',' ',' ','T',' ',' ','*',' ',' '],
    [' ',' ','*','*',' ',' ',' ','*','*',' ',' '],
    [' ',' ',' ','*','*',' ','*','*',' ',' ',' '],
    [' ',' ',' ',' ','*','*','*',' ',' ',' ',' '],
    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],
    [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']
    ]
    
    /* Build the map */
    Construct()
    {
        /* Table of aliases for the map parts. */
        local MapPartAlias = new LookupTable([
            'b', {: new BeachMap()},
            'g', {: new GrassyPlainsMap()},
            'w', {: new ShallowWaterMap()},
            'W', {: new DeepWaterMap()},
            'f', {: new ForestMap()}
            ]);
        
        /* Table of aliases for map POI's */
        local POIAlias = new LookupTable([
            '*',PlayerSpawn,
            'T',TermiteMound
            ]);
    
        local mapTable = new LookupTable();
        local poiTable = new LookupTable();
    
        //for future use
        local currentZ = 1;
        
        local currentY = 0;
        //check each row
        foreach (local mapY in Map)
        {
            currentY++;
            local currentX = 0;
            //check each column
            foreach(local mapLoc in mapY)
            {
                currentX++;
                
                //create the room
                local newRoom = MapPartAlias[mapLoc]();
                newRoom.X = currentX;
                newRoom.Y = currentY;
                newRoom.Z = currentZ;
                
                //add to the map
                local mapKey = '' + currentZ + ',' + currentY + ',' + currentX;
                mapTable[mapKey] = newRoom;
                
            }
        }
        
        currentY = 0;
        //check each row for POI
        foreach (local mapY in POIMap)
        {
            currentY++;
            local currentX = 0;
            //check each column
            foreach(local mapLoc in mapY)
            {
                currentX++;
                
                //create the POI
                local newPOI = POIAlias[mapLoc];
                
                //add to the POI table
                local POIKEY = '' + currentZ + ',' + currentY + ',' + currentX;
                poiTable[POIKEY] = newPOI;
                
            }
        }
        
        //now loop through each map and link them all
        foreach (local roomKey in mapTable.keysToList())
        { 
            local room = mapTable[roomKey];
            //check the surrounding rooms and link them
            for (local x = room.X - 1 ;x <= room.X + 1; x++)
            {
                for (local y = room.Y - 1 ;y <= room.Y + 1; y++)
                {
                    local linkedKey = '' + currentZ + ',' + y + ',' + x;
                    local linkedRoom = mapTable[linkedKey];
                    if (linkedRoom != nil && linkedRoom  != room && linkedRoom.CanBeLinked)
                    {
                        ConnectRooms(room, linkedRoom);
                    }
                    
                }
            }
            
            //Also add any of our POI's
            local POI = poiTable[roomKey];
            if (POI != nil)
            {
                POI.POIevent(room);
            }
        }
    }

}


/* For defining map position */
modify BasicLocation
{
    X = nil
    Y = nil
    Z = nil
    CanBeLinked = true
}


/* Open grassy plains */
class OverworldRoom : OutdoorRoom
{
    desc()
    {
        "You are currently in an area of <<self.name>>.";
        directionDesc();
    }
    farDesc()
    {
        " you can see <<self.name>>.";
    }
    
    directionDesc()
    {   
        //loop through all our rooms and get distinct directions
        local rooms = new LookupTable();
        foreach (local dir in Direction.allDirections)
        {
            local room = self.getTravelConnector(dir, Player);
            if (room.name != '')
            {
                if (rooms[room.getSuperclassList()[1]] == nil)
                {
                    rooms[room.getSuperclassList()[1]] = [];
                }
                rooms[room.getSuperclassList()[1]] += dir;
            }
        }
        "<br>";
        foreach (local roomType in rooms.keysToList())
        {
            "<br>To the ";
            local x = 1;
            foreach (local dir in rooms[roomType])
            {
                if (x == 1)
                {
                    "<<dir.name>>";
                }
                else if (x != rooms[roomType].length())
                {
                    ", <<dir.name>>";
                }
                else
                {
                    " and <<dir.name>>";
                }
                x++;
            }
            roomType.farDesc();
        }
    }
    travelerLeaving (traveler, dest, connector)
    {
        if (traveler == Player)
        {
            local minutesToTravel = traveler.OverlandTravelTime();
            traveler.FatigueRate = traveler.FatigueRate + 0.0200;            
            Player.AdvanceTime(minutesToTravel);
            traveler.FatigueRate = traveler.FatigueRate - 0.0200;    
        }            
        
        inherited(traveler, dest, connector);
    }
    
}

class GrassyPlainsMap : OverworldRoom
{
    name = 'grassy plains'
}

class ShallowWaterMap : OverworldRoom
{
    name = 'shallow water'
}

class DeepWaterMap : OverworldRoom
{
    name = 'deep water'
}

class BeachMap : OverworldRoom
{
    name = 'beach'
}

class ForestMap : OverworldRoom
{
    name = 'forest'
    
    Gather()
    {
        GatheringStatus.Add(Player);
        local minutesToGather = Player.OverlandTravelTime()*3;
        local success = Player.AdvanceTime(minutesToGather);

        GatheringStatus.Remove(Player);
        if (success)
        {
            "You spend about <<spellInt(toInteger(minutesToGather))>> minutes looking for food. ";
            local results = Player.SurvivalCheck(12);
            if (results)
            {
                "You find an apple.";
                local apple = new Apple();
                apple.moveInto(Player);
            }
            else
            {
                "You don't manage to find anything.";
            }
        }
        
    }
}

/* Some food for now. Need to move this somewhere else and make something better */
class Apple : Food
{
    name = 'apple'
    vocabWords = 'apple*apples'
    isEquivalent = true
    Nutrition = 5
}

/* POIs */
class POI : object
{
    POIevent(room)
    {
        //nothing by default
    }
}

class PlayerSpawn : POI, Fixture
{
    POIevent(room)
    {
        local p = new PlayerSpawn();
        p.moveInto(room);
    }
    
}

//some functions
    
/* Used to connect 2 rooms together */
    
ConnectRooms(room1,room2)
{
    //determine where we are in relation to eachother
    local x = room2.X - room1.X;
    local y = room2.Y - room1.Y;
    local z = room2.Z - room1.Z;
    
    //create the link (one way)
    if (z == 1) //up
    {
        room1.up = room2;
        //room2.down = room1;
    }
    else if (z == -1) //down
    {
        room1.down = room2;
        //room2.up = room1;        
    }
    else
    {
        if (y == -1) //south
        {
            if (x == 1) //east
            {
                room1.southeast = room2;
                //room2.southwest = room1;
            }
            else if (x == -1) //west
            {
                room1.southwest = room2;
                //room2.southeast = room1;
            }
            else
            {
                room1.south = room2;
                //room2.south = room1;
            }
        }
        else if (y == 1) // north
        {
            if (x == 1) //east
            {
                room1.northeast = room2;
                //room2.northeast = room1;
            }
            else if (x == -1) //west
            {
                room1.northwest = room2;  
                //room2.northwest = room1;
            }
            else
            {
                room1.north = room2;
                //room2.north = room1;
            }
        }
        else if (x == 1) //east
        {
            room1.east = room2;
            //room2.west = room1;
        }
        else //west
        {
            room1.west = room2;
            //room2.east = room1;            
        }
        
    }
    //should be done!
}