#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>

HumanSpeciesTag : SpeciesTag
{
    Type = 'Species'
    Name = 'human'
    
    AverageHeight = 170.0;
    
    desc(actor)
    {
        "You are an everyday, normal <<actor.sex>> human.";
    }
}

class Human : Actor
{
    Tags = [HumanSpeciesTag]
    BaseSpeciesTag = HumanSpeciesTag
    CurrentSpeciesTag = HumanSpeciesTag
    Height = 170.00;
    
    initializeActor()
    {
        inherited();
        MakeHuman(self);
    }
}

// Quick function to instantly make an actor a human
MakeHuman(actor, gender = FemaleGenderGene)
{
    RemoveGenes(actor);
    HumanHeadGene.AddGeneTo(actor);
    HumanTorsoGene.AddGeneTo(actor);
    HumanLegsGene.AddGeneTo(actor);
    HumanArmsGene.AddGeneTo(actor);
    HumanSkinGene.AddGeneTo(actor);
    
    switch (gender)
    {
        case FemaleGenderGene:
            actor.isHer = true;
            actor.isHim = nil;
            FemaleGenderGene.AddGeneTo(actor);
            HumanVaginaGene.AddGeneTo(actor);
            HumanBreastsGene.AddGeneTo(actor);        
            break;
        case MaleGenderGene:
            actor.isHer = true;
            actor.isHim = nil;        
            MaleGenderGene.AddGeneTo(actor);
            HumanPenisGene.AddGeneTo(actor);        
            break;
    }

}


//////////////////////////////GENES/////////////////////////////////////

HumanHeadGene : Gene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = [HumanSpeciesTag]
    
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local head = new HumanHead();
        head.moveInto(actor);
        head.owner = actor;
        return true;
    }
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local head = actor.contents.valWhich({x: x.ofKind(HumanHead)});
            head.owner = nil;
            head.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanTorsoGene : Gene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = [HumanSpeciesTag]
    
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local torso = new HumanTorso();
        torso.moveInto(actor);
        torso.owner = actor;
        return true;
    }
    RemoveGeneFrom(actor)
    {
        if (actor.Genepool.indexOf(self) != nil)
        {
            local torso = actor.contents.valWhich({x: x.ofKind(HumanTorso)});
            torso.owner = nil;
            torso.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanArmsGene : Gene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = [HumanSpeciesTag]
    
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local arms = new HumanArms();
        arms.moveInto(actor);
        arms.owner = actor;
        return true;
    }
    RemoveGeneFrom(actor)
    {
        if (actor.Genepool.indexOf(self) != nil)
        {
            local arms = actor.contents.valWhich({x: x.ofKind(HumanArms)});
            arms.owner = nil;
            arms.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanLegsGene : Gene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = [HumanSpeciesTag]
    
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local legs = new HumanLegs();
        legs.moveInto(actor);
        legs.owner = actor;
        return true;
    }
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local legs = actor.contents.valWhich({x: x.ofKind(HumanLegs)});
            legs.owner = nil;
            legs.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanSkinGene : Gene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = [HumanSpeciesTag]
        
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local skin = new HumanSkin();
        skin.moveInto(actor);
        skin.owner = actor;
        return true;
    }
    
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local skin = actor.contents.valWhich({x: x.ofKind(HumanSkin)});
            skin.owner = nil;
            skin.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanBreastsGene : FemaleGenderGene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = []
        
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local breasts = new HumanBreasts();
        breasts.moveInto(actor);
        breasts.owner = actor;
        return true;
    }
    
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local breasts = actor.contents.valWhich({x: x.ofKind(HumanBreasts)});
            breasts.owner = nil;
            breasts.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanVaginaGene : FemaleGenderGene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = []
        
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local vagina = new HumanVagina();
        vagina.moveInto(actor);
        vagina.owner = actor;
        return true;
    }
    
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local vagina = actor.contents.valWhich({x: x.ofKind(HumanVagina)});
            vagina.owner = nil;
            vagina.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

HumanPenisGene : MaleGenderGene
{
    Tags = [HumanSpeciesTag]
    RequiredSpeciesTags = []
        
    AddGeneTo(actor)
    {
        actor.Genepool += self;
        local penis = new HumanPenis();
        penis.moveInto(actor);
        penis.owner = actor;
        return true;
    }
    
    RemoveGeneFrom(actor)
    {        
        if (actor.Genepool.indexOf(self) != nil)
        {
            local penis = actor.contents.valWhich({x: x.ofKind(HumanPenis)});
            penis.owner = nil;
            penis.moveInto(nil);
            actor.Genepool -= self;
            return true;
        }
        return nil;
    }
}

//////////////////////////////COMPONENTS////////////////////////////////

class HumanHead : Component
{
    orderName = 'head'
    name = 'human head'
    vocabWords = '(human) head*heads'
    desc()
    {
        "You have a normal human head.";
    }
}

class HumanTorso : Component
{
    orderName = 'torso'
    name = 'human torso'
    vocabWords = '(human) torso*torsos'
    desc()
    {
        "You have a normal human torso.";
    }
}

class HumanArms : Component
{
    orderName = 'arms'
    name = 'human arms'
    vocabWords = '(human) arm*arms'
    isPlural = true
    desc()
    {
        "You have two, normal human arms.";
    }
}

class HumanLegs : Component
{
    orderName = 'legs'
    name = 'human legs'
    vocabWords = '(human) leg*legs'
    isPlural = true
    desc()
    {
        "You have two, normal human legs.";
    }
}

class HumanSkin : Component
{
    orderName = 'skin'
    name = 'human skin'
    vocabWords = '(human) skin'
    desc()
    {
        "You are covered in normal human skin.";
    }
}

class HumanBreasts : Component
{
    orderName = 'breasts'
    name = 'human breasts'
    vocabWords = '(human) breast*breasts'
    isPlural = true
    desc()
    {
        "You have two, normal human breasts.";
    }
}

class HumanVagina : Component
{
    orderName = 'vagina'
    name = 'human vagina'
    vocabWords = '(human) vagina/pussy/sex'
    desc()
    {
        "You have a normal, human vagina.";
    }
}

class HumanPenis : Component
{
    orderName = 'penis'
    name = 'human penis'
    vocabWords = '(human) penis/cock/dick'
    desc()
    {
        "You have a normal, human penis.";
    }
}