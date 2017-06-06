#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

class craftable : Fixture
{
    difficulty = 1.00 //how difficult a craft attempt is to progress
    requiredSuccesses = 1.00 //how many successes are required to complete
    successes = 0.00 //how many successes have been completed already
    
    name = 'craftable'
    
    Craft(progressRoll)
    {
        local attemptSuccesses = new BigNumber(progressRoll/difficulty).getFloor();
        successes += attemptSuccesses;
        if (successes >= requiredSuccesses)
        {
            OnComplete();
        }
    }
    
    Progress()
    {
        local progress = new BigNumber(successes/requiredSuccesses).roundToDecimal(2);
        return progress;
    }
    
    specialDesc()
    {
        "An incomplete project (<<name>>) is here. It is about <<Progress()>>% done";
    }
    
    OnComplete()
    {
        self.moveInto(nil);
    }
}