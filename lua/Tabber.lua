-- global variables

currentTab 		= nil;
userTabs 		= nil;

-- Init the campaign registry and register menu items.
-- Check if we're running a different version to what data is stored, if so clear the data.
-- Load tabs if the campaign registry information already exists
-- Pass functions to the required handlers
function reset( version )
	CampaignRegistry["Tabber"] = {};
	CampaignRegistry["Tabber"]["version"] = version;
	CampaignRegistry["Tabber"]["hotkeys"] = {};
end

function onInit()
	registerMenuItem("New Tab", "insert", 5);

	local tabberVersion = "v0.6.6";

	if CampaignRegistry["Tabber"] == nil then
		reset( tabberVersion );
	end

	local registeredVersion = CampaignRegistry["Tabber"]["version"];

	if tabberVersion ~= registeredVersion then
		reset( tabberVersion );
	end

	if CampaignRegistry["Tabber"][User.getUsername()] == nil then
		CampaignRegistry["Tabber"][User.getUsername()] = {};
		userTabs = CampaignRegistry["Tabber"][User.getUsername()];
	else
		userTabs = CampaignRegistry["Tabber"][User.getUsername()];
		loadTabs();
	end

	Interface.onDesktopClose 	= onDesktopClose
	Interface.onWindowOpened 	= onWindowOpened
	Interface.onWindowClosed 	= onWindowClosed
	Interface.onHotkeyActivated = onHotkeyActivated
	Interface.onHotkeyDrop 		= onHotkeyDrop

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
				tab.load( data, self );

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
	local name =  "T" .. string.format( "%x", string.sub( math.random(), 3 ) );

	while( userTabs[name] ) do
		name = "T" .. string.format( "%x", string.sub( math.random(), 3 ) );
	end
	
	newTab = createControl( "tabbertab", name );
	newTab.new( "New Tab", userTabs, #tabs + 1, self );

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
	CampaignRegistry["Tabber"]["hotkeys"][tab.getName()] = nil;

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
				currentTab.setBGSelected();
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

-- When a hotkey is activated, check if it's a taborder datatype, and process it

function onHotkeyActivated( dragdata )
	if dragdata.getType() == "tabbertab" then
		local tabName = dragdata.getStringData();
		local regData = CampaignRegistry["Tabber"]["hotkeys"][tabName];

		if regData then
			local tabs = getControls();
			local swTab = nil;

			for i, tab in ipairs( tabs ) do
				if tab.getName() == tabName then
					swTab = tab;
				end
			end

			switchTab( swTab );
		end
	end
end

-- When a hotkey is dropped into a bar

function onHotkeyDrop( dragdata )
	if dragdata.getType() == "tabbertab" then
		CampaignRegistry["Tabber"]["hotkeys"][dragdata.getStringData()] = dragdata.getDescription();
	end
end

-- Pass captured data to the current tab

function captureData( data )
	return currentTab.captureData( data );
end