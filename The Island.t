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
    initialPlayerChar = me
    showIntro()
    {
        randomize();
        MapGenerator.Construct();
        
        //place the player on a random spawn for now.
        local spawns = [];
        forEachInstance(PlayerSpawn, {x: spawns += x});
        local randomIndex = rand(spawns.length)+1;
        me.moveIntoForTravel(spawns[randomIndex].location);
        
    }
}


startRoom: Room 
{
    name = 'Start Room'
    desc() { "This is the starting room. "; }
}

+ me: Actor
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