#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

Player: Actor
{    
    
    desc()
    {
    
        //should only ever have one TF active at a time.
        
        if (Statuses.indexWhich({y :y.ofKind(TFStatus) == true}))
        {
            local instance = Statuses[Statuses.indexWhich({y :y.ofKind(TFStatus) == true})];
            instance.desc();
        }
        else
        {
            inherited();
        }
    }

    
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
    CurrentSchedule = nil
    
    // Add an event to fire off <minutes> minutes from when it is added.
    AddToSchedule(name,minutes,obj,event)
    {
        if (CurrentSchedule == nil) { CurrentSchedule = new LookupTable();};
        CurrentSchedule[name] = [minutes,obj,event];
    }

    RemoveFromSchedule(name)
    {
        CurrentSchedule.removeElement(name);
    }
    
    AdvanceSchedule(minutes)
    {
        local newSchedule = new LookupTable();
        foreach (local key in CurrentSchedule.keysToList())
        {
            local scheduleItem = CurrentSchedule[key];
            local time = scheduleItem[1];
            local obj = scheduleItem[2];
            local event = scheduleItem[3];
            
            newSchedule[key] = [time-minutes,obj,event];
        }
        CurrentSchedule = newSchedule;
    }
    
    AdvanceTime(minutes)
    {
        local scheduleTime = 0;
        local scheduleObj;
        local scheduleEvent;
        local minutesToAdvance = minutes;
        local minutesAdvanced = 0;
        local stop = nil;
        
        while (stop != true)
        {
            minutesToAdvance = minutes - minutesAdvanced;
            local scheduleName = nil;
        
            //get our next schedule item to run
            if (CurrentSchedule.getEntryCount() >= 1)
            {    
                local scheduleList = CurrentSchedule.valsToList();
                local scheduleIndex = scheduleList.indexOfMin({x: x[1]});
                
                local nextSchedule = scheduleList[scheduleIndex];
                    
                scheduleName = CurrentSchedule.keysToList()[scheduleIndex];
                scheduleTime = nextSchedule[1];
                scheduleObj = nextSchedule[2];
                scheduleEvent = nextSchedule[3];
                
                if (scheduleTime <= minutesToAdvance)
                {
                    minutesToAdvance = scheduleTime;
                }
                else
                {
                    stop = true;
                }
            }
            else
            {
                stop = true;
            }
            
            //advance our time
            DateTime.AddMinutes(minutesToAdvance);
            minutesAdvanced += minutesToAdvance;
            AdvanceSchedule(minutesToAdvance);
            
            //execute the schedule event
            if (scheduleObj != nil && minutesToAdvance >= scheduleTime)
            {
                RemoveFromSchedule(scheduleName);
                stop = scheduleObj.(scheduleEvent);
                scheduleObj = nil;
            }
        }
        
        //completed with the minutes initially required or slept without any interruption. 
        return true;
    }
    
    
    //BASIC SCHEDULE ITEMS
    ConfigureSchedules()
    {
        AddToSchedule('Hunger',60,self,&AdvanceHunger);
        AddToSchedule('Fatigue',60,self,&AdvanceFatigue);
    }
    
    AdvanceHunger()
    {
        Hunger += HungerRate * 60;
        
        CheckHunger();
        
        AddToSchedule('Hunger',60,self,&AdvanceHunger);
    }
    
    CheckHunger()
    {
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
    }
    
    AdvanceFatigue()
    {
        Fatigue += FatigueRate * 60;
        
        CheckFatigue();
        
        AddToSchedule('Fatigue',60,self,&AdvanceFatigue);
    }
    
    CheckFatigue()
    {
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
    }
   
}