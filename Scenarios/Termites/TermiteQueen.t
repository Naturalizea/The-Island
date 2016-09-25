#charset "us-ascii"
#include <adv3.h>
#include <lookup.h>
#include <bignum.h>

//To being the TF, we need some food to trigger it.
class TermiteJelly : Food
{
    name = 'yellow royal jelly'
    vocabWords = 'yellow royal jelly/food'
    desc()
    {
        "This appears to be some form of yellow jelly.";
    }
    dobjFor(Eat)
    {
        preCond = []
        action()
        {
            if (Player.TermiteState == 0)
            {
            
                local eatAll = nil;
                "You eat some of the jelly. It is sweet, and very, very tasty.";
                local willCheck = Player.DoCheck('Will', Player.WillBonus, 10);
                if (willCheck)
                {
                    "Do you want to eat it all? ";
                    local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
                    "<br><br>";
                    if (accept)
                    {
                        eatAll = true;
                    }                
                }
                else
                {
                    eatAll = true;
                }
                if (eatAll)
                {
                    "You find yourself unable to resist the taste, and you devour the entire yellow mound of sweet jelly. Soon afterwards, fatigue takes over, and
                    you can't help but fall asleep within the large chamber...";
                    inputManager.pauseForMore(true);
                    DateTime.AdvanceTime(1440); //24 hours pass
                    clearScreen();
                    
                    "You awaken sometime later, feeling very relaxed and refereshed, however with an odd headache and a sore butt. Your clothing also seems to be
                    missing. Looking around, you are greeted with a terrifying sight. A giant termite is standing a few feet away from you, about the size of an 
                    average human, seeming watching you with twitching antennae. Around you, you also notice several other smaller termites, about half the size 
                    of the other size of large one.<br>
                    <br>
                    You start to back away from them, and you movement seems to cause the termites to become more active themselves. The smaller ones circle
                    around you, preventing you from escaping, while the large one approaches. His antennae twitch, and your headache intensifies. Reaching a hand up
                    to your head, you also start to feel something strange... Two long protruding and flexable sticks of some kind, and they are growing out from
                    your head, right above your eyes.<br>
                    <br>
                    Your headache throbs again as the large termite gets closer, and you are suddenly filled with various thoughts and emotions. They don't make
                    much sense to you at first, but then they begin to get focused. You somehow get a feeling of happiness and an idea that the future is secured.
                    You then understand that what you are feeling is coming from the large termite, who you now recognise as the king, and he is communicating with
                    you in this strange way. You are still, however, confused at this situation you find yourself in.<br>
                    <br>
                    As if sensing your own emotions, you get projected other feelings. Feelings of reassurance, and of family. The termite kings gets closer, and
                    his antennae touch your own, causing a flood of images to flow into your mind. You see a large termite kingdom with thousands, no... millions of
                    termites, all working in unison to survive and prosper. You then see death of the termite queen, and the gradual decrease in population. An
                    emotion of sadness hits you as the vision shifts to that of only a handful of termites left, led by the king.<br>
                    <br>
                    The visions end as the king steps again, and emotions of rebuilding the kingdom enter your mind, and of immense love for you. Feelings of
                    belonging enter your mind, and you understand. The termites have been waiting for a new queen, and you have been chosen for the position.<br>
                    <br>
                    Do you want to become the new queen?";
                    local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
                    
                    if (accept)
                    {
                        "<br><br>The termites all seem to be extreamly happy. The small ones start to approch you closer and start to climb over you, forcing you
                        to lie on the ground as they get accustomed to their new queen. One of them crawls over to your face, a glob of that royal jelly in it's
                        mandabile, and attempts to feed it to you.";
                        willCheck = Player.DoCheck('Will', Player.WillBonus, 10);
                        if (willCheck)
                        {
                            "Do you want to eat it? ";
                            local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
                            "<br><br>";
                            if (accept)
                            {
                                "Unable to resist, you open your mouth and swallow the sweet jelly. It tastes better then it did before!<br>
                                <br>";
                                Player.TermiteMutationLevel += 5;
                            }
                            else
                            {
                                "TODO : Decline food";
                            }
                        }
                        else
                        {
                            "Unable to resist, you open your mouth and swallow the sweet jelly. It tastes better then it did before!<br>
                            <br>";
                            Player.TermiteMutationLevel += 5;
                        }
                        
                        "A few minutes later, they all get off you, and feelings of purpose start to fill your mind, and feelings of hunger and sating that 
                        hunger filling your mind. From the king, feelings of protection and home fill your mind, as well as preperation. You are not entirely 
                        certian on the preperation thoughts, but you have a feeling that the king does not want you to leave the mound, after waiting for you 
                        to come for so long.";
                    }
                    else
                    {
                        "TODO : REJECTION PATH. FIGHT WITH TERMITES ENSURE.";
                    }
                    
                    TermiteKing.moveIntoForTravel(TermiteQueenChamber);
                    
                    local bp = new TermiteAntennae();
                    bp.moveInto(Player);
                    bp.owner = Player;
                    Player.BodypartTable['TermiteAntennae'] = bp;
                    
                    bp = new TermiteHead1();
                    bp.moveInto(Player);
                    bp.owner = Player;
                    Player.BodypartTable['TermiteHead1'] = bp;
                    
                    bp = Player.BodypartTable['HumanHead'];
                    bp.moveInto(nil);
                    Player.BodypartTable['HumanHead'] = nil;
                    
                    bp = new TermiteArms1();
                    bp.moveInto(Player);
                    bp.owner = Player;
                    Player.BodypartTable['TermiteArms1'] = bp;
                    
                    bp = new TermiteAbdomin1();
                    bp.moveInto(Player);
                    bp.owner = Player;
                    Player.BodypartTable['TermiteAbdomin1'] = bp;
                    
                    self.moveInto(nil);
                    
                    Player.TermiteState = 1;
                    
                    //and add some workers all around. somewhere around 8-12
                    local workerCount = 8+rand(5);
                    local worker = new TermiteWorker();
                    
                    worker.count = workerCount;
                    
                    worker.configureStates();
                    worker.initializeActor();
                    worker.moveInto(TermiteQueenChamber);
                    worker.startRTFuse();
                    
                }
            }
        }
    }
}

