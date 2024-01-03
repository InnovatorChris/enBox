/* Class: enBox — "orda" - style combo box
{    .name : TEXT — name of form object we control
     .entityPath : TEXT — evaluates into the entity (For example:  "Form.en" )
     .entityKey : TEXT  — the KEY ATTRIBUTE stored in our entity
     .entityValue : TEXT — (if used) the VALUE ATTRIBUTE stored in our entity. BLANK if the value is not stored
     .emptyKey : VARIANT — what constitutes an 'empty' key
     .emptyValue : VARIANT — what constitutes an 'empty' value
     .valuesFormula : OBJECT — Formula that creates the { Value : Key } object
     .lookupClass : TEXT — DataClass of the 'Lookup' Table (lookup table)

*/
Class constructor($objName : Text; $entityPath : Text; $entityKey : Text; $entityValue : Text; $emptyKey : Variant; $emptyValue : Variant; $valuesFormula : Object; $lookupDataClass : Text; $lookupKey : Text; $lookupValue : Text)
	This.name:=$objName  // the OBJECT NAME on the form
	This.entityPath:=$entityPath  // in the CLASSIC - style 4D, the field that this value relates to
	This.entityKey:=$entityKey
	This.entityValue:=$entityValue
	This.emptyKey:=$emptyKey  // signifies 'NOTHING'
	This.emptyValue:=$emptyValue  // signifies 'NOTHING'
	This.valuesFormula:=$valuesFormula  // the formula to collect the values. creates [ { key; Value ] }
	// —— LOOKUP 'SOURCE' INFORMATION ——
	This.lookupClass:=$lookupDataClass
	This.lookupKey:=$lookupKey
	This.lookupValue:=$lookupValue
	This.isChanged:=False  // set up this semaphore. It will be TRUE by .onLosingFocus() when things are changed, so that the object method can know and react as neede
	// define the 3 elements that make the object work on the form
	This.values:=New collection
	This.index:=0
	This.currentValue:=""
	This.keysValues:=New collection  // this [ { key: Variant; value: Text } ]
	
Function en() : 4D.Entity  // get the entity
	return Formula from string(This.entityPath).call()
	
Function setVisible($isVisible : Boolean)  // set the visibility of the comboBox Form object
	OBJECT SET VISIBLE(*; This.name; $isVisible)
	
Function show()
	OBJECT SET VISIBLE(This.name; True)
	
Function hide()
	OBJECT SET VISIBLE(This.name; False)
	
Function loadKeyValues()  // execute the FORMULA, which will return a collection [ { .key; .value } ] and which we will use in This.values[ ]
	This.keysValues:=This.valuesFormula.call(Null)  // update the .keysValues via the valuesFormula
	This.keysValues.insert(0; New object("key"; This.emptyKey; "value"; This.emptyValue))  // put an 'empty' one in there at the beginning of the list
	This.values:=This.keysValues.extract("value")  // this is JUST for the cBox
	
Function getIndexFromValue($value : Variant) : Integer  // -1 if not found
	return This.values.indexOf($value)
	
Function getIndexFromKey($key : Variant) : Integer  // -1 if not found
	If ($key=Null)  // a null key? Then we want the 'Blank' value
		return This.getIndexFromValue("")
	Else 
		return This.keysValues.findIndex("Equals"; $key; "key")  // get the index via the key
	End if 
	
Function getIndex($obKeyValue : Object) : Integer  // get based on our TYPE
	var $idx : Integer
	$idx:=This.getIndexFromKey($obKeyValue.key)
	If ($idx<0)
		$idx:=This.getIndexFromValue($obKeyValue.value)  // try from the value then
	End if 
	return $idx
	
Function getKey() : Variant
	return This.en()[This.entityKey]
	
