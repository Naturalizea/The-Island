#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

TermiteSpeciesTag : SpeciesTag
{
    Type = 'Species'
    Name = 'termite'
    
    AverageHeight = 120.0;
    
    Caste = WorkerCasteGene
    
    desc(actor)
    {
        "Giant termite <<Caste.Name>>.";
    }
}

//the termite class
class Termite : Actor
{
    Tags = [TermiteSpeciesTag]
    BaseSpeciesTag = TermiteSpeciesTag
    CurrentSpeciesTag = TermiteSpeciesTag
    height = 120.00;

    StrengthBase = 17.0000
    DexterityBase = 11.0000
    ConstitutionBase = 14.0000
    IntelligenceBase = 3.0000
    WisdomBase = 12.0000
    CharismaBase = 7.0000
    
    initializeActor()
    {
        inherited();
        MakeTermite(self);
    }
}

// Quick function to instantly make an actor a human
MakeTermite(actor, Caste = 'worker')
{
    RemoveGenes(actor);
    TermiteHeadGene.AddGeneTo(actor);
}

//////////////////////////////GENES/////////////////////////////////////

TermiteHeadGene : Gene
{
    Tags = [TermiteSpeciesTag]
    RequiredSpeciesTags = [TermiteSpeciesTag]
    
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local head = new TermiteHead();
        head.moveInto(actor);
        head.owner = actor;
        return true;
    }
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local head = actor.contents.valWhich({x: x.ofKind(TermiteHead)});
            head.owner = nil;
            head.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}


class WorkerCasteGene : GenderGene
{
    Name = 'worker'
}
class KingCasteGene : GenderGene
{
    Name = 'king'
}
class QueenCasteGene : GenderGene
{
    Name = 'queen'
}

//////////////////////////////COMPONENTS////////////////////////////////

class TermiteHead : Component
{
    orderName = 'head'
    name = 'termite head'
    vocabWords = '(termite) head*heads'
    desc()
    {
        "You have a normal termite head.";
    }
}