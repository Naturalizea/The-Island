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
        if (!x.Statuses.indexWhich({y :y.ofKind(self.getSuperclassList()[1]) == true}))
        {
            x.Statuses += self;
            owner = x;
            NoteAddition();
        }
        statusLine.showStatusLine();
    }
    
    Remove(x)
    {
        if (x.Statuses.indexWhich({y :y.getSuperclassList()[1] == self}))
        {
            local instance = x.Statuses[x.Statuses.indexWhich({y :y.getSuperclassList()[1] == self})];
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

modify statusLine
{
    showStatusHtml()
    {
        inherited();
        local x = 0;
        local sortedStatuses = libGlobal.playerChar.Statuses.sort(true, { a, b: a.name().compareTo(b.name())});
        sortedStatuses = sortedStatuses.subset({x: !x.hidden});
        "<tab align=center>";
        foreach(local status in sortedStatuses)
        {
            if (x > 0)
            {
                ", ";
            }
            "<<status.name()>>";
            x++;
        }
        
    }
}