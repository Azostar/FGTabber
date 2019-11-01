-- This script is used to create temporary data for the client on launch. Fantasy Grounds raises issues
-- at launch when FGTabber tries to open windows before certain data nodes are set correctly. Instead,
-- we will create a temporary "ghost tab" that throws any data away at the end of the session, and is not
-- included in the list of saved tabs.

-- Global variables

tabData 		= nil;
recentWindow 	= nil;

-- Initialise the ghostData

function init( data )
	tabData = data;
end

-- Gain focus, loading all windows

function gainFocus()
	loadAllWindows();
end

-- Lose focus by saving all current windows and closing them

function loseFocus()
	saveAllWindows();
	closeAllWindows();
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