-- global variables

currentTab 		= nil;
userTabs 		= nil;

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
	if selection == 5 then
		addTab();
	end
end

-- Load in order of name
-- TODO: add custom ordering a drag & drop ordering

function loadTabs()
	local order = {};

	for tabName, data in pairs( userTabs ) do
		order[ data["order"] ] = tabName;
	end

	for i, name in ipairs( order ) do
		for tabName, data in pairs( userTabs ) do
			if tabName == name then
				tab = createControl( "tabbertab", tabName );
				tab.load( data );

				if i > 1 then
					tab.setAnchor( "left", order[i - 1], "right", "absolute", 30 );
				end
			end
		end
	end
end

-- Add a new tab

function addTab()
	local tabs = getControls();
	local name = math.random();

	while( userTabs[name] ) do
		name = math.random();
	end
	
	newTab = createControl( "tabbertab", name );
	newTab.new( "New Tab", userTabs, #tabs + 1 );

	if tabs[1] then
		local lastTab = tabs[#tabs];
		newTab.setAnchor( "left", lastTab.getName(), "right", "absolute", 30 )
	end

	switchTab( newTab );
end

-- Delete passed tab

function deleteTab( tab )
	local order = {};

	for tabName, data in pairs( userTabs ) do
		order[ data["order"] ] = tabName;
	end

	for i, name in ipairs( order ) do
		if i >= userTabs[tab.getName()]["order"] then
			current = userTabs[name]["order"];
			userTabs[name]["order"] = current - 1;
		end
	end

	userTabs[tab.getName()] = nil;

	if currentTab == tab then
		switchTab( ghostTab );
	end

	reloadTabs();
end

-- Switch tabs

function switchTab( tab )
	if currentTab then
		currentTab.loseFocus();
	end

	if currentTab == tab then
		ghostTab.gainFocus()
		currentTab = ghostTab;
	else
		tab.gainFocus();
		currentTab = tab;
	end
end

-- Swap two tabs

function changeOrder( tab1, order1, tab2, order2 )
	userTabs[tab1]["order"] = order2;
	userTabs[tab2]["order"] = order1;
	reloadTabs();
end

-- Reloads all the tabs onto the bar.

function reloadTabs()
	local tabs = getControls();
	local reset = nil;

	if currentTab ~= ghostTab then
		reset = currentTab.getName();
		currentTab.loseFocus();
	end

	for i, tab in ipairs( tabs ) do
		tab.destroy();
	end

	loadTabs();

	if reset then
		tabs = getControls();

		for i, tab in ipairs( tabs ) do
			if tab.getName() == reset then
				currentTab = tab;
				currentTab.gainFocus();
			end
		end
	end
end

-- If there is a tab open, and desktop closes, save the tab

function onDesktopClose()
	currentTab.saveAllWindows();
	tabUtil.exiting();
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
	return currentTab.captureData( data );
end