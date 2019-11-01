-- global variables

currentTab 		= nil;
userTabs 		= nil;
devMode 		= false;

-- Init the campaign registry and register menu items.
-- Check if we're running a different version to what data is stored, if so clear the data.
-- Load tabs if the campaign registry information already exists
-- Pass functions to the required handlers

function onInit()
	registerMenuItem("New Tab", "insert", 5);

	local tabberVersion = Extension.getExtensionInfo( "FGTabber" )["version"];

	if CampaignRegistry["Tabber"] == nil then
		CampaignRegistry["Tabber"] = {};
		CampaignRegistry["Tabber"]["version"] = tabberVersion;
	end

	local registeredVersion = CampaignRegistry["Tabber"]["version"];

	if tabberVersion ~= registeredVersion then
		CampaignRegistry["Tabber"]["version"] = tabberVersion;
		CampaignRegistry["Tabber"][User.getUsername()] = nil;
	end

	if CampaignRegistry["Tabber"][User.getUsername()] == nil then
		CampaignRegistry["Tabber"][User.getUsername()] = {};
		userTabs = CampaignRegistry["Tabber"][User.getUsername()];
	else
		userTabs = CampaignRegistry["Tabber"][User.getUsername()];
		loadTabs();
	end

	Interface.onDesktopClose = onDesktopClose
	Interface.onWindowOpened = onWindowOpened
	Interface.onWindowClosed = onWindowClosed

	ghostTab.init({
		["init"] = {},
		["data"] = {}
	});
	currentTab = ghostTab;
end

-- Menu options

function onMenuSelection( selection )
	-- Add Tab
	if selection == 5 then
		addTab();
	end
end

-- Send toggled message to console

function devMessage( message )
	if devMode then
		Debug.console( "Tabber - " .. message )
	end
end

-- Load in order of name
-- TODO: add custom ordering a drag & drop ordering

function loadTabs()
	local num = nil;
	local numOrder = {};

	for tabName, data in pairs( userTabs ) do
		num = tonumber( string.sub( tabName, 4 ) );
		table.insert( numOrder, num );
	end

	table.sort(numOrder)

	for i, order in ipairs( numOrder ) do
		for tabName, data in pairs( userTabs ) do
			if tonumber( string.sub( tabName, 4 ) ) == order then
				tab = createControl( "tabbertab", tabName );
				tab.load( data );
			end
		end
	end

	resetAnchors();
end

-- Add a new tab

function addTab()
	tabs = getControls();
	
	if tabs[1] then
		num = tonumber( string.sub(tabs[#tabs].getName(), 4) ) + 1;
	else
		num = 1
	end

	newTab = createControl( "tabbertab", "TAB" .. num );
	newTab.new( "New Tab " .. num );

	switchTab( newTab )
	resetAnchors();
end

-- Delete passed tab

function deleteTab( tab )
	if currentTab == tab then
		switchTab( ghostTab )
	end

	tab.destroy()
	userTabs[tab.getName()] = nil
	resetAnchors()
end

-- Switch tabs

function switchTab( tab )
	currentTab.loseFocus();

	if currentTab == tab then
		ghostTab.gainFocus()
		currentTab = ghostTab;
	else
		tab.gainFocus();
		currentTab = tab;
	end
end

-- Resets anchors of all child tabs to stack them left

function resetAnchors()
	controls = getControls()

	for i, tab in ipairs(controls) do
		if i == 1 then
			tab.setAnchor("left", getName(), "left", "absolute", 20);
		else
			tab.setAnchor("left", controls[i-1].getName(), "right", "absolute", 30);
		end
	end
end

-- If there is a tab open, and desktop closes, save the tab

function onDesktopClose()
	currentTab.saveAllWindows();
end

-- When a window opens, and we have a tab selected, save the tab

function onWindowOpened( window )
	currentTab.storeWindow( window );
end

-- When a window closes, and we have a tab selected, remove the tab

function onWindowClosed( window )
	currentTab.removeWindow( window );
end

-- Pass captured data to the current tab

function captureData( data )
	currentTab.captureData( data );
end