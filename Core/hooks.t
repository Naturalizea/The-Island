#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <lookup.h>

HookEvents : object
{
    eventTable = nil;

    ChooseRandomOrderedHook(hookType)
    {
        if (eventTable == nil)
        {
            eventTable = new LookupTable();
        }
        
        if (eventTable[hookType] == nil)
        {
            local hookArray = [];
            forEachInstance(hookType, {x: hookArray += [[x.name,x]]});
            hookArray = hookArray.sort(true, { a, b: SortHookByRank(a,b) });
            eventTable[hookType] = hookArray;
        }
        
        for (local x = 0; x < eventTable[hookType].length(); x++)
        {
            local hook = eventTable[hookType][x+1][2];
            if (hook.IsValid())
            {
                local stop = hook.event();
                
                if (stop) { break; }
            }
        }
    }

    SortHookByRank(a,b)
    {
        local order = a[2].Rank - b[2].Rank;
        if (order == 0)
        {
            if (rand(2) == 1)
            {
                return -1;
            }
            else
            {
                return 1;
            }
        }
        return order;
    }
}


class Hook : object
{
    name = ''
    event()
    {
        //TODO : Implement
    }
}

TrueHook : Hook
{
    event()
    {
        return true;
    }
}

FalseHook : Hook
{
    event()
    {
        return nil;
    }
}

RandomHook : Hook
{
    Rank = 100;
    IsValid()
    {
        return true;
    }    
}