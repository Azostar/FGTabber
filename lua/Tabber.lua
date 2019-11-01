-- global variables

currentTab 		= nil;
userTabs 		= nil;
devMode 		= false;

-- Data for a temp tab
-- TODO: Make use of this tempTab skeleton

tempTab = {
	["init"] = {},
	["data"] = {},
	["text"] = ""
};

-- Init the campaign registry and register menu items.
-- Check if we're running a different version to what data is stored, if so clear the data.
-- Load tabs if the campaign registry information already exists
-- Pass functions to the required handlers

function onInit()
	registerMenuItem("New Tab", "insert", 5);

	if CampaignRegistry["Tabber"] == nil then
		CampaignRegistry["Tabber"] = {};
		CampaignRegistry["Tabber"]["version"] = getExtensionInfo( "FGTabber" )["version"];
	end

	if getExtensionInfo( "FGTabber" )["version"] ~= CampaignRegistry["Tabber"]["version"] then
		CampaignRegistry["Tabber"]["version"] = getExtensionInfo( "FGTabber" )["version"];
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

	for name,value in pairs( userTabs ) do
		num = tonumber( string.sub(name, 4) );
		table.insert( numOrder, num );
	end

	table.sort(numOrder)

	for i, order in ipairs( numOrder ) do
		for name,value in pairs( userTabs ) do
			if tonumber( string.sub( name, 4 ) ) == order then
				tab = createControl( "tabbertab", name );
				tab.load( value );
			end
		end
	end

	resetAnchors();
end

-- Add a new tab

function addTab()
	tabs = getControls();
	num = tonumber( string.sub(tabs[#tabs].getName(), 4) ) + 1;

	newTab = createControl( "tabbertab", "TAB" .. num );
	newTab.new( "New Tab " .. num );

	resetAnchors();
end

-- Delete passed tab

function deleteTab( tab )
	tab.closeAllWindows()
	tab.destroy()
	userTabs[tab.getName()] = nil

	if currentTab == tab then
		currentTab = nil
	end

	resetAnchors()
end

-- Switch tabs
-- TODO: if switched tab = current tab, return to the tempTab

function switchTab( tab )
	if currentTab then
		currentTab.loseFocus();
	end
	tab.gainFocus();
	currentTab = tab;
end

-- Resets anchors of all child tabs to stack them left

function resetAnchors()
	controls = getControls()

	for i, tab in ipairs(controls) do
		if i = 1 then
			tab.setAnchor("left", getName(), "left", "absolute", 20);
		else
			tab.setAnchor("left", controls[i-1].getName(), "right", "absolute", 30);
		end
	end
end

-- If there is a tab open, and desktop closes, save the tab

function onDesktopClose()
	if currentTab then
		currentTab.saveAllWindows()
	end
end

-- When a window opens, and we have a tab selected, save the tab

function onWindowOpened( window )
	if currentTab then
		currentTab.storeWindow( window )
	end
end

-- When a window closes, and we have a tab selected, remove the tab

function onWindowClosed( window )
	if currentTab then
		currentTab.removeWindow( window )
	end

end