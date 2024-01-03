// Class: boxGroup — acts as a 'controller' of a group of boxes used during input.  ————
//%W-550.2 -- suppress cs.App.me ... warning
Class constructor
	
Function addBox($box : Object)  // add this to our group of ones being managed — usually cs.box
	This[$box.name]:=$box  // and add the box to the group
	
Function doBox($objName) : Boolean
	return This[$objName].boxDo()
	
Function loadBox($objName)
	This[$objName].load()  // load the single box
	
Function loadBoxes  // load all the boxes
	var $name : Text  // the name of the boxes
	For each ($name; This)
		This.loadBox($name)
	End for each 
	
Function setVisible($isVisible : Boolean)  // set the visibility of the comboBox Form objects in this group
	var $name : Text  // the name of the boxes
	For each ($name; This)
		OBJECT SET VISIBLE(*; $name; $isVisible)
	End for each 