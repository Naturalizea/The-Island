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
    baseSize = 3
    baseYOffset = 0
    
    
    BuildTermiteMound()
    {
        map = new LookupTable();
        
        //create the entrance tunnel in the south. Lets put the chords on 0,-3,0
        
        local X = 0;
        local Y = -3;
        local Z = 0;
        
        TermiteMoundEntrance.Z = Z;
        TermiteMoundEntrance.Y = Y;
        TermiteMoundEntrance.X = X;        
        local key = '' + Z + ',' + Y + ',' + Z;
        map[key] = TermiteMoundEntrance;
        
        //build our tunnel 3 in
        local prevRoom = nil;
        
        for (local i=1; i<=3; i++)
        {
            prevRoom = map[key];
            Y += 1;
            local tunnel = DigTunnel(prevRoom,[Z,Y,X]);
            key = '' + Z + ',' + Y + ',' + Z;
            map[key] = tunnel;            
        }
        
        //one up
        prevRoom = map[key];
        Z += 1;
        local tunnel = DigTunnel(prevRoom,[Z,Y,X]);
        key = '' + Z + ',' + Y + ',' + Z;
        map[key] = tunnel;
        
        //and then the centre of the mound. The queens chamber
        Z += 1;
        TermiteQueenChamber.Z = Z;
        TermiteQueenChamber.Y = Y;
        TermiteQueenChamber.X = X;
        
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
    
    
//ARCHIVED IN CODE TILL I CAN DECIDE TO KEEP OR NOT    
/*
    BuildTermiteMound()
    {
        map = new LookupTable();
        local currentTunnels = [];
        //entrance room at one of the sides and built upwards like a pyrimid. Do not go further then 1,1,1 - 1,20,20 or 8,[7-13].
        
        local currentZ = 1;
        local currentY = 1;
        local currentX = 1;
        
        //get the entrance location in relation to the mound.
        switch (rand(4))
        {
            case 0:
            {
                currentX = rand(10)+1;
                break;
            }
            case 1:
            {
                currentY = rand(10)+1;
                break;
            }
            case 2:
            {
                currentY = 10;
                currentX = rand(10)+1;
                break;
            }
            case 3:
            {
                currentX = 10;
                currentY = rand(10)+1;
                break;
            }
        }
        
        //add the entrance to the map
        TermiteMoundEntrance.X = currentX;
        TermiteMoundEntrance.Y = currentY;
        TermiteMoundEntrance.Z = currentZ;
        local key = '' + currentZ + ',' + currentY + ',' + currentX;
        map[key] = TermiteMoundEntrance;
        
        //and create one tunnel branched off from the entrance. in a random direction.
        local validLoc = nil;
        
        local newZ = 1;
        local newY = 1;
        local newX = 1;
        
        while (!validLoc)
        {
            newY = currentY + rand(3)-1;
            newX = currentX + rand(3)-1;
            
            validLoc = ((newY != currentY || newX != currentX) && CheckValidLoc(newZ,newY,newX));
        }
        
        currentTunnels += CreateTunnel(map, TermiteMoundEntrance,[newZ, newY, newX]);
        
        local maxZ = 1;
        //now create some tunnels...
        local tunnelsToPlace = 19;
        while (tunnelsToPlace > 0)
        {
        
            //choose a random tunnel from the map to branch off from
            local tunnel = currentTunnels[rand(currentTunnels.length)+1];
            
            newZ = tunnel.Z;
            newY = tunnel.Y;
            newX = tunnel.X;
            //always build up for Z. Never down
            newZ = tunnel.Z + rand(2);
            
            if (newZ == tunnel.Z)
            {
                newY = tunnel.Y + rand(3)-1;
                newX = tunnel.X + rand(3)-1;      
            }
            //check if new location is valid and that we are not ourselves
            if((newZ != tunnel.Z || newY != tunnel.Y || newX != tunnel.X) && CheckValidLoc(newZ,newY,newX))
            {
                //create the new tunnel
                local newTunnel = CreateTunnel(map, tunnel,[newZ, newY, newX]);
                
                if (!newTunnel == nil) //tunnel already exists? Means we may have dug into it and not created anything new.
                {
                    currentTunnels += newTunnel;
                    tunnelsToPlace -= 1;
                    
                    if (newZ > maxZ)
                    {
                        maxZ = newZ;
                    }
                }
            } 
        }
        
        //All the tunnels are done. Now place the special rooms
        
        //Queens chamber. We will try and place this on the highest Z level of the mound that we have possible.
        //So get all the tunnels on the max Z
        local topTunnels = currentTunnels.subset({x: x.Z == maxZ});
        validLoc = nil;
        while (!validLoc)
        {
            local queenTunnel = topTunnels[rand(topTunnels.length)+1];
            
            newZ = queenTunnel.Z;
            newY = queenTunnel.Y;
            newX = queenTunnel.X;
            
            newZ = queenTunnel.Z + rand(2);
            
            if (newZ == queenTunnel.Z)
            {
                newY = queenTunnel.Y + rand(3)-1;
                newX = queenTunnel.X + rand(3)-1;      
            }
            
            key = '' + newZ + ',' + newY + ',' + newX;
            //check if new location is valid and that we are not ourselves
            //also check that the location is not occupied by another tunnel. We can't overlap with this.
            if((newZ != queenTunnel.Z || newY != queenTunnel.Y || newX != queenTunnel.X) && CheckValidLoc(newZ,newY,newX) && map[key] == nil)
            {
                //link up the queen chamber
                TermiteQueenChamber.Z = newZ;
                TermiteQueenChamber.Y = newY;
                TermiteQueenChamber.X = newX;
                ConnectRooms(queenTunnel, TermiteQueenChamber);
                ConnectRooms(TermiteQueenChamber, queenTunnel);
                
                validLoc = true;
               
            }
        }
        
        
    }
    
    CheckValidLoc(z,y,x)
    {
        local Max = 11-z;
        local Min = 0+z;
        
        if (z <= 8 && z >= 1 && y >= Min && y <= Max && x >= Min && x <= Max)
        {
            return true;
        }
        return nil;
    }
    
    CreateTunnel(map, source, newPos)
    {
        local key = '' + newPos[1] + ',' + newPos[2] + ',' + newPos[3];
        
        local tunnel = map[key];
        local madeNew = nil;
        
        if (tunnel == nil)
        {
            madeNew = true;
            tunnel = new TermiteMoundTunnel();
            tunnel.Z = newPos[1];
            tunnel.Y = newPos[2];
            tunnel.X = newPos[3];
        
            map[key] = tunnel;
        }
               
        ConnectRooms(source, tunnel);
        ConnectRooms(tunnel, source);
        
        if (madeNew)
        {
            return tunnel;  
        }
        return nil;
    }
*/    
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

TermiteMoundTunnel : Room
{
    name = 'Tunnel'
}

TermiteQueenChamber : Room
{
    name = 'Large open chamber'
    desc()
    {
        "You find yourself in a large, open chamber within this cave. You have a feeling that in the past, this room used to be full of life. What it's purpose
        used to be, however, is not clear.";
    }

    
    
}