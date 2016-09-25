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
        action()
        {
            local eatAll = nil;
            "You eat some of the jelly. It is sweet, and very, very tasty.";
            local willCheck = Player.DoCheck('Will', WillBonus, 20);
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
                self.moveInto(nil);
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