-- Globals

tabData 		= nil;
recentWindow 	= nil;

-- Register menu items

function onInit()
	registerMenuItem("Rename Tab", "edit", 5);
	registerMenuItem("Delete Tab", "delete", 4);
end

-- On select edit, set tab to be readable and current setFocus
-- On select delete, tell tabber to remove this tab

function onMenuSelection( selection )
	if selection == 5 then
		setReadOnly( false );
		setFocus( true );
	end
	if selection == 4 then
		Interface.findWindow("Tabber", "").deleteTab( self );
	end
end

-- On enter while in focus, set read only and save the current value

function onEnter()
	setReadOnly( true );
	checkEmpty();
	saveValue();
end

-- On lose tab focus, set read only and set tab to the old value

function onLoseFocus()
	setReadOnly( true );
	setValue( tabData["text"] )
end

-- When tab is clicked, tell tabber we want to change to this tab

function onClickDown( button, x, y )
	if button == 1 then
		Interface.findWindow("Tabber", "").changeTab( self );
	end
end

-- Load the data passed to the tab into the tabData variable

function load( data )
	tabData = data;
	setValue( tabData["text"] )
end

-- Set up the tabData variable as needed

function new( text )
	tabData = {};
	tabData["init"] = {};
	tabData["data"] = {};
	tabData["text"] = text;
	setValue( text );
end

-- If field is empty, set unnamed

function checkEmpty()
	if getValue() == "" then
		setValue( "Unnamed" );
	end
end

-- Save the value of the tab into the text data

function saveValue()
	tabData["text"] = getValue();
end

-- Gain focus by changing BG colour and loading all windows

function gainFocus()
	loadAllWindows();
	etBackColor("#FF222222");
	setColor("#FFDDDDDD");
end

-- Lose focus by saving all current windows and closing them, setting colour to original state

function loseFocus()
	saveAllWindows();
	closeAllWindows();
	setBackColor("#FF333333");
	setColor("#FFCCCCCC");
end

-- Store window data inside of the tabData

function storeWindow( window )
	tabberUtil.storeWindow( window, tabData );
end

-- Remove a window from the tabData

function removeWindow( window )
	tabberUtil.removeWindow( window, tabData );
end

-- Save all windows to the tabData

function saveAllWindows()
	tabberUtil.saveAllWindows( tabData );
end

-- Close all windows currently open

function closeAllWindows()
	tabberUtil.closeAllWindows( tabData );
end

-- Load all the windows contained inside the dataData

function loadAllWindows()
	tabberUtil.loadAllWindows( tabData );
end

-- Capture data passed to a window when it is loaded. Requires manual overide of XML to get function data.

function captureData( data )
	tabData["init"][recentWindow] = data;
	return data;
end