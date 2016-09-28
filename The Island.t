#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <bignum.h>

versionInfo: GameID
    IFID = '31101a87-a29f-4309-bd06-41f53ef602d3'
    name = 'The Island'
    byline = 'by Naturalizea'
    htmlByline = 'by <a href="mailto:Naturalizea@gmail.com">
                  Naturalizea</a>'
    version = '1'
    authorEmail = 'Naturalizea <Naturalizea@gmail.com>'
    desc = 'Description comming soon'
    htmlDesc = 'Description comming soon'
;

gameMain: GameMainDef
{
    initialPlayerChar = Player
    
    showDiceRolls = nil;
    
    showIntro()
    {
        randomize();
        MapGenerator.Construct();
        
        "<br>Show dice rolls?";
        showDiceRolls = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
        "<br>";
        
        local choiceArray = [
            ['Male',MaleHook],
            ['Female',FemaleHook]
        ];
        "<br>Are you male or female?";
        PresentChoice(choiceArray);
        "<br>";
        
        Player.name = inputManager.getInputLine(nil, {: "<br>And what is your name? " });
        
        RollAbilityScores();
        
        clearScreen();
        
        DateTime._month = rand(12)+1;
        DateTime._day = rand(28)+1;
        DateTime._hour = 6;
        
        //place the player on a random spawn for now.
        local spawns = [];
        forEachInstance(PlayerSpawn, {x: spawns += x});
        local randomIndex = rand(spawns.length)+1;
        Player.moveIntoForTravel(spawns[randomIndex].location);
        
        //Describe the scene
        "You slowly wake up to the sound of seagulls around you. Groggily, you stand up as your brush off golden beach sand from your clothing. You appear to be alone on a beach, 
        and you have no recollection of how you would have got here.<br>
        <br>";
        
    }
    
    RollAbilityScores()
    {
        local accept = nil;
        
        while (!accept)
        {
            clearScreen();
            
            Player.StrAdj = Player.AttributeRoll();
            Player.DexAdj = Player.AttributeRoll();
            Player.ConAdj = Player.AttributeRoll();
            Player.IntAdj = Player.AttributeRoll();
            Player.WisAdj = Player.AttributeRoll();
            Player.ChaAdj = Player.AttributeRoll();
            
            "--Rolling ability scores--<br>";
            "<br>";
            "<<Player.Strength>> = Strength (measures muscle and physical power)<br>";
            "<<Player.Dexterity>> = Dexterity (measures agility, reflexes, and balance)<br>";
            "<<Player.Constitution>> = Constitution (represents your character's health and stamina)<br>";
            "<<Player.Intelligence>> = Intelligence (determines how well your character learns and reasons)<br>";
            "<<Player.Wisdom>> = Wisdom (describes a character's willpower, common sense, awareness, and intuition)<br>";
            "<<Player.Charisma>> = Charisma (measures a character's personality, personal magnetism, ability to lead, and appearance)<br>";
            "<br>";
            "Do you accept? ";
            accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
        }
    }
}
