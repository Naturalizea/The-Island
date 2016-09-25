#include <adv3.h>
#include <en_us.h>
modify WaitAction
{
    execAction()
    {
        if (RestlessStatus.Has(libGlobal.playerChar))
        {
            "You are too restless to just wait around and do nothing.";
            exit;
        }
        local minutes = toInteger(inputManager.getInputLine(nil, {: "How many minutes do you want to wait? " }));
        
        DateTime.AdvanceTime(minutes);
    }
      
}


//wait for x minutes
DefineIAction(WaitTime)
execAction()
{
    //advance time
    DateTime.AdvanceTime(numMatch.getval());
};

VerbRule(WaitTime) (('z' | 'wait') | ('z' | 'wait') 'for') ((singleNumber) | (singleNumber 'minutes')) : WaitTimeAction
{
    verbPhrase = 'wait/waiting (what)'
}