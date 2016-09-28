#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify actor
{
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
    
    //skills
    SkillLearningRate = 0.2500
    
    SurvivalLevel = 0.0000
    SurvivalExp = 0.0000
    SurvivalMod = WisMod + SurvivalLevel
    
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
    
    SurvivalCheck(dc)
    {
        local result = DoCheck('Survival', SurvivalMod, dc);
        
        SurvivalExp += (1.0000 / (SurvivalLevel+1.0000)) * SkillLearningRate;
        if (SurvivalExp >= 1)
        {
            "<font color=blue> [Your <b>survival</b> is now level <b><<spellInt(toInteger(SurvivalLevel+1))>></b>.] </font>";
            SurvivalExp = 0.0000;
            SurvivalLevel++;
        }
        
        
        return result;        
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
}