modify TermiteQueenChamber {}
+ Termite1Jelly : TermiteJelly 
{
    name = 'a large mound of yellow jelly'
    dobjFor(Take)
    {
        action()
        {
            "There is too much for you to carry. If you want to eat some, you can just eat it.";
        }
    }
}

TermiteKing : Actor
{
    name = 'termite king'
    vocabWords = 'big large termite/king*termites'
    desc()
    {
        "A large termite the size of an average human. He is your king for the kingdom you are going to help rebuild.";
    }
}

+ termiteKingFollowing: AccompanyingState
{
    specialDesc = "The Termite king is at your side. ";
}

class TermiteWorker : Actor
{
    count = 1
    isProperName = true;
    name()
    {
        if (count == 1) {return 'A termite worker'; }
        return '<<count>> termite workers';
    }
    vocabWords = 'termite/worker*termites*workers'
    desc()
    {
        if (count == 1)
        {
            "A small termite worker.";
        }
        else
        {
            "<<count>> small, termite workers.";
        }
    }
    isEquivalent() { return true; }
    
    stateTable = nil
    
    configureStates()
    {
        stateTable = new LookupTable();
        local state = new termiteWonderState(self);
        state.moveInto(self);
        stateTable[termiteWonderState] = state;
        
        self.setCurState(stateTable[termiteWonderState]);
    }
    
    rtFuse = nil;
    
    startRTFuse()
    {
        rtFuse = new RealTimeFuse(self,&rtEvent,rand(6001)+6000);
    }
    
    rtEvent()
    {
        //let the state do things
        curState.event();
        
        //and get ready for the next tick if we are still alive.
        if (self.location != nil)
        {
            rtFuse = new RealTimeFuse(self,&rtEvent,rand(6001)+6000);
        }
    }
}

class termiteWonderState: ActorState
{
    isInitState = 1;
    specialDesc()
    {
        if (location.count == 1)
        {
            "A small termite worker is wondering around here.";
        }
        else
        {
            "<<location.count>> small termite workers are wondering around here.";        
        }
    }
    stateDesc()
    {
        if (location.count == 1)
        {
            "Thoughts of being lost fill your mind as you concentract on the wondering termite worker. ";
        }
        else
        {
            "Thoughts of being lost fill your mind as you concentract on the wondering termite workers. ";
        }
    }
    event()
    {
        local worker = self.location;
        local loc = worker.location;
        local destList = [];
    
        //get a list of all directions we could go
        foreach (local dir in Direction.allDirections)
        {
            local conn;
            
            //check for connectors from our location
            if ((conn = loc.getTravelConnector(dir, self)) != nil)
            /*
                && (dest = getDestination(loc, dir, conn)) != nil
                && includeRoom(dest))
                */
            {
                //we have an exit. Lets remember it
                if (conn != noTravel && conn != noTravelIn && conn != noTravelOut && conn != noShipTravel)
                {
                    destList += conn;
                }
            }
        }
        
        //how many termites workers are we?
        local count = worker.count;
        
        //lets split up our termites if they want
        for(local x = 1; x <= destList.length(); x++)
        {

            local dest = destList[x];
            local travellingCount = rand(count+1);
            if (x == destList.length())
            {
                travellingCount = count;
            }
                    
            //Create new workers and move them.
            
            if (travellingCount > 0)
            {
                local newWorker = new TermiteWorker();
                newWorker.configureStates();
                newWorker.initializeActor();
                newWorker.moveInto(worker.location);
                newWorker.count = travellingCount;
                newWorker.startRTFuse();
                //and travel with the new worker
                if (Player.canSee(newWorker)) { newWorker.sayDeparting(dest); }
                newWorker.moveIntoForTravel(dest);
                if (Player.canSee(newWorker)) {  newWorker.sayArriving(dest); }
                
                count -= travellingCount;
            }
        }
        //dont forget to kill the old worker
        worker.moveInto(nil);
        
    }
}


modify Player
{
    TermiteState = 0;
    TermiteMutationLevel = 0;
}

//Some bodyparts for the player
class TermiteAntennae : Component
{
    orderName = 'antennae'
    name = 'termite arms'
    vocabWords = '(termite) antennae*antennae'
    isPlural = true
    desc()
    {
        "You have two, termite antennae on your head.";
    }
}

class TermiteHead1 : Component
{
    orderName = 'head'
    name = 'human head'
    vocabWords = '(human) head*heads'
    desc()
    {
        "You have a mostly normal human head. It is just larger then average.";
    }
}

class TermiteArms1 : Component
{
    orderName = 'lumps'
    name = 'odd lumps'
    vocabWords = '(odd) lumps'
    desc()
    {
        "Along the sides of your torso under your arms, there are four small lumps. Two on either side, and each spread out underneath each other.";
    }
}

class TermiteAbdomin1 : Component
{
    orderName = 'butt'
    name = 'human butt'
    vocabWords = '(human) butt/ass/behind'
    desc()
    {
        "Your butt is big and swolen.";
    }
}