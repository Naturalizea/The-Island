#charset "us-ascii"
#include <adv3.h>

/* Very simple DateTime object for tracking time. This is not using the Gregorian calendar, but rather a simplied system of having a flat 28 days in a month. */

DateTime : object
{
    /* Month of the year */
    _month = 1
    /* Day of the month */
    _day = 1
    /* Current hour */
    _hour = 0
    /* Current minute */
    _minute = 0
    
    /* Returns the current season in text */
    GetSeason()
    {
        if (_month < 3) {return 'winter';}
        if (_month < 6) {return 'spring';}
        if (_month < 9) {return 'summer';}
        if (_month < 12) {return 'fall';}
        return 'winter';
    }

    /* Returns the current time of day, based on the current hour */
    GetTimeOfDay()
    {
        if (_hour < 1) {return 'midnight';}
        if (_hour < 5) {return 'early morning';}
        if (_hour < 7) {return 'dawn';}
        if (_hour < 11) {return 'morning';}
        if (_hour < 13) {return 'noon';}
        if (_hour < 17) {return 'afternoon';}
        if (_hour < 19) {return 'dusk';}
        if (_hour < 23) {return 'evening';}
        return 'midnight';
    }
    
    /* String representation of the date with the season and time of day. */
    ToString()
    {
        return '\^<<GetSeason>> - \^<<GetTimeOfDay()>>';
    }
    
    /* Add <minutes> minutes to the current datetime */
    AddMinutes(minutes)
    {
        _minute += minutes;
        while (_minute >= 60)
        {
            AddHours(1);
            _minute -= 60;
        }
    }
    
    /* Add <hours> hours to the current datetime */
    AddHours(hours)
    {
        _hour += hours;
        while (_hour >= 24)
        {
            AddDays(1);
            _hour -= 24;
        }
    }
    
    /* Add <days> days to the current datetime */
    AddDays(days)
    {
        _day += days;
        while (_day > 28)
        {
            AddMonths(1);
            _day -= 28;
        }
    }
    
    /* Add <months> months to the current datetime */
    AddMonths(months)
    {
        _month += months;
        while (_month > 12)
        {
            _month -= 12;
        }
    }
    
    //our future schedule
    currentSchedule = []
    
    
    // Add an event to fire of <minutes> minutes from when it is added.
    AddToForwardSchedule(minutes,event)
    {
        currentSchedule += [[minutes,event]];
    }
    
    // Advance time by <minutes>, taking the schedule into account
    AdvanceTime(minutes)
    {
        local advancing = true;
        while (advancing)
        {            
            local scheduleIndex = currentSchedule.indexOfMin({x: x[1]});
        
            local nextSchedule = currentSchedule[scheduleIndex];
            
            local scheduleTime = nextSchedule[1];
            local scheduleEvent = nextSchedule[2];
            
            if (scheduleTime <= minutes)
            {
                AdvanceSchedule(scheduleTime);            
                AddMinutes(scheduleTime);
                minutes -= scheduleTime;
                local cont = scheduleEvent();
                
                if (!cont)
                {
                    "Prompt for player to stop.";
                }
                
                currentSchedule = currentSchedule.removeElementAt(scheduleIndex);
                
                if (minutes == 0)
                {
                    advancing = nil;
                }
                
            }
            else
            {
                AddMinutes(minutes);
                AdvanceSchedule(minutes);
                advancing = nil;
            }
        }
    }
    
    AdvanceSchedule(minutes)
    {
        local newSchedule = [];
        foreach (local scheduleItem in currentSchedule)
        {
            local time = scheduleItem[1];
            local event = scheduleItem[2];
            
            newSchedule += [[time-minutes,event]];
        }
        currentSchedule = newSchedule;
    }

}

/* change the status line to display date / time. This is just a rewrite of the current statusLine, with the DateTime displayed */
modify statusLine
{
    replace showStatusHtml()
    {
        /* hyperlink the location name to a "look around" command */
        "<a plain href='<<libMessages.commandLookAround>>'>";
            
        /* show the left part of the status line */
        showStatusLeft();
            
        "</a>";

        "<tab align=center>";

        showStatusCenter();

        //"</a>";

        /* set up for the score part on the right half */
        "<tab align=right><a plain
            href='<<libMessages.commandFullScore>>'>";
        
        /* show the right part of the status line */
        showStatusRight();
        
        /* end the score link */
        "</a>";
        
        /* add the status-line exit list, if desired */
        if (gPlayerChar.location != nil)
            gPlayerChar.location.showStatuslineExits();
            
            
        //statuses change
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

    showStatusCenter()
    {
        "<<DateTime.ToString()>>";
    }

    replace showStatusRight()
    {
        local s;

        /* show the time and score */
        if ((s = libGlobal.scoreObj) != nil)
        {
            "<.statusscore>Score:\t<<s.totalScore>><./statusscore>";
        }
    }
}