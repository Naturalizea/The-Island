#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Actor
{
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
}