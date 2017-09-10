#charset "us-ascii"
#include <adv3.h>
#include <lookup.h>

class TermiteMound : POI, Fixture, PathPassage
{
    name = 'termite mound'
    vocabWords = 'termite mound/cave/entrance'
    desc()
    {
        "TODO";
    }
    specialDesc()
    {
        "A rather large, mound of mostly hard dirt is here. It is large enough, that there is an entrance which you could walk in to get inside
        should you so desire.";
    }

    POIevent(room)
    {
        local p = new TermiteMound();
        p.moveInto(room);
        TermiteMoundEntrance.out = room;
    }    
    destination = TermiteMoundEntrance;
}


//mound manager
TermiteMoundManager : object
{
    map = nil
    baseYOffset = 0 
    population = 2
    
    queenCount = 1
    kingCount = 1
    soldierCount = 0
    workerCount = 0
    nymphCount = 0
    eggCount = 0
    
    HiveStatus()
    {
        "<u><b>Termite hive status</b></u><br>
        <br>
        <u>Total Inhabitants (<<population>>)</u><br>
        Queens : <<queenCount>><br>
        Kings : <<kingCount>><br>
        Soldiers : <<soldierCount>><br>
        Workers : <<workerCount>><br>
        Nymphs : <<nymphCount>><br>
        Eggs : <<eggCount>><br>
        <br>
        <u><b>Structure</b></u>";
        
        local roomCount = new LookupTable();
        foreach (local room in TermiteMoundManager.map)
        {
            local roomType = room.name;
            if (roomCount.isKeyPresent(roomType))
            {
                roomCount[roomType] += 1;
            }
            else
            {
                roomCount[roomType] = 1;
            }
        }
        
        foreach (local key in roomCount.keysToList())
        {
            "<br><<key>> : <<roomCount[key]>>";
        }
        "<br><br>";
    }    
    
    BuildTermiteMound()
    {
        map = new LookupTable();
        
        //create the entrance tunnel in the south. Lets put the chords on 0,0,0
        
        local X = 0;
        local Y = 0;
        local Z = 0;
        
        TermiteMoundEntrance.Z = Z;
        TermiteMoundEntrance.Y = Y;
        TermiteMoundEntrance.X = X;        
        local key = '' + Z + ',' + Y + ',' + X;
        map[key] = TermiteMoundEntrance;
        
        //build our tunnel 3 in and down
        local prevRoom = nil;
        local dir = 0;
        for (local i=1; i<=3; i++)
        {
            prevRoom = map[key];
            if (dir == 1)
            {   
                Y += 1;
                dir = 0;
            }
            else
            {
                Z -= 1;
                dir = 1;
            }
            DigTunnel(prevRoom,[Z,Y,X]);
            key = '' + Z + ',' + Y + ',' + X;
        }
        
        //one north
        prevRoom = map[key];
        Y += 1;
        local tunnel = DigTunnel(prevRoom,[Z,Y,X]);
        
        //and then the centre of the mound. The queens chamber
        Y += 1;
        TermiteQueenChamber.Z = Z;
        TermiteQueenChamber.Y = Y;
        TermiteQueenChamber.X = X;
        
        key = '' + Z + ',' + Y + ',' + X;
        
        ConnectRooms(tunnel, TermiteQueenChamber);
        ConnectRooms(TermiteQueenChamber, tunnel);
        map[key] = TermiteQueenChamber;
        
        
        
    }
    
    DigTunnel(source, newPos)
    {        
        local tunnel = new TermiteMoundTunnel();
        tunnel.Z = newPos[1];
        tunnel.Y = newPos[2];
        tunnel.X = newPos[3];
        
        ConnectRooms(source, tunnel);
        ConnectRooms(tunnel, source);
        
        local key = '' + newPos[1] + ',' + newPos[2] + ',' + newPos[3];
        map[key] = tunnel;
        
        return tunnel;  
    }
}

