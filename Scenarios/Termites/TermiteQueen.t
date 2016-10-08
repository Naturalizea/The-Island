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
                    SleepingStatus.Add(Player);
                    DateTime.AdvanceTime(1440); //24 hours pass
                    SleepingStatus.Remove(Player);

                    Player.TermiteMutationLevel = 50;
                    clearScreen();
                    
                    "You awaken sometime later, feeling very relaxed and refereshed, however with an odd headache and a sore butt. Your clothing also seems to be
                    missing. Looking around, you are greeted with a terrifying sight. A giant termite is standing a few feet away from you, about the size of an 
                    average human, seeming watching you with twitching antennae.<br>
                    <br>
                    You start to back away from the termite, be he approaches as you retreat, and soon you feel your back up against one of the walls The termite's
                    antennae twitch, and your headache intensifies. Reaching a hand up to your head, you also start to feel something strange... Two long protruding 
                    and flexable sticks of some kind, and they are growing out from your head, right above your eyes.<br>
                    <br>
                    Your headache throbs again as the large termite gets closer, and you are suddenly filled with various thoughts and emotions. They don't make
                    much sense to you at first, but then they begin to get focused. You somehow get a feeling of happiness and an idea that the future is secured.
                    You then understand that what you are feeling is coming from the large termite, who you now recognise as the king, and he is communicating with
                    you in this strange way. You are still, however, confused at this situation you find yourself in.<br>
                    <br>
                    As if sensing your own emotions, you get projected other feelings. Feelings of reassurance, and of family. The termite kings gets closer, and
                    his antennae touch your own, causing a flood of images to flow into your mind. You see a large termite kingdom with thousands, no... millions of
                    termites, all working in unison to survive and prosper. You then see destruction hit the mountain-like mound, killing the queen and almost all
                    of the termites. With the death of the queen, over time the remaining termines started to perish, and the termite mound collapsed into the much
                    small mound you entered today. Soon, only the king was left.<br>
                    <br>
                    The visions end as the king steps again, and emotions of rebuilding the kingdom enter your mind, and of immense love for you. Feelings of
                    belonging enter your mind, and you understand. He has been waiting for a new queen, and you have been chosen for the position.<br>
                    <br>
                    Do you want to become the new queen? ";
                    local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
                    
                    if (accept)
                    {
                        "<br><br>Immense feelings of joy, excitment, love and eagerness flood your mind, and it starts to become extremly overwhelming.
                        You almost don't notice the termite king approach your naked form and position himself for the mating process to begin. ";
                        willCheck = Player.DoCheck('Will', Player.WillBonus, 15);
                        if (willCheck)
                        {
                            "Do you resist? ";
                            local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
                            "<br><br>";
                            if (!accept)
                            {
                                "Choosing not to resist the emotions flooding your mind, you get more confortable as the termite climbs on top of your, his antenne twitching 
                                like crazy. You feel his alien-like tool enter your wanting pussy, and shudder at the feeling. You wrap your arms around his bocy
                                as he starts to thrust his member in and our of your pussy.<br>
                                <br>
                                He opens his mouth as yellow jelly flows out from it. You open your mouth, and manage to catch most of the sweet, yellow jelly
                                as you feel him release his load into your womb. His job done, he gets off of you and feelings security and protection enter your 
                                mind. Security for the future, and protection of yourself.";
                                Player.TermiteMutationLevel += 10;
                                
                                //DateTime.AddToForwardSchedule(1440,({:TermiteKing.MateSchedule()})); //every 24 hours we want to mate the player
                            }
                            else
                            {
                                "TODO : Decline sex";
                            }
                        }
                        else
                        {
                            "Unable to resist the emotions flooding your mind, you get more confortable as the termite climbs on top of your, his antenne twitching 
                            like crazy. You feel his alien-like tool enter your wanting pussy, and shudder at the feeling. You wrap your arms around his bocy
                            as he starts to thrust his member in and our of your pussy.<br>
                            <br>
                            He opens his mouth as yellow jelly flows out from it. You open your mouth, and manage to catch most of the sweet, yellow jelly
                            as you feel him release his load into your womb. His job done, he gets off of you and feelings security and protection enter your 
                            mind. Security for the future, and protection of yourself.";
                            Player.TermiteMutationLevel += 10;
                            
                            //DateTime.AddToForwardSchedule(1440,({:TermiteKing.MateSchedule()})); //every 24 hours we want to mate the player
                        }
                    }
                    else
                    {
                        "TODO : REJECTION PATH. FIGHT WITH TERMITE ENSURE.";
                    }
                    
                    TermiteKing.moveIntoForTravel(TermiteQueenChamber);
                    
                    Player.TermiteState = 1;
                    
                    //and add some workers all around. somewhere around 8-12
                    /*
                    local workerCount = 8+rand(5);
                    local worker = new TermiteWorker();
                    
                    worker.count = workerCount;
                    
                    worker.configureStates();
                    worker.initializeActor();
                    worker.moveInto(TermiteQueenChamber);
                    worker.startRTFuse();
                    */
                    
                    TermiteKing.setCurState(termiteKingFollowing);
                    
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

