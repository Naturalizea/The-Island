#include <adv3.h>
#include <en_us.h>

class Tag : object
{
    Type = nil
    Name = nil
}

class SpeciesTag : Tag
{
    Type = 'Species'
    desc(actor)
    {
        "Species description for <<actor.theName>>.";
    }
    
    AverageHeight = 0.0;
    IgnoredGenes = [];
    
    isThisSpecies(actor)
    {
        local requiredGenes = [];
        local validGenes = [];

        forEachInstance(Gene, function(x) { if (x.RequiredSpeciesTags.indexWhich({y: y.ofKind(self)}) != nil) { requiredGenes += x; }});
        forEachInstance(Gene, function(x) { if (x.Tags.indexWhich({y: y.ofKind(self)}) != nil) { validGenes += x; }});
        
        local currentGenes = actor.Genepool;
        
        foreach(local gene in validGenes)
        {
            local isIgnoedGene = IgnoredGenes.indexWhich({x: gene.ofKind(x)});
            if (isIgnoedGene == nil)
            {
                local indexFound = currentGenes.indexWhich({x: x.ofKind(gene)});
                if (indexFound != nil)
                {
                    local requiredGene = requiredGenes.valWhich({x: x.ofKind(gene)});
                    if (requiredGene != nil)
                    {
                        requiredGenes -= requiredGene;
                    }
                    currentGenes -= currentGenes[indexFound];
                }
            }
        }
        
        if (requiredGenes.length() == 0 && currentGenes.length() == 0)
        {
            return true;
        }
        
        return nil;
    }
    
}

class HybridSubSpeciesTag : SpeciesTag
{
    Type = 'SubSpecies'
    Name = 'Hybrid'
}

TauricSubSpeciesTag : Tag
{
    Type = 'SubSpecies'
    Name = 'Tauric'
}

MerSubSpeciesTag : Tag
{
    Type = 'SubSpecies'
    Name = 'Mer'
}

class FlagTag : Tag
{
    Type = 'Flag'
}

ForTauricFlagTag : FlagTag
{
    Name = 'ForTauric'
}

ForMerFlagTag : FlagTag
{
    Name = 'ForMer'
}

class FilterTag : Tag
{
    Type = 'Filter'
    ValidTags = []
    IsGeneValid(gene) 
    {
        local validGeneTags = gene.Tags.subset({x : ValidTags.indexWhich({y : y == x})});
        
        return (validGeneTags.length() > 0);
    }
}

NormalFilterTag : FilterTag
{
    IsGeneValid(gene) 
    {
        return true;
        /*
        local allFlagTags = [];
        forEachInstance(FlagTag, {x: allFlagTags += x});
        
        local invalidGeneTags = gene.Tags.subset({x : allFlagTags.indexWhich({y : y == x})});
        
        return (invalidGeneTags.length() == 0);
        */
    }
}

MerFilterTag : FilterTag
{
    ValidTags = [ForMerFlagTag, MerSubSpeciesTag]
    Name = 'MerFilterTag'
}