#charset "us-ascii"
#include <adv3.h>
#include <lookup.h>

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
                local willCheck = Player.DoCheck('Will', Player.WillBonus, 20);
                if (willCheck)
                {
                    "Do you want to eat it all? ";
                    local accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
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
                        to lie on the ground as they get accustomed to their new queen. A few minutes later, they all get off you, and feelings of purpose start
                        to fill your mind. One of them drops a small handfull of jelly close to your head, before they all leave the chamber. A feeling of sating 
                        hunger filling your mind as they leave, but the king remains with you.<br>
                        <br>
                        Feelings of protection and home fill your mind, as well as preperation. You are not entirely certian on the preperation thoughts, but you
                        have a feeling that the king does not want you to leave the mound, after waiting for you to come for so long.";
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
                    
                    while (workerCount > 0)
                    {
                        workerCount--;
                        local worker = new TermiteWorker();
                        
                        //random area to spawn in the mound
                        local rooms = TermiteMoundBuilder.map.valsToList();
                        local randRoom = rooms[rand(rooms.length)+1];
                        
                        worker.initializeActor();
                        worker.moveInto(randRoom);
                    }
                    
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
    name = 'the termite king'
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
    name = 'termite worker'
    vocabWords = 'termite/worker*termites*workers'
    desc()
    {
        "A small termite worker.";
    }
    isEquivalent() { return true; }
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