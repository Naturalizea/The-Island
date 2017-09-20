#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>
#include <lookup.h>

Player: Actor
{    

    //Game stuff
    Points = 50;
    Statuses = []
    
    isHim = true;

    //Basic attributes
    Strength = 10
    Dexterity = 10
    Intelligence = 10
    Health = 10
    
    //Secondary attributes
    HitPoints = 10
    Will = 10
    Perception = 10
    FatiguePoints = 10
    BasicSpeed = 5.0000 //(HT + DX) / 4
    BasicMove = 5.0000
    
    //Tracking
    StarvationFP = 0
    
    
    //Basic test
    SuccessCheck(modifier,test,testname)
    {
        local roll = rand(6)+rand(6)+rand(6)+3;
        local total = roll + modifier;
        if (gameMain.showDiceRolls)
        {
            "<font color=blue> [\^<<testname>> check (<<roll>> + <<modifier>>) vs <<test>> = ";
        }
        if (roll < 17 && (total <= test || roll <= 4))
        {
            if (gameMain.showDiceRolls)
            {
                "<b>Success</b>]</font> ";
            }
            return true;
        }
        if (gameMain.showDiceRolls)
        {
            "<b>Failure</b>]</font> ";
        }
        return nil;
    }
    
    //Attribute tests
    StrengthTest(modifier)
    {
        return SuccessCheck(modifier,Strength,'strength');
    }
    
    DexterityTest(modifier)
    {
        return SuccessCheck(modifier,Dexterity,'dexterity');
    }
    
    IntelligenceTest(modifier)
    {
        return SuccessCheck(modifier,Intelligence,'intelligence');
    }
    
    HealthTest(modifier)
    {
        return SuccessCheck(modifier,Health,'health');
    }   

    CreateCharacter()
    {
        PlayerCreateMenu.Show();
        ConfigureSchedule();
    }
    
    ConfigureSchedule()
    {
        AddToSchedule('Hunger',60*24,self,&AdvanceStarvation);
    }
    
    AdvanceStarvation()
    {
        "Starvation test";
        return nil;
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
    CurrentSchedule = nil
    
    // Add an event to fire of <minutes> minutes from when it is added.
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
            
            if (time-minutes <= 0)
            {
                RemoveFromSchedule(key);
            }
            else
            {
                newSchedule[key] = [time-minutes,obj,event];
            }
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
        
        while (stop != nil || minutesAdvanced < minutes)
        {
            
            //If we are sleeping
            /*
            if (SleepingStatus.Has(Player))
            {
                //work out when we would wake up
                minutes = new BigNumber(Fatigue / FatigueRestRate).getCeil();
                minutesToAdvance = minutes;
            }
        */
            //get our next schedule item to run
            if (CurrentSchedule.getEntryCount() >= 1)
            {    
                local scheduleList = CurrentSchedule.valsToList();
                local scheduleIndex = scheduleList.indexOfMin({x: x[1]});
                
                local nextSchedule = scheduleList[scheduleIndex];
                    
                scheduleTime = nextSchedule[1];
                scheduleObj = nextSchedule[2];
                scheduleEvent = nextSchedule[3];
                
                if (scheduleTime < minutes)
                {
                    minutesToAdvance = scheduleTime;
                }
            }
            else
            {
                minutesToAdvance = minutes - minutesAdvanced;
            }
            

            /*
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
            */
            //advance our time
            DateTime.AddMinutes(minutesToAdvance);
            minutesAdvanced += minutesToAdvance;
            AdvanceSchedule(minutesToAdvance);
            
            //execute the schedule event
            if (scheduleObj != nil && minutesAdvanced >= scheduleTime)
            {
                stop = scheduleObj.(scheduleEvent);
                scheduleObj = nil;
            }
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
        AddMenuItem(Menu_Line);
        AddMenuItem(PlayerCreateMenu_Done);
        
        
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
    name = '<hr><tab align=center><b>Basic attributes (<<Player.Points>> points available)</b><hr>';
    fakeItem = true;
}

PlayerCreateMenu_AttributeStrength : ExMenuItem
{
    name = 'Strength : <<Player.Strength>> (+/- 10 points)'
    Left()
    {
        if (Player.Strength > 8)
        {
            Player.Points += 10;
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
        if (Player.Points >= 10 && Player.Strength < 12)
        {
            Player.Points -= 10;
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
            Player.Points += 20;
            Player.Dexterity -= 1;
            Player.BasicSpeed -= 0.25;
        }
        return nil;
    }
    Right()
    {
        if (Player.Points >= 20 && Player.Dexterity < 12)
        {
            Player.Points -= 20;
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
            Player.Points += 20;
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
        if (Player.Points >= 20 && Player.Intelligence < 12)
        {
            Player.Points -= 20;
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
            Player.Points += 10;
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
        if (Player.Points >= 10 && Player.Health < 12)
        {
            Player.Points -= 10;
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
            Player.Points += 2;
            Player.HitPoints -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = ((Player.Strength * 1.3)).getFloor();
        if (Player.Points >= 2 && Player.HitPoints < RealCap)
        {
            Player.Points -= 2;
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
            Player.Points += 5;
            Player.Will -= 1;
        }
    
        return nil;
    }
    Right()
    {
        if (Player.Points >= 5 && Player.Will < 20)
        {
            Player.Points -= 5;
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
            Player.Points += 5;
            Player.Perception -= 1;
        }
    
        return nil;
    }
    Right()
    {
        if (Player.Points >= 5 && Player.Perception < 20)
        {
            Player.Points -= 5;
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
            Player.Points += 3;
            Player.FatiguePoints -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = ((Player.Health * 1.3)).getFloor();
        if (Player.Points >= 3 && Player.FatiguePoints < RealCap)
        {
            Player.Points -= 3;
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
            Player.Points += 5;
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
        if (Player.Points >= 5 && Player.BasicSpeed + 0.25 <= RealCap)
        {
            Player.Points -= 5;
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
            Player.Points += 5;
            Player.BasicMove -= 1;
        }
    
        return nil;
    }
    Right()
    {
        local RealCap = Player.BasicSpeed.getFloor() + 3;
        if (Player.Points >= 5 && Player.BasicMove < RealCap)
        {
            Player.Points -= 5;
            Player.BasicMove += 1;
        }
    
        return nil;
    }
}

PlayerCreateMenu_Done  : ExMenuItem
{
    name = 'Done'
    Select()
    {
        return true;
    }
}