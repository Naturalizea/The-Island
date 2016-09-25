#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
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
    initialPlayerChar = player
    
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
        player.moveIntoForTravel(spawns[randomIndex].location);
        
    }
    
    RollAbilityScores()
    {
        local accept = nil;
        
        while (!accept)
        {
            clearScreen();
            
            player.Strength = player.AttributeRoll();
            player.Dexterity = player.AttributeRoll();
            player.Constitution = player.AttributeRoll();
            player.Intelligence = player.AttributeRoll();
            player.Wisdom = player.AttributeRoll();
            player.Charisma = player.AttributeRoll();
            
            "--Rolling ability scores--<br>";
            "<br>";
            "<<player.Strength>> = Strength (measures muscle and physical power)<br>";
            "<<player.Dexterity>> = Dexterity (measures agility, reflexes, and balance)<br>";
            "<<player.Constitution>> = Constitution (represents your character's health and stamina)<br>";
            "<<player.Intelligence>> = Intelligence (determines how well your character learns and reasons)<br>";
            "<<player.Wisdom>> = Wisdom (describes a character's willpower, common sense, awareness, and intuition)<br>";
            "<<player.Charisma>> = Charisma (measures a character's personality, personal magnetism, ability to lead, and appearance)<br>";
            "<br>";
            "Do you accept? ";
            accept = PresentChoice([['Yes',TrueHook],['No',FalseHook]]);
        }
    }
}


startRoom: Room 
{
    name = 'Start Room'
    desc() { "This is the starting room. "; }
}

+ player: Actor
{}



/* change the status line to display date / time. This is just a rewrite of the current statusLine, with the DateTime displayed */
modify statusLine
{
    replace showStatusHtml()
    {
        /* hyperlink the location name to a "look around" command */
        "<a plain href='<<libMessages.commandLookAround>>'>";
            
        /* show the left part of the status line */
        showStatusLeft();
            
        "</a>";

        "<tab align=center>";

        showStatusCenter();

        /* set up for the score part on the right half */
        "<tab align=right><a plain
            href='<<libMessages.commandFullScore>>'>";
        
        /* show the right part of the status line */
        showStatusRight();
        
        /* end the score link */
        "</a>";
        
        /* add the status-line exit list, if desired */
        if (gPlayerChar.location != nil)
            gPlayerChar.location.showStatuslineExits();
    }

    showStatusCenter()
    {
        "<<DateTime.ToString()>>";
    }

    replace showStatusRight()
    {
        local s;

        /* show the time and score */
        if ((s = libGlobal.scoreObj) != nil)
        {
            "<.statusscore>Score:\t<<s.totalScore>><./statusscore>";
        }
    }
}