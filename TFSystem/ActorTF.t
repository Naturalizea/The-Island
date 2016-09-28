#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

modify Actor
{
    // Array of current genes on the actor.
    Genepool = []
    
    // Array of any traits which an actor might have
    Traits = []
    
    //What is our base species?
    BaseSpeciesTag = nil
    
    //And what is our current species?
    CurrentSpeciesTag = nil
    
    heightVariance = 100.00
    height = 0.00
    sex = ''
    
    //The description of the actor (when examined)
    desc()
    {    
        local speciesGenes = [];
        Genepool.forEachAssoc({x, y: y.Tags.forEachAssoc({a, b: speciesGenes += b})});
        speciesGenes = speciesGenes.subset({x: x.Type == 'Species' || x.Type == 'Subspecies'});
        
        local uniqueSpeciesGenes = speciesGenes.getUnique();
        
        if (IsSpecies())
        {
            if (BaseSpeciesTag == CurrentSpeciesTag)
            {
                "You are a <<sex>> <<BaseSpeciesTag.Name>>.";
                
            }
            else
            {
                "You started out as a <<BaseSpeciesTag.Name>>, but currently you are a <<CurrentSpeciesTag.Name>>.";
            }
            " You are <<height>>cm tall<br>";
            "<hr>";
            CurrentSpeciesTag.desc(self);
        }
        else
        {
            local x = 1;
            
            "You started out as a <<BaseSpeciesTag.Name>>";
            if (BaseSpeciesTag != CurrentSpeciesTag)
            {
                " and was previously a <<CurrentSpeciesTag.Name>>";
            }
            ", but currently, you are a mixture of species. Specifically you are about ";
            
            foreach (local gene in uniqueSpeciesGenes)
            {
                local percentage = GetPercentageOfSpecies(gene, speciesGenes);
                if (x == 1)
                {
                    "<<percentage.formatString(4)>>% <<gene.Name>>";
                }
                else if (x != uniqueSpeciesGenes.length())
                {
                    ", <<percentage.formatString(4)>>% <<gene.Name>>";
                }
                else
                {
                    " and <<percentage.formatString(4)>>% <<gene.Name>>";
                }
                if (x == uniqueSpeciesGenes.length())
                {
                    ".";
                }                
                x++;
            }
            " You are <<height>> centermeters tall.<br>";
            
        }
        "<hr>";

        //Check the components to determine what the description should say.
        local components = contents.subset({x: x.ofKind(Component)}).sort(true, {a, b: a.orderName > b.orderName ? -1 : 1});
            
        //display each bodypart description
        foreach (local part in components)
        {
            "<<part.desc>> ";  
        }
    }
    
    
    GetPercentageOfSpecies(gene, total)
    {
        local count = total.length();
        
        local percentage = new BigNumber(total.subset({x: x.Name == gene.Name}).length());
        percentage = percentage / new BigNumber(count) * 100;
        percentage = percentage.roundToDecimal(2);
        
        return percentage;
    }
    
    IsSpecies()
    {
        local allSpecies = [];
        forEachInstance(SpeciesTag, {x: allSpecies += x});
        
        foreach (local species in allSpecies)
        {
            if (species.isThisSpecies(self))
            {
                CurrentSpeciesTag = species;
                return true;
            }
        }
        
        return nil;
    }
    
    
}