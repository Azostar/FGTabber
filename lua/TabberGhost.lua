-- This script is used to create temporary data for the client on launch. Fantasy Grounds raises issues
-- at launch when FGTabber tries to open windows before certain data nodes are set correctly. Instead,
-- we will create a temporary "ghost tab" that throws any data away at the end of the session, and is not
-- included in the list of saved tabs.

-- Global variables

tabData 		= nil;
closing 		= false;
opening 		= false;

-- Initialise the ghostData

function init( data )
	tabData = data;
	return self;
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
	if not opening then
		local class = window.getClass();
		local node = window.getDatabaseNode().getPath();
		local x,y = window.getPosition();
		local w,h = window.getSize();

		if node == nil then
			node = "";
		end

		local windowName = class .. node;
		recentWindow = windowName;

		tabData["data"][windowName] = {
			["class"] = class,
			["node"] = node,
			["position"] = {
				["x"] = x,
				["y"] = y
			},
			["size"] = {
				["width"] = w,
				["height"] = h
			}
		};
	end
end

-- Remove a window from the tabData

function removeWindow( window )
	if not closing then
		local class = window.getClass();
		local node = window.getDatabaseNode.getPath();
		local windowName = class .. node;

		tabData["data"][windowName] = nil;
		tabData["init"][windowName] = nil;
	end
end

-- Save all windows to the tabData

function saveAllWindows()
	for windowName, data in pairs( tabData["data"] ) do
		window = Interface.findWindow( data["class"], data["node"] );
		storeWindow( window );
	end
end

-- Close all windows currently open

function closeAllWindows()
	closing = true;

	for windowName, data in pairs( tabData["data"] ) do
		Interface.findWindow( data["class"], data["node"] ).close();
	end

	closing = false;
end

-- Load all the windows contained inside the dataData

function loadAllWindows()
	opening = true;

	for windowName, data in pairs( tabData["data"] ) do
		window = Interface.openWindow( data["class"], data["node"] );
		window.setPosition( data["position"]["x"], data["position"]["y"], true );
		window.setSize( data["size"]["width"], data["size"]["height"] );

		if tabData["init"][windowName] then
			window.init( tabData["init"][name] );
		end

	end

	opening = false;
end

-- Capture data passed to a window when it is loaded. Requires manual overide of XML to get function data.

function captureData( data )
	tabData["init"][recentWindow] = data;
	return data;
end