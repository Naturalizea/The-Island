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
            if (!TermiteQueenTFStatus.Has(Player))
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
                    "You find yourself unable to resist the taste, and you devour the entire yellow mound of sweet jelly. Soon afterwards, fatigue takes over, 
                    and you can't help but fall asleep within the large chamber...";
                    inputManager.pauseForMore(true);
                    SleepingStatus.Add(Player);
                    DateTime.AdvanceTime(1440); //24 hours pass
                    SleepingStatus.Remove(Player);

                    clearScreen();
                    
                    "You awaken sometime later, feeling very relaxed and refereshed, however with an odd headache and a sore butt. Your clothing also seems to 
                    be missing, but that is the least of your concerns at the moment.<br>
                    <br>
                    Standing over you and holding your body down, is one of the largest termites you have ever seen!<br>
                    <br>";
                    PresentChoice([
                    ['Push it off.',Termite1aHook],
                    ['Submit.',Termite1bHook]
                    ]
                    );
                    
                }
            }
        }
    }
}

Termite1aHook : Hook //Try and push the termite off.
{
    event()
    {
        local DC = TermiteKing.Roll(TermiteKing.StrMod);
        local check = Player.DoCheck('Strength check', Player.StrMod, DC);
        
        if (check)
        {
            "Summoning up all your strength, you manage to push the termite off of you. (TODO - ESCAPE)";
        }
        else
        {
            "You try and push the termite off of you, but the creature is too strong for you. You continue to strugle, all the while you feel your headache intensifies. ";
            
            Termite2Hook.event();
           
        }
    }
}

Termite1bHook : Hook //Submit
{
    event()
    {
        "You decide against fighting back and just remain pinned by the termite, all the while the headache which you have been feeling intensifies. ";
        
        Termite2Hook.event();
    }
}

Termite2Hook : Hook //Pinned by the termite, we get filled with emotions.
{
    event()
    {
           "The termite's antennae twitch in the air and you suddnely feel then touch your head. As they do, your mind is suddenly filled with odd, 
           undescribable thoughts and emotions...<br>
            <br>
            The sensation is confusing and disorientating at first, but they quickly become focused and less painful. Thoughs of relaxation and clamness flood 
            your mind, and you find yourself relaxing.<br>
            <br>
            You find yourself thinking thoughts, not quite your own, but at the same time you can only describe them as being guided to think of specific
            things.<br>
            <br>
            You imagine the mound you just entered into, only much larger, and crawling full of life. All around, hundreds of termines wonder around, inside
            and out. Your thoughs are suddenly taken inside, to a chamber much like the one you find yourself currently in, except swarming with smaller
            termines, eggs, and an extremely large queen.<br>
            <br>
            Sadness grips you as you imagine the queen dead, and you see the termite kingdom crumble. Without the queen, the termites start to die, and the
            mound starts to deteriorate without having workers to maintain it. All that is left, is a single termite. A lonely king.<br>
            <br>
            Suddenly, you imagine yourself entering the ruined kingdom, entering the old queens chamber, and eating the yellow jelly... the remains of the
            previous queen, before falling asleep. Visions of the future begin to fill your mind. Visions of the kingdom being restored, and once again full 
            of life, and with you as the queen.<br>
            <br>
            The termite pinning you down eases up, as happy thoughts of home, family and love enter your mind. This is when you come to realize that
            the thoughts and emotions you are feeling, are being projected to you from the termite. This giant termite is the king, and you have been chosen 
            to be his queen and restore his kingdom.<br>
            <br>";
            
            PresentChoice([['Become the new queen',Termite2aHook]]);
    }
}

Termite2aHook : Hook //Become the new termite queen
{
    event()
    {
        "You decide that you will become the new queen. The king gets off of you as you decide this, immense feelings of joy, excitment and love flooding your 
        mind. You slowly stand up and also come to realize that your body is not completely human. Growing out from your forehead, you have two antennae 
        similar to that of the king's, only smaller. Your butt is also swollen up, about 3 times larger then it should be. The beginnings of your abdomin. 
        You just know that your body will transform while you remain within the termite mound, and you just can't wait until you can become the queen for 
        your new king.<br>
        <br>
        Unsure of what comes next, the king approaches you once more. Clear thoughts of you digging a room out come to mind, while you imagine the king and
        yourself digging out a chamber of some sorts until the sun sets, and then while you sleep, the king will be out gathering various types of food to 
        store in this new room you dig out. You should start preparing a storeroom, while your king will go out and gather food for the future.";
        
        TermiteKing.moveIntoForTravel(TermiteQueenChamber);
        TermiteQueenTFStatus.Add(Player);
        TermiteQueenChamber.known = true;
        TermiteKing.setCurState(termiteKingFollowing);
        Termite1Jelly.moveInto(nil);
    }
}

