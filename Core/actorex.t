#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Actor //Basic stats
{
    //Game stuff
    Statuses = []

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
    
}