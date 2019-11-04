-- Globals

tabData 		= nil;
focus 			= false;

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
	checkEmpty();
	saveValue();
end

-- To get to the onClickRelease function

function onClickDown( button, x, y )
	return true;
end

-- When tab is clicked, tell tabber we want to change to this tab

function onClickRelease( button, x, y )
	if button == 1 then
		Interface.findWindow("Tabber", "").switchTab( self );
	end
end

-- On drag

function onDragStart( button, x, y, dragdata )
	dragdata.createBaseData();
	dragdata.setType( "taborder" );
	dragdata.setNumberData( tabData["order"] );
	dragdata.setStringData( getName() );
	dragdata.setDescription( tabData["text"] );
	return true;
end

-- On drop

function onDrop( x, y, dragdata )
	if dragdata.getType() == "taborder" then
		Interface.findWindow("Tabber", "").changeOrder( 
			getName(), 
			tabData["order"], 
			dragdata.getStringData(), 
			dragdata.getNumberData() 
			);
	end
end

-- Load the data passed to the tab into the tabData variable

function load( data )
	tabData = data;
	setValue( tabData["text"] )
end

-- Set up the tabData variable as needed

function new( text, data, order )
	data[getName()] = {}

	tabData = data[getName()];
	tabData["init"] = {};
	tabData["data"] = {};
	tabData["order"] = order;
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
	setBackColor( "#FF222222" );
	setColor("#FFDDDDDD");
	focus = true;
end

-- Lose focus by saving all current windows and closing them, setting colour to original state

function loseFocus()
	saveAllWindows();
	closeAllWindows();
	setBackColor( "#FF333333" );
	setColor("#FFCCCCCC");
	focus = false;
end

-- On tab hover

function onHover( state )
	if not focus then
		if state then
			setBackColor("#FF2B2B2B");
		else
			setBackColor("#FF333333");
		end
	end
end

-- Store window data inside of the tabData

function storeWindow( window )
	tabUtil.storeWindow( window, tabData );
end

-- Remove a window from the tabData

function removeWindow( window )
	tabUtil.removeWindow( window, tabData );
end

-- Save all windows to the tabData

function saveAllWindows()
	tabUtil.saveAllWindows( tabData );
end

-- Close all windows currently open

function closeAllWindows()
	tabUtil.closeAllWindows( tabData );
end

-- Load all the windows contained inside the dataData

function loadAllWindows()
	tabUtil.loadAllWindows( tabData );
end

-- Capture data passed to a window when it is loaded. Requires manual overide of XML to get function data.

function captureData( data )
	return tabUtil.captureData( data, tabData );
end