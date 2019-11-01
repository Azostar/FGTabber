closing 		= false;
opening 		= false;

-- Get node path of passed window

function getNodePath( window )
	node = window.getDatabaseNode();

	if node then
		return window.getDatabaseNode().getPath();
	end
	
	return "";
end

-- Store window data inside of the tabData

function storeWindow( window, tabData )
	if not opening then
		local class = window.getClass();
		local node = tabberUtil.getNodePath( window );
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

function removeWindow( window, tabData )
	if not closing then
		local class = window.getClass();
		local node = tabberUtil.getNodePath( window );
		local windowName = class .. node;

		tabData["data"][windowName] = nil;
		tabData["init"][windowName] = nil;
	end
end

-- Save all windows to the tabData

function saveAllWindows( tabData )
	for windowName, data in pairs( tabData["data"] ) do
		window = Interface.findWindow( data["class"], data["node"] );
		storeWindow( window );
	end
end

-- Close all windows currently open

function closeAllWindows( tabData )
	closing = true;

	for windowName, data in pairs( tabData["data"] ) do
		Interface.findWindow( data["class"], data["node"] ).close();
	end

	closing = false;
end

-- Load all the windows contained inside the dataData

function loadAllWindows( tabData )
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