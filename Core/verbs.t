#include <adv3.h>
#include <en_us.h>

//waiting
modify WaitAction
{
    execAction()
    {
        if (RestlessStatus.Has(Player))
        {
            "You are too restless to just wait around and do nothing.";
            exit;
        }
        local minutes = toInteger(inputManager.getInputLine(nil, {: "How many minutes do you want to wait? " }));
        DateTime.AdvanceTime(minutes);
        
    }
      
}

modify SleepAction
{
    execAction()
    {
        if (!FatiguedStatus.Has(Player) && !TiredStatus.Has(Player) && !VeryTiredStatus.Has(Player)) 
        {
            "You are not tired enough to sleep.";
            exit;
        }
        
        "You drift off to sleep...";
        inputManager.pauseForMore(true);
        SleepingStatus.Add(Player);
        SleepingStatus.forced = nil;
        DateTime.AdvanceTime(60);
    }
}


//wait for x minutes
DefineIAction(WaitTime)
execAction()
{
    //advance time
    DateTime.AdvanceTime(numMatch.getval());
    " ";
};

VerbRule(WaitTime) (('z' | 'wait') | ('z' | 'wait') 'for') ((singleNumber) | (singleNumber 'minutes')) : WaitTimeAction
{
    verbPhrase = 'wait/waiting (what)'
}

