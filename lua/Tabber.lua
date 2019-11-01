currentTab = nil
mainTab = nil
userTabs = nil
switchTab = false
devMode = false
dClose = false
recentWindow = nil

function onFirstLayout()
	registerMenuItem("New Tab", "insert", 5)

	if CampaignRegistry["Tabber"] == nil then
		CampaignRegistry["Tabber"] = {}
	end

	if CampaignRegistry["Tabber"][User.getUsername()] == nil then
		devMessage( "New User Init" )

		CampaignRegistry["Tabber"][User.getUsername()] = {}
		userTabs = CampaignRegistry["Tabber"][User.getUsername()]
		createMain()
	else
		devMessage( "Registered User Init" )

		userTabs = CampaignRegistry["Tabber"][User.getUsername()]
		loadTabs()
		resetAnchors()
	end

	changeTab( mainTab )
	Interface.onWindowOpened = saveWindow
	Interface.onWindowClosed = removeWindow
	Interface.onDesktopClose = desktopClose
end

function onMenuSelection( selection )
	if selection == 5 then
		addTab()
	end
end

-- Custom functions

function devMessage( message )
	if devMode then
		Debug.console( "Tabber - " .. message )
	end
end

function createMain()
	mainTab = createControl( "tabbertab", "TAB1" )
	mainTab.setValue("Home")
	storeTab( mainTab )
	currentTab = mainTab
end

function addTab()
	devMessage( "Adding tab" )

	tabs = getControls()
	num = tonumber( string.sub(tabs[#tabs].getName(), 4) ) + 1

	newTab = createControl( "tabbertab", "TAB" .. num )
	newTab.setValue( "New Tab " .. num )
	newTab.canDelete()

	closeAllWindows( )	
	storeTab( newTab )
	tabGainFocus( newTab )
	resetAnchors()
	devMessage( "Tab added:" .. num )
end

function loadTabs()
	devMessage( "Loading tabs" )

	local num = nil
	local numOrder = {}

	for name,value in pairs(userTabs) do
		num = tonumber( string.sub(name, 4) ) 
		table.insert(numOrder, num)
	end

	table.sort(numOrder)

	for i, order in ipairs(numOrder) do
		for name,value in pairs(userTabs) do
			if tonumber( string.sub(name, 4) ) == order then
				tab = createControl( "tabbertab", name )

				if name ~= "TAB1" then 
					tab.canDelete() 
				else 
					mainTab = tab 
				end

				tab.setValue(userTabs[name]["text"])
			end
		end
	end

	currentTab = mainTab
	resetAnchors()
	devMessage( "Tabs Loaded" )
end

function storeTab( tab )
	devMessage( "Storing Tab: " .. tab.getName() )

	userTabs[tab.getName()] = {}
	userTabs[tab.getName()]["init"] = {}
	userTabs[tab.getName()]["data"] = {}
	userTabs[tab.getName()]["text"] = tab.getValue()
end

function changeTab( tab )
	devMessage( "Changing To Tab: " .. tab.getName() )

	saveAllWindows()
	switchTab = true
	closeAllWindows()
	loadAllWindows( tab )
	switchTab = false
	tabGainFocus( tab )
	devMessage( "Tab Changed" )
end

function tabGainFocus( tab )
	tabLoseFocus( currentTab )
	currentTab = tab
	currentTab.setBackColor("#FF222222")
	currentTab.setColor("#FFDDDDDD")
end

function tabLoseFocus( tab )
	currentTab.setBackColor("#FF333333")
	currentTab.setColor("#FFCCCCCC")
end

function deleteTab( tab )
	devMessage( "Deleting tab: " .. tab.getName() )

	if tab == currentTab then
		changeTab( mainTab )
	end
	userTabs[tab.getName()] = nil
	tab.destroy()
	resetAnchors()
	devMessage( "Tab Deleted" )
end

function resetAnchors()
	controls = getControls()

	for i,tab in ipairs(controls) do
		if i > 1 then
			tab.setAnchor("left", controls[i-1].getName(), "right", "absolute", 30)
		end
	end
end

function captureData( data )
	userTabs[currentTab.getName()]["init"][recentWindow] = data
	Debug.console(userTabs[currentTab.getName()]["init"])

	return data
end

function saveWindow( window )
	if not switchTab then
		devMessage( "Saving Window: " .. window.getClass() )

		local class = window.getClass()
		local node = window.getDatabaseNode()
		local nodePath = ""
		local x,y = window.getPosition()
		local w,h = window.getSize()

		if node ~= nil then
			nodePath = node.getPath()
		end

		if nodePath == "" then
			userTabs[currentTab.getName()]["data"][class] = {
				["class"] = class,
				["node"] = nodePath,
				["position"] = {
					["x"] = x,
					["y"] = y
				},
				["size"] = {
					["width"] = w,
					["height"] = h
				}
			}
			recentWindow = class
		else
			userTabs[currentTab.getName()]["data"][nodePath] = {
				["class"] = class,
				["node"] = nodePath,
				["position"] = {
					["x"] = x,
					["y"] = y
				},
				["size"] = {
					["width"] = w,
					["height"] = h
				}
			}
			recentWindow = nodePath
		end
	end
end

function removeWindow( window )
	if not switchTab and not dClose then
		devMessage( "Removing Window: " .. window.getClass() )

		if window.getDatabaseNode() == nil then
			userTabs[currentTab.getName()]["data"][window.getClass()] = nil
			userTabs[currentTab.getName()]["init"][window.getClass()] = nil
		else
			userTabs[currentTab.getName()]["data"][window.getDatabaseNode().getPath()] = nil
			userTabs[currentTab.getName()]["init"][window.getDatabaseNode().getPath()] = nil
		end
	end
end

function saveAllWindows( )
	devMessage( "Saving all windows" )

	for name, data in pairs( userTabs[currentTab.getName()]["data"] ) do
		window = Interface.findWindow( data["class"], data["node"] )
		if window ~= nil then
			saveWindow( window )
		else
			userTabs[currentTab.getName()]["data"][name] = nil
		end 
	end
end

function closeAllWindows()
	devMessage( "Closing all windows" )

	for name, window in pairs( userTabs[currentTab.getName()]["data"] ) do
		devMessage ( "Closing window: " .. name )
		Interface.findWindow( window["class"], window["node"] ).close()
	end
end

function loadAllWindows( tab )
	devMessage( "Loading all windows" )

	for name,window in pairs( userTabs[tab.getName()]["data"] ) do
		devMessage( "Loading window: " ..name)

		instance = Interface.openWindow(window["class"], window["node"])
		instance.setPosition( window["position"]["x"], window["position"]["y"], true )
		instance.setSize( window["size"]["width"], window["size"]["height"] )

		if userTabs[tab.getName()]["init"][name] ~= nil then
			Debug.console( userTabs[tab.getName()]["init"][name] )
			instance.init( userTabs[tab.getName()]["init"][name] )
		end

	end
end

function desktopClose()
	devMessage( "Desktop Closing" )

	saveAllWindows()
	dClose = true
end