#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <lookup.h>


class Status : object
{
    rank = 0
    hidden = nil
    name() { return ''; }
    desc() {}
    event() {}
    adjustModifier(mod) { return 0; }
    
    Add(x)
    {
        if (!x.Statuses.indexWhich({y :y.ofKind(self) == true}))
        {
            x.Statuses += self;
            owner = x;
            NoteAddition();
        }
        statusLine.showStatusLine();
    }
    
    Remove(x)
    {
        if (x.Statuses.indexWhich({y :y.ofKind(self) == true}))
        {
            local instance = x.Statuses[x.Statuses.indexWhich({y :y.ofKind(self) == true})];
            x.Statuses -= instance;
            instance.NoteRemoval();
        }
        statusLine.showStatusLine();
    }
    
    Has(x)
    {
        return (Get(x) != nil);
    }
    
    Get(x)
    {
        local index = x.Statuses.indexWhich({y :y.getSuperclassList()[1] == self});
        if (index != nil)
        {
            return x.Statuses[index];
        }
        return nil;
    }
    
    NoteAddition() {}
    NoteRemoval() {}
}

//Some statuses

class FatiguedStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Fatigued'
    
    adjustModifier(mod)
    {
        switch(mod)
        {
            case 'Str':
            case 'Dex':
            {
                return -2;
            }
        }
        
        return inherited(mod);
    }
    
    NoteAddition()
    {
        "You feel tired and fatigued.";
    }
}