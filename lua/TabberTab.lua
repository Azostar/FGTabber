-- Globals

tabData 		= nil;
recentWindow 	= nil;
closing 		= false;
opening 		= false;

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
			window.init( userTabs[tab.getName()]["init"][name] );
		end

	end

	opening = false;
end

-- Capture data passed to a window when it is loaded. Requires manual overide of XML to get function data.

function captureData( data )
	tabData["init"][recentWindow] = data;
	return data;
end