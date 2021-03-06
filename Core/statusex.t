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
        local index = x.Statuses.indexWhich({y :y.ofKind(self) == true});
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
        "You feel fatigued.";
    }
}

class TiredStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Tired'
    
    adjustModifier(mod)
    {
        switch(mod)
        {
            case 'Str':
            case 'Dex':
            {
                return -4;
            }
        }
        
        return inherited(mod);
    }
    
    NoteAddition()
    {
        "You feel feeling tired.";
    }
}

class VeryTiredStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Very Tired'
    
    adjustModifier(mod)
    {
        switch(mod)
        {
            case 'Str':
            case 'Dex':
            {
                return -6;
            }
        }
        
        return inherited(mod);
    }
    
    NoteAddition()
    {
        "You feel feeling very tired.";
    }
}


class PeckishStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Peckish'
    
    NoteAddition()
    {
        "You feel a bit peckish.";
    }
}

class HungryStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Hungry'
    
    NoteAddition()
    {
        "You are hungry.";
    }
}

class StarvingStatus : Status
{
    rank = 0
    hidden = nil
    name = 'Starving'
    
    NoteAddition()
    {
        "You are starving.";
    }
}

class SleepingStatus : Status
{
    rank = 0
    hidden = true
    name = 'Sleeping'
}


class RestlessStatus : Status
{
    rank = 0
    hidden = true
    name = 'Restless'
}

class GatheringStatus : Status
{
    rank = 0
    hidden = true
    name = 'Gathering'
}

class EatingStatus : Status
{
    rank = 0
    hidden = true
    name = 'Eating'
}

class CraftingStatus : Status
{
    rank = 0
    hidden = true
    name = 'Crafting'
}


class TFStatus : Status 
{
    desc()
    {
        "TODO - Description for this TF";
    }

}