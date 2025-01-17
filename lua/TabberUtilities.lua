-- Globals

closing 		= false;
opening 		= false;
recentWindow 	= nil;

-- Get node path of passed window

function getNodePath( window )
	local node = window.getDatabaseNode();

	if node then
		return window.getDatabaseNode().getPath();
	end
	
	return "";
end

-- Store window data inside of the tabData

function storeWindow( window, tabData )
	if not opening then
		local class = window.getClass();
		local node = getNodePath( window );
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
		local node = getNodePath( window );
		local windowName = class .. node;

		tabData["data"][windowName] = nil;
		tabData["init"][windowName] = nil;
	end
end

-- Save all windows to the tabData

function saveAllWindows( tabData )
	for windowName, data in pairs( tabData["data"] ) do
		local window = Interface.findWindow( data["class"], data["node"] );

		if window then
			storeWindow( window, tabData );
		else
			clearTabEntry( windowName, tabData);
		end
	end
end

-- Close all windows currently open

function closeAllWindows( tabData )
	closing = true;

	for windowName, data in pairs( tabData["data"] ) do
		local window = Interface.findWindow( data["class"], data["node"] );

		if window then
			window.close();
		else
			clearTabEntry( windowName, tabData );
		end
	end

	closing = false;
end

-- Load all the windows contained inside the dataData

function loadAllWindows( tabData )
	opening = true;

	for windowName, data in pairs( tabData["data"] ) do
		local window = Interface.openWindow( data["class"], data["node"] );

		if window then
			window.setPosition( data["position"]["x"], data["position"]["y"], true );
			window.setSize( data["size"]["width"], data["size"]["height"] );

			if tabData["init"][windowName] then
				window.init( tabData["init"][windowName] );
			end
		else
			clearTabEntry( windowName, tabData );
		end
	end

	opening = false;
end

-- Set exiting to true

function exiting()
	closing = true
end

-- Clears the tab entry for the given window name in the tab data

function clearTabEntry( windowName, tabData )
	tabData["data"][windowName] = nil;
	tabData["init"][windowName] = nil;
end

-- Capture data passed to a window when it is loaded. Requires manual overide of XML to get function data.

function captureData( data, tabData )
	tabData["init"][recentWindow] = data;
	return data;
end