#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Actor //human stats
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
    HungerRateBase = 0.0250
    HungerCap1 = 20.0000 //peckish
    HungerCap2 = 35.0000 //hungry
    HungerCap3 = 90.0000 //starving

    StrengthBase = 10.0000
    DexterityBase = 10.0000
    ConstitutionBase = 10.0000
    IntelligenceBase = 10.0000
    WisdomBase = 10.0000
    CharismaBase = 10.0000
    
    Strength = GetAdjScore(StrengthBase,StrAdj);
    Dexterity = GetAdjScore(DexterityBase,DexAdj);
    Constitution = GetAdjScore(ConstitutionBase,ConAdj);
    Intelligence = GetAdjScore(IntelligenceBase,IntAdj);
    Wisdom = GetAdjScore(WisdomBase,WisAdj);
    Charisma = GetAdjScore(CharismaBase,ChaAdj);
    
    StrAdj = 1.00
    DexAdj = 1.00
    ConAdj = 1.00
    IntAdj = 1.00
    WisAdj = 1.00
    ChaAdj = 1.00
    
    WillBonus = 0
    FortitudeBonus = 0
    ReflexBonus = 0    
    
    StrMod = CalculateModifier('Str',Strength);
    DexMod = CalculateModifier('Dex',Dexterity);
    ConMod = CalculateModifier('Con',Constitution);
    IntMod = CalculateModifier('Int',Intelligence);
    WisMod = CalculateModifier('Wis',Wisdom);
    ChaMod = CalculateModifier('Cha',Charisma);
    
    Will = WillBonus + WisMod;
    Fortitude = FortitudeBonus + ConMod;
    Reflex = ReflexBonus + DexMod;
    
    //skills
    SkillLearningRate = 0.2500
    
    SurvivalLevel = 0.0000
    SurvivalExp = 0.0000
    SurvivalBonus = WisMod + SurvivalLevel
    
    Statuses = []
    
    GetAdjScore(score,adj)
    {
        local value = new BigNumber(score*adj).getFloor();
        return value;
    }
    
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
        local result = DoCheck('Survival', SurvivalBonus, dc);
        
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
    
    HungerRate()
    {
        return HungerRateBase/ConAdj;
    }
    
    Roll(mod)
    {
        return rand(20)+1 + mod;
    }
    
    AttributeRoll()
    {
        local dice = [rand(6)+1,rand(6)+1,rand(6)+1,rand(6)+1].sort(true, { a, b: a-b });
        return (dice[1]+dice[2]+dice[3]) / 10.00;
    }
}