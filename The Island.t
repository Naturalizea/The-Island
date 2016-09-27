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
        
        RollAbilityScores();
        
        clearScreen();
        
        DateTime._month = rand(12)+1;
        DateTime._day = rand(28)+1;
        DateTime._hour = rand(24);
        
        //place the player on a random spawn for now.
        local spawns = [];
        forEachInstance(PlayerSpawn, {x: spawns += x});
        local randomIndex = rand(spawns.length)+1;
        Player.moveIntoForTravel(spawns[randomIndex].location);
        Player.initiazlieBodyParts();
        
    }
    
    RollAbilityScores()
    {
        local accept = nil;
        
        while (!accept)
        {
            clearScreen();
            
            Player.Strength = Player.AttributeRoll();
            Player.Dexterity = Player.AttributeRoll();
            Player.Constitution = Player.AttributeRoll();
            Player.Intelligence = Player.AttributeRoll();
            Player.Wisdom = Player.AttributeRoll();
            Player.Charisma = Player.AttributeRoll();
            
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
