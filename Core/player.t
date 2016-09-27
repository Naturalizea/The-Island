#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

Player: Actor
{
    BodypartTable = nil
    
    Fatigue = 0.0000
    FatigueRate = 0.0500
    FatigueRestRate = 0.0850
    FatigueCap1 = 30.0000 //fatigued
    FatigueCap2 = 60.0000 //tired
    FatigueCap3 = 90.0000 //very tired
    FatigueCap4 = 100.0000 //force sleep
    OverworldSpeed = 30.0000 //feet per 6 seconds. Each map square is 1 mile
    
    Hunger = 0.0000
    HungerRate = 0.0800

    Strength = 0
    Dexterity = 0
    Constitution = 0
    Intelligence = 0
    Wisdom = 0
    Charisma = 0
    
    StrBonus = 0
    DexBonus = 0
    ConBonus = 0
    IntBonus = 0
    WisBonus = 0
    ChaBonus = 0    
    
    WillBonus = 0
    FortitudeBonus = 0
    ReflexBonus = 0    
    
    StrMod = CalculateModifier('Str',Strength+StrBonus);
    DexMod = CalculateModifier('Dex',Dexterity+DexBonus);
    ConMod = CalculateModifier('Con',Constitution+ConBonus);
    IntMod = CalculateModifier('Int',Intelligence+IntBonus);
    WisMod = CalculateModifier('Wis',Wisdom+WisBonus);
    ChaMod = CalculateModifier('Cha',Charisma+ChaBonus);
    
    Will = WillBonus + WisMod;
    Fortitude = FortitudeBonus + ConMod;
    Reflex = ReflexBonus + DexMod;
    
    Statuses = []
    
    CalculateModifier(mod, value)
    {
        local total = new BigNumber((value-10.01)/new BigNumber(2)).roundToDecimal(0);
        foreach (local status in Statuses)
        {
            total += status.adjustModifier(mod);
        }
        return total;
    }
    
    DoCheck(name, bonus, dc)
    {
        local roll = rand(20)+1;
        local result = roll + bonus;
        
        if (gameMain.showDiceRolls)
        {
            "<font color=blue> [<<name>> check (<<result>>) vs DC <<dc>> = ";
        }
        
        if (roll != 1 && (result >= dc || roll == 20))
        {
            if (gameMain.showDiceRolls)
            {
                "<b>Success</b>]</font> ";
            }
            return true;
        }
        else
        {
            if (gameMain.showDiceRolls)
            {
                "<b>Failure</b>]</font> ";
            }
            return nil;
        }
    }
    
    AttributeRoll()
    {
        local dice = [rand(6)+1,rand(6)+1,rand(6)+1,rand(6)+1].sort(true, { a, b: a-b });
        return dice[1]+dice[2]+dice[3];
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
    
    dobjFor(Sleep)
    {
        Action()
        {
            "OK!";
        }
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
        local fatigueToAdd = FatigueRate * minutes;
        
        Fatigue += fatigueToAdd;
        
        if (Fatigue >= FatigueCap3)
        {
            VeryTiredStatus.Add(Player);
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
        
        //advance our time
        DateTime.AddMinutes(minutesToAdvance);
        AdvanceSchedule(minutesToAdvance);
        //if we still have time remaining on the schedule and should not stop, continue making turns.
        if (stop != nil || minutesToAdvance < minutes)
        {
            AdvanceTime(minutes-minutesToAdvance);
        }
    }
}