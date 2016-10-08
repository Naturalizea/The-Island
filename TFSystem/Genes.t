#include <adv3.h>
#include <en_us.h>

// This class is used to represent a specific gene within a form.
class Gene : object
{
    Name = ''
    Tags = []
    RequiredSpeciesTags = []
    // Array of string's to represent tags associated with the gene, to more easily locate and identify
    
    AddGeneTo(actor) {}
    RemoveGeneFrom(actor) {}
}

// Method to quickly remove all genes from an actor

RemoveGenes(actor, tagfilter = nil)
{
    foreach (local gene in actor.Genepool)
    {
        if (tagfilter == nil || gene.Tags.intersect(tagfilter).length() > 0)
        {
            gene.RemoveGeneFrom(actor);
        }
    }    
    t3RunGC();
}

//TODO : Expand on how this works

class GenderGene : Gene {}

class MaleGenderGene : GenderGene
{
    AddGeneTo(actor)
    {
        actor.sex = 'male';
    }
}

class FemaleGenderGene : GenderGene
{
    AddGeneTo(actor)
    {
        actor.sex = 'female';
    }
}