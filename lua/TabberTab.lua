tabData 		= nil;
recentWindow 	= nil;
closing 		= false;
opening 		= false;

function onInit()
	registerMenuItem("Rename Tab", "edit", 5);
	registerMenuItem("Delete Tab", "delete", 4);
end

function onMenuSelection( selection )
	if selection == 5 then
		setReadOnly( false );
		setFocus( true );
	end
	if selection == 4 then
		Interface.findWindow("Tabber", "").deleteTab( self );
	end
end

function onEnter()
	setReadOnly( true );
	checkEmpty();
	saveValue();
end

function onLoseFocus()
	setReadOnly( true );
	checkEmpty();
	saveValue();
end

function onClickDown( button, x, y )
	if button == 1 then
		Interface.findWindow("Tabber", "").changeTab( self );
	end
end

-- Custom functions

function load( data )
	tabData = data;
	setValue( tabData["text"] )
end

function new( text )
	tabData = {};
	tabData["init"] = {};
	tabData["data"] = {};
	tabData["text"] = text;
	setValue( text );
end

function checkEmpty()
	if getValue() == "" then
		setValue( "Unnamed" );
	end
end

function saveValue()
	tabData["text"] = getValue();
end

function gainFocus()
	loadAllWindows();
	etBackColor("#FF222222");
	setColor("#FFDDDDDD");
end

function loseFocus()
	saveAllWindows();
	closeAllWindows();
	setBackColor("#FF333333");
	setColor("#FFCCCCCC");
end

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

function removeWindow( window )
	if not closing then
		local class = window.getClass();
		local node = window.getDatabaseNode.getPath();
		local windowName = class .. node;

		tabData["data"][windowName] = nil;
		tabData["init"][windowName] = nil;
	end
end

function saveAllWindows()
	for windowName, data in pairs( tabData["data"] ) do
		window = Interface.findWindow( data["class"], data["node"] );
		storeWindow( window );
	end
end

function closeAllWindows()
	closing = true;

	for windowName, data in pairs( tabData["data"] ) do
		Interface.findWindow( data["class"], data["node"] ).close();
	end

	closing = false;
end

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

function captureData( data )
	tabData["init"][recentWindow] = data;
	return data;
end