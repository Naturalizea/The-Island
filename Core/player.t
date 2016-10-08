#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

Player: Actor
{    
    
    OverlandTravelTime() //in minutes
    {
        return ((new BigNumber(10)/ new BigNumber(OverworldSpeed)) * 60);
    }
    
    SortStatusByRank(a,b)
    {
        local order = a.rank - b.rank;
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
    
    //our future schedule of events
    currentSchedule = []
    
    // Add an event to fire of <minutes> minutes from when it is added.
    AddToSchedule(minutes,obj,event)
    {
        currentSchedule += [[minutes,obj,event]];
    }
    
    AdvanceSchedule(minutes)
    {
        local newSchedule = [];
        foreach (local scheduleItem in currentSchedule)
        {
            local time = scheduleItem[1];
            local obj = scheduleItem[2];
            local event = scheduleItem[3];
            
            newSchedule += [[time-minutes,obj,event]];
        }
        currentSchedule = newSchedule;
    }
    
    AdvanceTime(minutes)
    {
        local scheduleTime = 0;
        local scheduleObj;
        local scheduleEvent;
        local minutesToAdvance = minutes;
        local stop = nil;
        
        //If we are sleeping
        if (SleepingStatus.Has(Player))
        {
            //work out when we would wake up
            minutes = new BigNumber(Fatigue / FatigueRestRate).getCeil();
            minutesToAdvance = minutes;
        }
    
        //get our next schedule item to run
        if (currentSchedule.length >= 1)
        {    
            local scheduleIndex = currentSchedule.indexOfMin({x: x[1]});
            
            local nextSchedule = currentSchedule[scheduleIndex];
                
            scheduleTime = nextSchedule[1];
            scheduleObj = nextSchedule[2];
            scheduleEvent = nextSchedule[3];
            
            if (scheduleTime < minutes)
            {
                minutesToAdvance = scheduleTime;
            }
        }
        

        
        //based on our time, work out the changes to the stats
        
        //Fatigue
        local fatigueToAdd = 0;
        //Are we sleeping?
        if (SleepingStatus.Has(Player))
        {            
            Fatigue -= (minutes * FatigueRestRate).getFloor();
            
            if (Fatigue < FatigueCap3)
            {
                VeryTiredStatus.Remove(Player);
            }            
            if (Fatigue < FatigueCap2)
            {
                TiredStatus.Remove(Player);
            }
            if (Fatigue < FatigueCap1)
            {
                FatiguedStatus.Remove(Player);
            }
        }
        else
        {            
            fatigueToAdd = FatigueRate * minutes;
        }
        
        Fatigue += fatigueToAdd;
        
        if (Fatigue >= FatigueCap3 && VeryTiredStatus.Has(Player))
        {
            VeryTiredStatus.Remove(Player);
            TiredStatus.Remove(Player);
            FatiguedStatus.Remove(Player);
        }            
        if (Fatigue >= FatigueCap2 && !VeryTiredStatus.Has(Player))
        {
            TiredStatus.Add(Player);
            FatiguedStatus.Remove(Player);
        }
        if (Fatigue >= FatigueCap1 && !TiredStatus.Has(Player) && !VeryTiredStatus.Has(Player))
        {
            FatiguedStatus.Add(Player);
        }
        
        //Hunger
        local hungerToAdd = HungerRate * minutes;
        
        Hunger += hungerToAdd;
        
        if (Hunger >= HungerCap3)
        {
            StarvingStatus.Add(Player);
            HungryStatus.Remove(Player);
            PeckishStatus.Remove(Player);
        }            
        else if (Hunger >= HungerCap2)
        {
            StarvingStatus.Remove(Player);
            HungryStatus.Add(Player);
            PeckishStatus.Remove(Player);
        }
        else if (Hunger >= FatigueCap1)
        {
            StarvingStatus.Remove(Player);
            HungryStatus.Remove(Player);
            PeckishStatus.Add(Player);
        }
        else
        {
            StarvingStatus.Remove(Player);
            HungryStatus.Remove(Player);
            PeckishStatus.Remove(Player);
        }        
        
        if (SleepingStatus.Has(Player))
        {
            //wakeup
            SleepingStatus.Remove(Player);
            "You wake up after <<minutesToAdvance>> minutes.";
        }
        
        //advance our time
        DateTime.AddMinutes(minutesToAdvance);
        AdvanceSchedule(minutesToAdvance);
        //if we still have time remaining on the schedule and should not stop, continue making turns.
        if (stop != nil || minutesToAdvance < minutes)
        {
            AdvanceTime(minutes-minutesToAdvance);
        }
        
        //completed with the minutes initially required or slept without any interruption. 
        return true;
    }
}