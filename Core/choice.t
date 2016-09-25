#charset "us-ascii"
#include <adv3.h>
#include <en_us.h>
#include <lookup.h>

choiceBanner: CustomBannerWindow 
{
    bannerArgs = [nil, BannerAfter, statuslineBanner, BannerTypeText, BannerAlignBottom, 10, BannerSizeAbsolute, BannerStyleBorder]

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

PresentChoiceFrom(choiceArray, pos, outputSelection)
{

    if (choiceArray[1].length() == 3)
    {
        choiceArray = choiceArray.sort(nil, {a, b: a[3] - b[3]});
    }
    local choiceNumber = 0;
    local choiceResults = new LookupTable();
    
    local menuContents = '';
    
    for(local x = pos; x <= pos + 8 && x <= choiceArray.length; x++)
    {
        choiceNumber++;
        menuContents += '<b><<choiceNumber>> - <<choiceArray[x][1]>></b><br>';
        
        choiceResults[toString(choiceNumber)] = choiceArray[x][2];
    }
    
    if (choiceArray.length > 9)
    {
        menuContents += '<br>';
        if (pos > 1)
        {
            menuContents += '<b>p - Previous options</b><br>';
            
            choiceResults['p'] = true;
        }
        if (choiceNumber == 9)
        {
            menuContents += '<b>m - More options</b><br>';
            
            choiceResults['m'] = true;
        }
    }
    
    menuContents += '<br>';
    
    choiceBanner.showMenu(menuContents);
    
    local keyPress = nil;
    while (keyPress == nil)
    {
        keyPress = inputManager.getKey(nil, nil);
        
        //try match choice to func
        local objToCall = choiceResults[keyPress];
        if (objToCall != nil)
        {
            //execute
            if (keyPress == 'p')
            {
                PresentChoiceFrom(choiceArray, pos - 10, outputSelection);
            }
            else if (keyPress == 'm')
            {
                PresentChoiceFrom(choiceArray, pos + 10, outputSelection);                
            }
            else
            {
                choiceBanner.clearMenu();
                if (outputSelection) { " <b><<choiceArray[toNumber(keyPress)][1]>></b>"; }
                return objToCall.(&event);
            }
        }
        else
        {
            keyPress = nil;
        }
    }
    
    choiceBanner.clearMenu();
    return nil;

}

ChooseRandomChoice(choiceArray)
{
    local randomChoiceIndex = rand(choiceArray.length)+1;
    local choiceResults = new LookupTable();
    
    for(local x = 1; x <= choiceArray.length; x++)
    {        
        choiceResults[x] = choiceArray[x][2];
    }
    local objToCall = choiceResults[randomChoiceIndex];
    return objToCall.(&event);
}

PresentChoice(choiceArray, outputSelection = true)
{
   return PresentChoiceFrom(choiceArray, 1, outputSelection);
}