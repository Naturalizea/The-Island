#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <lookup.h>

menuBanner: CustomBannerWindow
{
    bannerArgs = [nil,BannerAfter, statuslineBanner, BannerTypeText, BannerAlignTop, 100, BannerSizePercent, BannerStyleBorder + BannerStyleVScroll]
    //bannerArgs = [nil, BannerAfter, statuslineBanner, BannerTypeText, BannerAlignBottom, 10, BannerSizeAbsolute, BannerStyleBorder]
    
    isActive = nil;   
    
    showMenu(content)
    {
        if (!isActive)
        {
            activate();
        }
        
        if (content != nil)
        {
            updateContents(content);
        }
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
    
    parentMenu = nil;
    index = 0;
    fakeItem = nil;
    
    Select()
    {
        return nil;
    }
    Right()
    {
        return nil;
    }
    Left()
    {
        return nil;
    }
    Escape()
    {
        parentMenu.Escape();
    }
}

class ExMenu : InitObject
{
    menuItems = nil;
    name = '===ExMenu==='
    
    execute()
    {
        //implement this
    }
    
    Escape()
    {
        return true;
    }
    
    
    AddMenuItem(menuItem)
    {
        if (menuItems == nil) { menuItems = new LookupTable();};
    
        local index = menuItems.getEntryCount();
        menuItem.parentMenu = self;
        menuItem.index = index;
        menuItems[index] = menuItem;

    }
    
    Show(selectedIndex=0)
    {
        local keyPress = nil;
        while (keyPress == nil)
        {       
            local menuContents = '<tab align=center><<name>>';
            menuContents += '<hr><br>';
            for (local x=0; x<menuItems.getEntryCount(); x++)
            {
                if (menuItems[x].fakeItem)
                {
                    menuContents += '<<menuItems[x].name>>';
                }
                else
                {
                    if (x==selectedIndex)
                    {
                        menuContents += '<b>    > <<menuItems[x].name>></b>';
                    }
                    else
                    {
                        menuContents += '    - <<menuItems[x].name>>';
                    }
                }
                menuContents += '<br>';
            }
            menuContents += '<hr>';
            menuBanner.showMenu(menuContents);
            
            keyPress = inputManager.getKey(nil, nil);
            
            switch (keyPress)
            {
                case '[down]' : 
                    selectedIndex++;
                    while (selectedIndex < menuItems.getEntryCount() && menuItems[selectedIndex].fakeItem) { selectedIndex++; }
                    if (selectedIndex >= menuItems.getEntryCount())
                    {
                        selectedIndex = 0;
                    }
                    Show(selectedIndex);
                    break;
                case '[up]' : 
                    selectedIndex--;
                    while (selectedIndex >= 0 && menuItems[selectedIndex].fakeItem) { selectedIndex--; }
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
                case '[esc]' :
                    menuBanner.clearMenu();
                    if (!menuItems[selectedIndex].Escape())
                    { keyPress = nil; }
                    break;
                default :
                    keyPress = nil;
                    break;
            }   
        }
    }
}

Menu_Line : ExMenuItem
{
    name = '<hr>';
    fakeItem = true;
}