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
        
        //build our tunnel 4 in and down
        local prevRoom = nil;
        local dir = 1;
        for (local i=1; i<=4; i++)
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
            local tunnel = DigTunnel(prevRoom,[Z,Y,X]);
            key = '' + Z + ',' + Y + ',' + X;
            map[key] = tunnel;            
        }
        
        //one north
        prevRoom = map[key];
        Y += 1;
        local tunnel = DigTunnel(prevRoom,[Z,Y,X]);
        key = '' + Z + ',' + Y + ',' + X;
        map[key] = tunnel;
        
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
    
        if (Player.TermiteState != 0 && connector.ofKind(GrassyPlainsMap))
        {
            failCheck('You start to head out of the termite mound, but the termite king grabs onto your leg. Large emotions of fear and danger flood
            your mind, and you get the feeling that you would have to get rid of the king if you want to leave.');
        }
    
        return inherited(traveler, connector);
    }
}

class TermiteMoundTunnel : Room
{
    name = 'Tunnel'
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

