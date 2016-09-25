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
}