modify TermiteQueenChamber 
{
    roomAfterAction()
    {
        if (TermiteQueenTFStatus.Has(Player) && gActionIs(Sleep))
        {
            local state = TermiteQueenTFStatus.state;
            
            if (state == 1)
            {
                TermiteQueenTFStatus.state = 2;
                "<br><br>Upon waking up, you find that your body has changed further. Looking down at your torso, the first thing you notice is your skin. It has taken on a dark brown
                shade, similar to that of the termite king. Your breasts have also shunk down and now small nubs of what they used to be. Also on the sides of your torso, 
                the small lumps have grown out to become small termite-like legs, protruding out about 30 cm from your body. You experimentally try and move them, and 
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
                growth, an adbomen much like that of any termite, and it extends outwards by about 50 cm.<br>
                <br>
                Emotions of happiness and excitment fill your mind from your king, as well as that to have a bit more patience. You have a feeling that you are almost ready.";
            }
            else if (state == 2)
            {
                TermiteQueenTFStatus.state = 3;
                "<br><br>You wake up lying on on your stomach. Stretching, you try and push yourself up, but find that your legs are not working correctly. Looking down at
                your body, you see that your transformation appears to be complete. You have the body of a giant termite, from your pincers down to your meter long abdomin.<br>
                <br>
                You suddenly feel a weight on your back, and you turn to spot the termite king on you. Excited emotions of family flow into your mind from him, as you feel
                his insect penis thrust into the top of your abdomin. You don't know much about termite physiology, but you shortly feel his seed flowing inside of your
                abdomin. It shouldn't be long now until you have your first children...";
            }
        }
        
    }
}
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
        SleepingStatus.Add(Player);

        DateTime.AdvanceTime(60);

        SleepingStatus.Remove(Player);
        
        
        
        //DateTime.AddToForwardSchedule(1440,({:TermiteKing.MateSchedule()})); //every 24 hours we want to mate the player
        
        return true;
    }
    
    dobjFor(TalkTo)
    {
        action()
        {
            clearScreen();
            "Although you are not entirely certin how you will talk with the termite king, you decide to give it a go anyway.<br>
            <br>";
            doConversation();

        }
    }
    doConversation()
    {        
        PresentChoice([
        ['<q>What should we be doing right now?</q>',TermiteKingCHint],
        ['Stop talking',TermiteKingCStop]
        ]);
    }
    
}

+ termiteKingFollowing: AccompanyingState
{
    specialDesc = "The termite king is at your side. ";
}

TermiteKingCHint : Hook
{
    event()
    {
        "TODO : Progress hints";
        
        TermiteKing.doConversation();
    }
}

TermiteKingCStop : Hook
{
    event()
    {
        "The termite king nods as you stop communicating.";
    }
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

class TermiteQueenTFStatus : TFStatus
{
    rank = 0
    state = 1
    hidden = true
    name = 'Termite-TF (<<state>>)'
    desc()
    {
        switch(state)
        {
            case 1:
            {
                "You are mostly yourself, a human female, except for the short termite-like antennae growing out of your forehead, small lumps along the sides of your
                torso, and your large butt.";
                break;
            }
            case 2:
            {
                "You appear to be a termite-human hybrid. Your skin has a dark-brown shade to it, and your breasts have shrunk down to be small nubs. Along the sides of
                your torse, you have small, underdeveloped termite-like 'arms', about 30cm in length. Your arms are also slightly shorter and thinner, your hands
                insctile with three thin, claw-like fingers. Your legs have similar changes to yours arms. You head is larger, and your hair has fallen out, with two
                mandibles growing out from the sides of your mouth. Your butt has grown out into a small adbomen, extending outwards by about 50 cm.";
            }
            case 3:
            {
                "You are a giant termite, a young queen termite to be precise.";
            }
        }
    }
    
}
/*
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
*/