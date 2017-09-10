#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

Player: Actor
{    

    isHim = true;
    
    points = 50;

    CreateCharacter()
    {
        PlayerCreateMenu.Show();
    }


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
        
        //execute the schedule event
        if (scheduleObj != nil)
        {
            stop = scheduleObj.(&scheduleEvent);
        }
        
        //if we still have time remaining on the schedule and should not stop, continue making turns.
        if (stop != nil || minutesToAdvance < minutes)
        {
            AdvanceTime(minutes-minutesToAdvance);
        }
        
        //completed with the minutes initially required or slept without any interruption. 
        return true;
    }
}


//The create player menus
PlayerCreateMenu : ExMenu
{
    name = '<b>Character Creation</b>'
    execute()
    {
        AddMenuItem(PlayerCreateMenu_Name);
        AddMenuItem(PlayerCreateMenu_Gender);
        AddMenuItem(PlayerCreateMenu_AttributesHeader);
        AddMenuItem(PlayerCreateMenu_AttributeStrength);
        AddMenuItem(PlayerCreateMenu_AttributeDexterity);
        AddMenuItem(PlayerCreateMenu_AttributeIntelligence);
        AddMenuItem(PlayerCreateMenu_AttributeHealth);
        AddMenuItem(PlayerCreateMenu_AttributeHitpoints);
        AddMenuItem(PlayerCreateMenu_AttributeWill);
        AddMenuItem(PlayerCreateMenu_AttributePerception);
        AddMenuItem(PlayerCreateMenu_AttributeFatigue);
        AddMenuItem(PlayerCreateMenu_AttributeBasicSpeed);
        AddMenuItem(PlayerCreateMenu_AttributeBasicMove);
        
    }
    
    Escape()
    {
        return nil;
    }
}

PlayerCreateMenu_Name : ExMenuItem
{
    name = 'Character name : <<value>>'
    value = ''
    Select()
    {
        parentMenu.clearMenu();
        clearScreen();
        value = inputManager.getInputLine(nil, {: "Please enter your name? " });
        Player.name = value;
        " "; //Stop "nothing obvious happens." :(
        return nil;                
    }
}

PlayerCreateMenu_Gender : ExMenuItem
{
    name = 'Character gender : <<value>>'
    value = 'Male'
    Right() { Select(); }
    Left() { Select(); }    
    Select()
    {
        if (Player.isHim == true)
        {
            value = 'Female';
            Player.isHim = nil;
            Player.isHer = true;
        }
        else
        {
            value = 'Male';
            Player.isHer = nil;
            Player.isHim = true;
        }
        return nil;                
    }
}

PlayerCreateMenu_AttributesHeader : ExMenuItem
{
    name = '<hr><tab align=center><b>Basic attributes (<<Player.points>> points available)</b><hr>';
    fakeItem = true;
}

PlayerCreateMenu_AttributeStrength : ExMenuItem
{
    name = 'Strength : <<Player.Strength>> (+/- 10 points)'
    Left()
    {
        if (Player.Strength > 8)
        {
            Player.points += 10;
            Player.Strength -= 1;
            Player.HitPoints -= 1;
            //are Hitpoints still in a valid range?
            local HPCapLow = ((Player.Strength * 0.7)).getFloor();
            local HPCapHigh = ((Player.Strength * 1.3)).getFloor();
            while (HPCapLow > Player.HitPoints)
            {
                PlayerCreateMenu_AttributeHitpoints.Right();
                HPCapLow = ((Player.Strength * 0.7)).getFloor();
            }
            while (HPCapHigh < Player.HitPoints)
            {
                PlayerCreateMenu_AttributeHitpoints.Left();
                HPCapHigh = ((Player.Strength * 1.3)).getFloor();
            }
            
        }
        return nil;  
    }
    Right()
    {
        if (Player.points >= 10 && Player.Strength < 12)
        {
            Player.points -= 10;
            Player.Strength += 1;
            Player.HitPoints += 1;
        }
        return nil;
    }
}

PlayerCreateMenu_AttributeDexterity : ExMenuItem
{
    name = 'Dexterity : <<Player.Dexterity>> (+/- 20 points)'
    Left()
    {
        if (Player.Dexterity > 8)
        {
            Player.points += 20;
            Player.Dexterity -= 1;
            Player.BasicSpeed -= 0.25;
        }
        return nil;
    }
    Right()
    {
        if (Player.points >= 20 && Player.Dexterity < 12)
        {
            Player.points -= 20;
            Player.Dexterity += 1;
            Player.BasicSpeed += 0.25;
        }
        return nil;
    }
}

PlayerCreateMenu_AttributeIntelligence : ExMenuItem
{
    name = 'Intelligence : <<Player.Intelligence>> (+/- 20 points)'
    Left()
    {
        if (Player.Intelligence > 8)
        {
            Player.points += 20;
            Player.Intelligence -= 1;
            Player.Will -= 1;
            Player.Perception -= 1;
            //Is will decrease valid?
            if (Player.Will < 4)
            {
                PlayerCreateMenu_AttributeWill.Right();
            }
            //Is per decrease valid?
            if (Player.Perception < 4)
            {
                PlayerCreateMenu_AttributePerception.Right();
            }
        }
        return nil;
    }
    Right()
    {
        if (Player.points >= 20 && Player.Intelligence < 12)
        {
            Player.points -= 20;
            Player.Intelligence += 1;
            Player.Will += 1;
            Player.Perception += 1;
            //Is will increase valid?
            if (Player.Will > 20)
            {
                PlayerCreateMenu_AttributeWill.Left();
            }
            //Is per increase valid?
            if (Player.Perception > 20)
            {
                PlayerCreateMenu_AttributePerception.Left();
            }
        }
        return nil;
    }
}

