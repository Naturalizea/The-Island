#charset "us-ascii"
#include <adv3.h>
#include <lookup.h>

/* The island map framwork. Generation will take an array of locations, create and link the rooms, and fill in random POI's to ensure some form of randomness
in the game. */

MapGenerator : object
{ 
    /* The static map. */
    Map = [
    ['g','g','g'],
    ['g','g','g'],
    ['g','g','g']
    ]
    
    /* The point of interest map  */
    POIMap = [
    ['*','*','*'],
    ['*','*','*'],
    ['*','*','*']
    ]
    
    /* Build the map */
    Construct()
    {
        /* Table of aliases for the map parts. */
        local MapPartAlias = new LookupTable([
            'g', {: new GrassyPlainsMap()}
            ]);
        
        /* Table of aliases for map POI's */
        local POIAlias = new LookupTable([
            '*',PlayerSpawn
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
            if (y == -1) //north
            {
                if (x == 1) //east
                {
                    room1.northeast = room2;
                    //room2.southwest = room1;
                }
                else if (x == -1) //west
                {
                    room1.northwest = room2;
                    //room2.southeast = room1;
                }
                else
                {
                    room1.north = room2;
                    //room2.south = room1;
                }
            }
            else if (y == 1) // south
            {
                if (x == 1) //east
                {
                    room1.southwest = room2;
                    //room2.northeast = room1;
                }
                else if (x == -1) //west
                {
                    room1.southeast = room2;  
                    //room2.northwest = room1;
                }
                else
                {
                    room1.south = room2;
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
class GrassyPlainsMap : OutdoorRoom
{
    name = 'Grassy plains'
}


/* POIs */
class POI : Fixture
{
    POIevent(room)
    {
        //nothing by default
    }
}

class PlayerSpawn : POI
{
    POIevent(room)
    {
        local p = new PlayerSpawn();
        p.moveInto(room);
    }
    
}