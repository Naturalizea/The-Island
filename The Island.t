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
}