TermiteMoundEntrance : Room
{
    name = 'Entrance'
    desc()
    {
        "You are standing within the entrance to a large network of caves.";
    }
    hasBuilt = nil;
    enteringRoom (traveller)
    {
        if (!hasBuilt)
        {
            TermiteMoundManager.BuildTermiteMound();
            hasBuilt = true;
        }
        inherited(traveller);
    }
    beforeTravel(traveler, connector)
    {
    
        if (TermiteQueenTFStatus.Has(Player) && connector.ofKind(OutdoorRoom))
        {
            //check the time
            if (DateTime._hour >= 19 || DateTime._hour <= 5)
            {
                return inherited(traveler, connector);
            }
            else
            {
                if (TermiteQueenTFStatus.state >= 3)
                {
                    failCheck('Leaving the mound during the day while the sun is out is too dangerous. You will burn alive!');
                }
                if (Player.canSee(TermiteKing))
                {
                    failCheck('You start to head out of the termite mound, but the termite king grabs onto your leg. Large emotions of fear and danger of
                    buring from the sun flood your mind. You will not be able to leave during the day while the king is with you.');
                }
            }
        }
    
        return inherited(traveler, connector);
    }
}

class TermiteMoundTunnel : Room
{
    name = 'Tunnel'
    
    GetValidCrafts(crafter)
    {
        if (TermiteQueenTFStatus.Has(crafter))
        {
            return [['Dig a new tunnel',CraftTermiteTunnelHook]];
        }
        return inherited(crafter);
    }
}

CraftTermiteTunnelHook : Hook
{
    event()
    {
        //check the player's location for open areas
        local l = Player.location;
        local map = TermiteMoundManager.map;
        local key = '';
        
        //find valid directions for a new tunnel
        
        local newValidTunnels = [];
        
        for(local z = -1; z <= 1; z++)
        {
            key = '' + (l.Z + z) + ',' + l.Y + ',' + l.X;
            
            if (z == 0)
            {
                //look at all rooms around (TODO)
            }
            else
            {                
                local nextRoom = map[key];
                if (!(nextRoom != nil && IsConnected(l,nextRoom)))
                {
                    if (z == -1) //down
                    {
                        newValidTunnels += [['Dig tunnel down', CraftTermiteTunnelDownHook]];
                    }
                    else //up
                    {
                        newValidTunnels += [['Dig tunnel up', FalseHook]];
                    }
                }
            }
        }
        if (newValidTunnels.length == 0)
        {
            "There isn't any room for a new tunnel from here.";
        }
        else
        {
            newValidTunnels += [['Cancel', FalseHook]];
            "<br>In which direction to you want to dig the tunnel?";
            PresentChoice(newValidTunnels);
            "<br>";
        }
    }
}

CraftTermiteTunnelDownHook : Hook
{
    event()
    {
        //TODO : Check for existing project and continue from there.
        local l = Player.location;
        local tunnelProject = new CraftableTermiteTunnel();
        local key = '' + (l.Z -1 ) + ',' + l.Y + ',' + l.X;
        TermiteMoundManager.map[key] = tunnelProject;
        tunnelProject.direction = 'down';
        tunnelProject.moveInto(l);
        
        //TODO : Check for king. He should also get a roll to assist if following the player.
        //local roll = Player.TermiteCraftingCheck(tunnelProject.difficulty);
        //tunnelProject.Craft(roll,true);
        
        //TermiteMoundManager.DigTunnel(l,[l.Z-1,l.Y,l.X]);
    }
}

class CraftableTermiteTunnel : craftable
{
    name = '<<direction>> tunnel'
    
    direction = ''
    
    difficulty = 1
    requiredSuccesses = 25
    
    
}

TermiteQueenChamber : Room
{
    known = nil
    name()
    {
        if (known)
        {
            return 'Royal chamber';
        }
        else
        {
            return 'Large open chamber';
        }
    }
    desc()
    {
        if (known)
        {
            "You are in the heart of the termite hive, the royal chamber. Here is where a termite king and queen would spend most, if not all of their time, 
            procuding future generations.";
        }
        else
        {
            "You find yourself in a large, open chamber within this cave. You have a feeling that in the past, this room used to be full of life. What it's purpose
            used to be, however, is not clear.";
        }
        
    }    
}

