#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

//the termite class
class Termite : UntakeableActor
{
    StrengthBase = 17.0000
    DexterityBase = 11.0000
    ConstitutionBase = 14.0000
    IntelligenceBase = 3.0000
    WisdomBase = 12.0000
    CharismaBase = 7.0000
    
    //states for termites
    //0 = idle
    //1 = out gathering food
    state = 0
    
    SetState(newstate)
    {
        switch(newstate)
        {
            case 1: //leave the mound to look for food. Return in an hour
            {
                Player.AddToSchedule(60,self,&gatherResult);
            }
        }
    }
    
    gatherResult()
    {
        "OK";
    }
    
}