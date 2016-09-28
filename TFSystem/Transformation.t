#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

// This class is used to represent a mutation of some sort
class Transformation : object
{
    RequiredGenesForFilter = []
    SubTransformations = []
    filterTag = nil
    
    name = 'Unnamed transformation'
    
    filterTagExpiry = nil
    
    IsValid(actor, appliedFilterTag = nil, extraAllowedGenes = [])
    {
        local geneCount = actor.Genepool;
        
        if (appliedFilterTag == nil)
        {
            appliedFilterTag = filterTag;
        }

        //remove allowed and required
        local requiredGenes = RequiredGenesForFilter.subset({x : x[1] == appliedFilterTag});

        if (requiredGenes.length == 0)
        {
            //filter not valid
            return nil;
        }
        requiredGenes = requiredGenes[1][2];
        
        local actorGender = geneCount.subset({x : x.ofKind(GenderGene) });
        local actorGenderTypes = [];
        actorGender.forEach({x : actorGenderTypes = actorGenderTypes.appendUnique(x.getSuperclassList()[1].getSuperclassList())});
        local requiredGender = requiredGenes.subset({x : x.ofKind(GenderGene) });
        requiredGender = requiredGenes.subset({x : actorGenderTypes.indexWhich({y :x.ofKind(y) == nil})});
        
        geneCount = geneCount.subset({x : requiredGenes.indexWhich({y :x.ofKind(y)}) == nil});
        geneCount = geneCount.subset({x : extraAllowedGenes.indexWhich({y :x.ofKind(y)}) == nil});
        geneCount = geneCount.subset({x : requiredGender.indexWhich({y :x.ofKind(y)}) == nil});
        return geneCount.length >= 1;
        
    }
    
    GetValidFilters(actor)
    {
        local allFilters = [];
        forEachInstance(FilterTag, {x: allFilters += x});
        local validFilters = [];
        
        foreach(local filter in allFilters)
        {
            local validWithFilter = IsValid(actor, filter);

            if (!validWithFilter)
            {
                foreach (local subTF in SubTransformations)
                {
                    local subCheck = subTF.IsValid(actor, filter);
                    if (subCheck)
                    {
                        validWithFilter = subCheck;
                        break;
                    }
                }
            }
            
            if (validWithFilter)
            {
                validFilters = validFilters.appendUnique([filter]);
            }
        }
        
        return validFilters;
    }
    
    TryTransformation(actor, filterTag = nil)
    {
        //TODO : Fix this expiry thingie.
        if (filterTagExpiry == nil)
        {
            if (filterTag != nil)
            {
                self.filterTag = filterTag;
                filterTagExpiry = true;                
            }
            else
            {            
                local possibleFilters = GetValidFilters(actor); //should always have at least one
                
                if (possibleFilters.length() == 0)
                    return true;
                
                self.filterTag = possibleFilters[rand(possibleFilters.length)+1]; 
                filterTagExpiry = true;
            }
            
            
        }

        local requiredGenes = RequiredGenesForFilter.subset({x : x[1] == self.filterTag});
        if (requiredGenes.length >= 1)
        {
            requiredGenes = requiredGenes[1][2];
        }
        
        //filter out gender based on the actors current gender genes
        local actorGender = actor.Genepool.subset({x : x.ofKind(GenderGene) });
        local actorGenderTypes = [];
        actorGender.forEach({x : actorGenderTypes = actorGenderTypes.appendUnique(x.getSuperclassList()[1].getSuperclassList())});
        local requiredGender = requiredGenes.subset({x : x.ofKind(GenderGene) });
        requiredGender = requiredGenes.subset({x : actorGenderTypes.indexWhich({y :x.ofKind(y)}) == nil && x.ofKind(GenderGene)});
        
        requiredGenes = requiredGenes.subset({x : requiredGender.indexWhich({y :x.ofKind(y)}) == nil});
        
        //todo : gender tf?

        local validSubTFs = SubTransformations.subset({x : x.IsValid(actor, self.filterTag, requiredGenes)});
        
        if (validSubTFs.length() > 0)
        {
            local randomSub = validSubTFs[rand(validSubTFs.length)+1];
            return randomSub.(&TryTransformation)(actor, self.filterTag);
        }
        
        if (requiredGenes.length == 0)
        {
            return nil;
        }
        
        local currentGenes = actor.Genepool;        
        local genesToRemove = currentGenes.subset({x : requiredGenes.indexWhich({y :x.ofKind(y)}) == nil});
        local genesToAdd = requiredGenes.subset({x : currentGenes.indexWhich({y :y.ofKind(x)}) == nil});
    
        //let the transformation sort through the genes
        
        if ((genesToAdd + genesToRemove).length >= 1)
        {        
            ApplyTransformation(actor,genesToAdd,genesToRemove);
        }
        
        UpdateHeight(actor);        
        
        return true;
    }
    
    UpdateHeight(actor)
    {
        local currentHeight = actor.height;
        local newHeight = 0.0;
        local newWidth = 0.0;
        
        local speciesGenes = [];
        actor.Genepool.forEachAssoc({x, y: y.Tags.forEachAssoc({a, b: speciesGenes += b})});
        speciesGenes = speciesGenes.subset({x: x.Type == 'Species'});
        
        local uniqueSpeciesGenes = speciesGenes.getUnique();
        
        foreach (local gene in uniqueSpeciesGenes)
        {
            local percentage = actor.GetPercentageOfSpecies(gene, speciesGenes);
            newHeight = newHeight + new BigNumber((gene.AverageHeight * (percentage/100.0)) * (actor.heightVariance/100.0)).roundToDecimal(2);
        }
        
        if (newHeight > currentHeight)
        {
            " You have also grown taller by about <<newHeight-currentHeight>>cm.";
        }
        else if (newHeight < currentHeight)
        {
            " You have also grown shorter by about <<currentHeight-newHeight>>cm.";
        }
        
        actor.height = newHeight;
    }
    
    ApplyTransformation(actor,newGenes,oldGenes)
    {
        "<font color=red>WARNING: ApplyTransformation on <B><<(self.name)>></b> not defined. No transformation applied.</font>";
    }
}