TermiteKing : Termite
{
    name = 'termite king'
    vocabWords = 'big large termite/king*termites'
    desc()
    {
        "A large termite the size of an average human. He is your king for the kingdom you are going to help rebuild.";
    }
    MateSchedule()
    {
        "The termite king approaches you, thoughs of reproduction and family flood your mind. You can't help but mate with to mate your king as he feeds you more yellow
        jelly, and falling asleep for an hour soon after you are done.";
        Player.TermiteMutationLevel += 10;
        SleepingStatus.Add(Player);

        DateTime.AdvanceTime(60);

        SleepingStatus.Remove(Player);
        
        
        
        //DateTime.AddToForwardSchedule(1440,({:TermiteKing.MateSchedule()})); //every 24 hours we want to mate the player
        
        return true;
    }
}

+ termiteKingFollowing: AccompanyingState
{
    specialDesc = "The termite king is at your side. ";
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

//wakeup events
modify SleepingStatus
{
    NoteRemoval()
    {
        if (Player.TermiteState == 1 && Player.TermiteMutationLevel >= 100)
        {
            Player.TermiteState = 2;
            Player.TermiteMutationLevel = 1;
            
            clearScreen();
            "<br><br>You awaken this time to find your body has changed further. Looking down at your torso, the first thing you notice is your skin. It has taken on a dark brown
            shade, similar to that of the termite king. Your breasts have also shunk down and now small nubs of what they used to be. Also on the sides of your torso, 
            the small lumps have grown out to become small termite-like legs, protruding out about 10 inches from your body. You experimentally try and move them, and 
            find that you have complete control, however the limbs are too small and frail to be useful for anything.<br>
            <br>
            Moving your arms to your chest, you also notice your arms have changed. They are slightly shorter and thinner, and your hands have become insectile, each now only
            having three thin, claw-like fingers. clenching your fists, your find your fine moter-skills in them decreased slightly. You will have a hard time with smaller
            objects, however you can still grasp and carry things with them. Looking at your legs, you notice similar changes with them as with your arms.<br>
            <br>
            Rubbing your changed arms over your chest, you find you body feeling mush softer then normal. Feeling your head grants you with a similar supprise. Your head is
            larger again, and your hair has fallen out. You also have two mandibles growing out from the sides of you mouth, and your mouth feels very alien-like.<br>
            <br>
            Standing up to examine your body further, you hunch slightly forwards, but still able to stand. Looking behind you, your butt has grown into a much larger 
            growth, an adbomen much like that of any termite, and it extends outwards by about 1 foot.<br>
            <br>
            Emotions of love and attraction flood your mind, as you realize that the king as noticed you are awake and noticed your changes. The emotions are quickly
            replaced yet again by those of reproduction and family, and you feel that your body is finally compatible enough with the king's to become pregnant.<br>
            <br>
            The king wastes no time in pushing you down to the ground, causing you a slight pain in your new soft abdomen. He climbs ontop of you, giving you no choice
            as he effectly <q>rapes</q> you.";
        }

        inherited();
    }
}