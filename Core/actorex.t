#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Actor
{
    Fatigue = 0
    FatigueRate = 3
    FatigueRestRate = 5
    FatigueCap1 = 50
    OverworldSpeed = 30 //feet per 6 seconds. Each map square is 1 mile
    
    Hunger = 0
    HungerRate = 5

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
    
    AdvanceTime()
    {
        if (SleepingStatus.Has(Player))
        {
            //restore some fatigue as our fatigue rest rate
            Fatigue -= FatigueRestRate;
            if (Fatigue <= FatigueCap1)
            {
                FatiguedStatus.Remove(Player);
            }
            
            if (Fatigue <= 0)
            {
                Fatigue = 0;
            }
        }
        else
        {
    
            //advance fatigue by fatigue rate 
            Fatigue += FatigueRate;
            
            if (Fatigue >= FatigueCap1)
            {
                FatiguedStatus.Add(Player);
            }
        }
        
        //add us back to the schedule
        DateTime.AddToForwardSchedule(60,({:Player.AdvanceTime()}));
    
        return true;
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

}