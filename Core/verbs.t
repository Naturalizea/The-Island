#include <adv3.h>
#include <en_us.h>

//hive status (when termite)
DefineIAction(HiveStatus)
execAction()
{
    if (TermiteTFStatus.Has(Player))
    {
        TermiteMoundManager.HiveStatus();
    }
    return nil;
};

VerbRule(HiveStatus) ('hivestatus') : HiveStatusAction
{
    verbPhrase = 'hivestatus';
}

//hunt or gather
DefineIAction(Gather)
execAction()
{
    //let the actor handle it
    gActor.Gather();
};

VerbRule(Gather) ('gather') : GatherAction
{
    verbPhrase = 'gather';
}

modify Actor
{
    Gather()
    {
        roomLocation.Gather();
    }
}

modify BasicLocation 
{
    Gather()
    {
        "This is not a suitable location to gather food in.";
        exit;
    }
}

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
        
        Player.AdvanceTime(minutes);
        
        
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
        Player.AdvanceTime(1);
    }
}


//wait for x minutes
DefineIAction(WaitTime)
execAction()
{
    //advance time
    Player.AdvanceTime(numMatch.getval());
    " ";
};

VerbRule(WaitTime) (('z' | 'wait') | ('z' | 'wait') 'for') ((singleNumber) | (singleNumber 'minutes')) : WaitTimeAction
{
    verbPhrase = 'wait/waiting (what)'
}