PlayerCreateMenu_AttributeHealth : ExMenuItem
{
    name = 'Health : <<Player.Health>> (+/- 10 points)'
    Left()
    {
        if (Player.Health > 8)
        {
            Player.points += 10;
            Player.Health -= 1;
            Player.FatiguePoints -= 1;
            //are FatiguePoints still in a valid range?
            local FPCapLow = ((Player.Health * 0.7)).getFloor();
            local FPCapHigh = ((Player.Health * 1.3)).getFloor();
            while (FPCapLow > Player.FatiguePoints)
            {
                PlayerCreateMenu_AttributeFatigue.Right();
                HPCapLow = ((Player.Health * 0.7)).getFloor();
            }
            while (FPCapHigh < Player.FatiguePoints)
            {
                PlayerCreateMenu_AttributeFatigue.Left();
                HPCapHigh = ((Player.Health * 1.3)).getFloor();
            }
            
            Player.BasicSpeed -= 0.25;
            
        }
        return nil;
    }
    Right()
    {
        if (Player.points >= 10 && Player.Health < 12)
        {
            Player.points -= 10;
            Player.Health += 1;
            Player.FatiguePoints += 1;
            Player.BasicSpeed += 0.25;
        }
        return nil;
    }
}

PlayerCreateMenu_AttributeHitpoints : ExMenuItem
{
    name = 'Hit Points : <<Player.HitPoints>> (+/- 2 points)'
    Left()
    {
        local RealCap = ((Player.Strength * 0.7)).getFloor();
        if (Player.HitPoints > RealCap)
        {
            Player.points += 2;
            Player.HitPoints -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = ((Player.Strength * 1.3)).getFloor();
        if (Player.points >= 2 && Player.HitPoints < RealCap)
        {
            Player.points -= 2;
            Player.HitPoints += 1;
        }
    
        return nil;
    }
}

PlayerCreateMenu_AttributeWill : ExMenuItem
{
    name = 'Will : <<Player.Will>> (+/- 5 points)'
    Left()
    {
        if (Player.Will > 4)
        {
            Player.points += 5;
            Player.Will -= 1;
        }
    
        return nil;
    }
    Right()
    {
        if (Player.points >= 5 && Player.Will < 20)
        {
            Player.points -= 5;
            Player.Will += 1;
        }
    
        return nil;
    }
}

PlayerCreateMenu_AttributePerception : ExMenuItem
{
    name = 'Perception : <<Player.Perception>> (+/- 5 points)'
    Left()
    {
        if (Player.Perception > 4)
        {
            Player.points += 5;
            Player.Perception -= 1;
        }
    
        return nil;
    }
    Right()
    {
        if (Player.points >= 5 && Player.Perception < 20)
        {
            Player.points -= 5;
            Player.Perception += 1;
        }
    
        return nil;
    }
}

PlayerCreateMenu_AttributeFatigue : ExMenuItem
{
    name = 'Fatigue Points : <<Player.FatiguePoints>> (+/- 3 points)'
    Left()
    {
        local RealCap = ((Player.Health * 0.7)).getFloor();
        if (Player.FatiguePoints > RealCap)
        {
            Player.points += 3;
            Player.FatiguePoints -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = ((Player.Health * 1.3)).getFloor();
        if (Player.points >= 3 && Player.FatiguePoints < RealCap)
        {
            Player.points -= 3;
            Player.FatiguePoints += 1;
        }
    
        return nil;
    }
}

PlayerCreateMenu_AttributeBasicSpeed : ExMenuItem
{
    name = 'Basic Speed : <<Player.BasicSpeed>> (+/- 5 points)'
    Left()
    {
        local RealCap = ((Player.Health + Player.Dexterity) / 4)-2.00;
        local flatSpeed = Player.BasicSpeed.getFloor();
        if (Player.BasicSpeed - 0.25 >= RealCap)
        {
            Player.points += 5;
            Player.BasicSpeed -= 0.25;
            //Adjust move
            if (flatSpeed != Player.BasicSpeed.getFloor())
            {
                Player.BasicMove -= 1;
            }
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = ((Player.Health + Player.Dexterity) / 4) + 2.00;
        local flatSpeed = Player.BasicSpeed.getFloor();
        if (Player.points >= 5 && Player.BasicSpeed + 0.25 <= RealCap)
        {
            Player.points -= 5;
            Player.BasicSpeed += 0.25;
            //Adjust move
            if (flatSpeed != Player.BasicSpeed.getFloor())
            {
                Player.BasicMove += 1;
            }
        }
    
        return nil;
    }
}

PlayerCreateMenu_AttributeBasicMove : ExMenuItem
{
    name = 'Basic Move : <<Player.BasicMove>> (+/- 5 points)'
    Left()
    {
        local RealCap = Player.BasicSpeed.getFloor() - 3;
        if (Player.BasicMove > RealCap)
        {
            Player.points += 5;
            Player.BasicMove -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = Player.BasicSpeed.getFloor() + 3;
        if (Player.points >= 5 && Player.BasicMove < RealCap)
        {
            Player.points -= 5;
            Player.BasicMove += 1;
        }
    
        return nil;
    }
}