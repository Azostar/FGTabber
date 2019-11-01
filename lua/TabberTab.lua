canDelete = false

function onInit()
	registerMenuItem("Rename Tab", "edit", 5)
end

function onMenuSelection( selection )
	if selection == 5 then
		setReadOnly( false )
		setFocus( true )
	end
	if selection == 4 then
		Interface.findWindow("Tabber", "").deleteTab( self )
	end
end

function onEnter()
	setReadOnly( true )
	checkEmpty()
	saveValue()
end

function onLoseFocus()
	setReadOnly( true )
	checkEmpty()
	saveValue()
end

function onClickDown( button, x, y )
	if button == 1 then
		Interface.findWindow("Tabber", "").changeTab( self )
	end
end

-- Custom functions

function checkEmpty()
	if getValue() == "" then
		setValue( "Unnamed" )
	end
end

function saveValue()
	thisNode = Interface.findWindow("Tabber", "").storeTab( self )
end

function canDelete()
	canDelete = true
	registerMenuItem("Delete Tab", "delete", 4)
end