#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Food
{
    Nutrition = 0
    Size = 1
    SizeRemaining = 1
    dobjFor(Eat)
    {
        action()
        {
            if (PeckishStatus.Has(Player) || HungryStatus.Has(Player) || StarvingStatus.Has(Player))
            {
                //TODO : Make better, using some kind of player stat for eating time combined with size?
                "You eat <<self.theName>>.<br><br>";
                EatingStatus.Add(Player);
                local minutesToEat = SizeRemaining;
                Player.Hunger -= Nutrition;
                Player.AdvanceTime(minutesToEat);
                if (Player.Hunger < 0)
                {
                    Player.Hunger = 0;                    
                }
                EatingStatus.Remove(Player);
                self.moveInto(nil);
            }
            else
            {
                "You are not hungry.";
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
    Nutrition = 10
}