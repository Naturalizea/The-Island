#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <lookup.h>

menuBanner: CustomBannerWindow
{
    bannerArgs = [nil,BannerAfter, statuslineBanner, BannerTypeText, BannerAlignTop, 90, BannerSizePercent, BannerStyleBorder + BannerStyleVScroll]
    //bannerArgs = [nil, BannerAfter, statuslineBanner, BannerTypeText, BannerAlignBottom, 10, BannerSizeAbsolute, BannerStyleBorder]
    
    isActive = nil;   
    
    showMenu(content)
    {
        if (!isActive)
        {
            activate();
        }
        
        updateContents(content);
    }
    
    clearMenu()
    {
        if (isActive)
        {
            deactivate();
        }
    }
}

class ExMenuItem : object
{
    name = 'Item'
    
    Select()
    {
        "ITEM SELECTED!";
        return true;
    }
    Right()
    {
        "RIGHT";
        return true;
    }
    Left()
    {
        "LEFT";
        return true;
    }
}

class ExMenu : object
{
    menuItems = nil;
    name = 'ExMenu'
    
    AddMenuItem(menuItem)
    {
        if (menuItems == nil) { menuItems = new LookupTable();};
        
    
        local index = menuItems.getEntryCount();
        menuItems[index] = menuItem;
    }
    
    Show(selectedIndex=0)
    {
        local menuContents = '<tab align=center>====<<name>>====';
        menuContents += '<br>';
        for (local x=0; x<menuItems.getEntryCount(); x++)
        {
            if (x==selectedIndex)
            {
                menuContents += '<b>    > <<menuItems[x].name>></b>';
            }
            else
            {
                menuContents += '    - <<menuItems[x].name>>';
            }
            menuContents += '<br>';
        }
        
        menuBanner.showMenu(menuContents);
        
        processKeyPress(selectedIndex);
    }
    
    processKeyPress(selectedIndex)
    {
        local keyPress = nil;
        while (keyPress == nil)
        {
            keyPress = inputManager.getKey(nil, nil);
            
            switch (keyPress)
            {
                case '[down]' : 
                    selectedIndex++;
                    if (selectedIndex >= menuItems.getEntryCount())
                    {
                        selectedIndex = 0;
                    }
                    Show(selectedIndex);
                    break;
                case '[up]' : 
                    selectedIndex--;
                    if (selectedIndex < 0)
                    {
                        selectedIndex = menuItems.getEntryCount()-1;
                    }
                    Show(selectedIndex);
                    break;
                case '\n' :
                    menuBanner.clearMenu();
                    if (!menuItems[selectedIndex].Select())
                    { keyPress = nil; }
                    break;
                case '[right]' :
                    menuBanner.clearMenu();
                    if (!menuItems[selectedIndex].Right())
                    { keyPress = nil; }
                    break;
                case '[left]' :
                    menuBanner.clearMenu();
                    if (!menuItems[selectedIndex].Left())
                    { keyPress = nil; }
                    break;
                case 'esc' :
                    menuBanner.clearMenu();
                    break;
                default :
                    keyPress = nil;
                    break;
                
            }   
        }
    }
}