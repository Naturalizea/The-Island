#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

Player: Actor
{
    BodypartTable = nil

    initiazlieBodyParts()
    {        
        BodypartTable = new LookupTable();
        
        local bp = new HumanHead();
        bp.moveInto(self);
        bp.owner = self;
        BodypartTable['HumanHead'] = bp;
        
        bp = new HumanTorso();
        bp.moveInto(self);
        bp.owner = self;
        BodypartTable['HumanTorso'] = bp;
        
        bp = new HumanArms();
        bp.moveInto(self);
        bp.owner = self;
        BodypartTable['HumanArms'] = bp;
        
        bp = new HumanLegs();
        bp.moveInto(self);
        bp.owner = self;
        BodypartTable['HumanLegs'] = bp;
        
        bp = new HumanSkin();
        bp.moveInto(self);
        bp.owner = self;
        BodypartTable['HumanSkin'] = bp;
        
        if (isHer())
        {
            bp = new HumanBreasts();
            bp.moveInto(self);
            bp.owner = self;
            BodypartTable['HumanBreasts'] = bp;
            
            bp = new HumanVagina();
            bp.moveInto(self);
            bp.owner = self;
            BodypartTable['HumanVagina'] = bp;
        }
        else
        {
            bp = new HumanPenis();
            bp.moveInto(self);
            bp.owner = self;
            BodypartTable['HumanPenis'] = bp;
        }
    }

    desc()
    {
        "Looking over yourself, you see the following: <br>";
    
        local components = contents.subset({x: x.ofKind(Component)}).sort(true, {a, b: a.orderName > b.orderName ? -1 : 1});
        
        //display each bodypart description
        foreach (local part in components)
        {
            if (canSee(part))
            {
                "<br><<part.desc>> ";  
            }
        }
    }
}



//and the core human bodyparts
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