Function getKeyAndValue() : Object  // { .key; .value }
	var $key : Variant
	var $value : Variant
	$key:=This.getKey()
	var $en : 4D.Entity
	$en:=ds[This.lookupClass].get($key)  // see if the record exists
	$value:=($en#Null) ? $en[This.lookupValue] : _Blank
	return New object("key"; $key; "value"; $value)
	
Function load()  // told to LOAD ourself based on the parameters. Will configure based on This.en(), This.entityKey
	var $obKeyValue : Object  // { .key; .value } 
	This.loadKeyValues()  // ensure this is up-to-date
	$obKeyValue:=This.getKeyAndValue()  // { .key; .value }
	$index:=This.getIndex($obKeyValue)  // lookup (either will be the KEY or the VALUE)
	If ($index<0)  // if not present, we need to add it to the front
		This.keysValues.insert(0; $obKeyValue)  // insert it into the front of our keys-values
		This.values.insert(0; $obKeyValue.value)
		$index:=0
	End if 
	// finish initializing the comboBox
	This.index:=$index
	This.currentValue:=This.keysValues[This.index].value
	
Function updateFields()  // update the KEY and/or Value fields —  This.keyPtr { and, conditionally, VALUE: This.valuePtr } fields. 
	var $en : 4D.Entity
	$en:=This.en()  // get our lookup ENTITY
	If (This.entityKey#_Blank)
		$en[This.entityKey]:=This.keysValues[This.index].key
	End if 
	If (This.entityValue#_Blank)  // if we are to store the VALUE too
		$en[This.entityValue]:=This.keysValues[This.index].value
	End if 
	
Function onGettingFocus()
	ARRAY LONGINT($events; 1)  // this should totally be unnecessary, but because On After Keystroke chooses not to fire at times, I'm trying to compensate for it.
	$events{1}:=On After Keystroke
	OBJECT SET EVENTS(*; This.name; $events; Enable events others unchanged)
	// the real code; above is weirdly 'required'???? //
	This.load()  // we ensure everything is up-to-date!
	HIGHLIGHT TEXT(*; This.name; 1; 10000)  // highlight the whole entry
	This.isChanged:=False
	
Function onLosingFocus()  // when we exit, we decide whether to update the values in our lookup
	var $obNow : Object
	If (This.index>-1)  // if an existing one is picked, return its key / value
		$obNow:=This.keysValues[This.index]
	Else   // it is a 'NEW' one.
		$obNow:=New object("key"; This.emptyKey; "value"; This.currentValue)
	End if 
	$obPresent:=This.getKeyAndValue()  // this is the present value
	This.isChanged:=(($obNow.key#$obPresent.key) | ($obNow.value#$obPresent.value))
	If ((This.isChanged) && (This.index>-1))  // a different value has been selected (or created). Update it
		This.updateFields()
	End if 
	
Function onBeforeKeystroke  // 
	var $startHighlight; $endHighlight : Integer
	GET HIGHLIGHT(*; This.name; $startHighlight; $endHighlight)
	This.beforeHighlight:=$startHighlight
	
Function onAfterKeystroke  // the first match to the input.  [lookup: cboxDo]
	var $text : Text
	$text:=Get edited text  // this is what they have in the field right now
	$charcode:=Character code(Keystroke)
	If ((Is macOS & ($charcode=8)) | ($charcode=127))  // BACKSPACE (DEL) on mac or DEL on PC?
		$text:=Delete string($text; This.beforeHighlight-1; 1)  // remove the character that did not get removed because we had highlighting
	End if 
	This.boxUpdate($text)  // set up the appearance / text highlighting
	
Function boxUpdate($text : Text) : Boolean  // update the box's selected choice, highlighting 'extra' text after determining the closest match
	If ($text=_Blank)
		This.index:=0  // choose the 'nothing' one
		This.currentValue:=""
		return 
	End if 
	// there is some sort of text. Look for it
	This.index:=This.values.indexOf($text+"@")  // search for first match
	If (This.index>-1)  // if there was a match found...
		This.currentValue:=This.values[This.index]
		OBJECT SET VALUE(This.name; This)  // this is unnecessary if the index changed, but IS NECESSARY if This.index remained the same (otherwise the highlight will not happen)
		HIGHLIGHT TEXT(*; This.name; Length($text)+1; 1000)  // highlight the rest of the text
	End if 
	
Function onClicked
	var $text : Text
	$text:=Get edited text  // this is what they have in the field right now
	This.boxUpdate($text)  // set up the appearance / text highlighting
	HIGHLIGHT TEXT(*; This.name; 1; 1000)  // highlight the entire text
	
Function boxDo()  // this performs the operation of the comboBox on-screen. Insert script as simply:  'Form.cBoxes[object get name].boxDo()'
	Case of 
		: (Form event code=On Getting Focus)
			This.onGettingFocus()
		: (Form event code=On Losing Focus)
			This.onLosingFocus()  // this will also update the KEY / VALUE fields if they have changed
		: (Form event code=On Before Keystroke)
			This.onBeforeKeystroke()  // get it all ready for the real processing that happens in On After Keystroke
		: (Form event code=On After Keystroke)
			This.onAfterKeystroke()  // handle this
			//: (Form event code=On Data Change)  // this will happen with dropdown Lists
			//: (Form event code = On After Edit) // this screws up stuff, as it triggers every time after On After Keystroke and when an menu item is selected. bad news.
		: (Form event code=On Clicked)
			This.onClicked()
	End case 
	
	