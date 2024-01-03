<!-- Type your summary here -->

## cs.enBox



The `cs.enBox` class operates a comboBox on a form.

If you need to store a FOREIGN KEY to a lookup table, provide the $entityKey

If you need only to store a VALUE, provide the $entityValue

The class handles keeping the comboBox up-to-date, retrieving and storing the foreign key (i.e. updates your field), can handle situation where the current key *is not part of the selection* (could happen if, for instance, you want to show only *active* choices, and the one stored is actually *not active*). A "nothing" choice is appended at the top to let the user select 'nothing'

**Configuration** — cs.enBox.new( ) in the `Form Method`  to configure the comboBox.

cs.enBox.new($objName **:** **Text**; $entityPath **:** **Text**; $entityKey **:** **Text**; $entityValue **:** **Text**; $emptyKey **:** **Variant**; $emptyValue **:** **Variant**; $valuesFormula **:** **Object**; $lookupDataClass **:** **Text**; $lookupKey **:** **Text**; $lookupValue **:** **Text**)

| Parameter                 | Attribute      | Explanation                                                  |
| :------------------------ | -------------- | :----------------------------------------------------------- |
| **$objName**              | .name          | name of the comboBox form object                             |
| **$entityPath**           | .entityPath    | string 'formula' that evaluates into the entity (for example: "Form.en") |
| **$entityKey**            | .entityKey     | the Key Attribute stored in our entity (example: "City"; This becomes Form.en.City) |
| **$entityValue**          | .entityValue   | alternatively, you can store the textual value instead of the Key (i.e. "CityName") |
| **$emptyKey**             | .emptyKey      | what constitutes an 'empty' key (maybe Nul or 0)             |
| **$emptyValue**           | .emptyValue    | what constitutes an 'empty' value (probably "")              |
| **$valuesFormula**:Object | .valuesFormula | Formula that creates the [ { Value: Key}] collection         |
| **$lookupClass**          | .lookupClass   | DataClass of the 'lookup table'                              |
| **$lookupKey**            | .lookupKey     | Attribute in the 'lookup table' that holds the key (ex: "UUID" or "ID") |
| **$lookupValue**          | .lookupValue   | Attribute in the 'lookup table' that holds the display value (ex: "Name") |

## Example

```4d
// in Form Method, during on Load (we are storing the KEY into [Company]City). The cities are stored in the [City] table.
var $boxGroup : cs.boxGroup
Form.boxGroup:=cs.boxGroup.new()  // to hold our BOXES. This creates Form.boxes[ ] — boxGroup controller
$formula:=Formula(ds.City.all().orderBy("Name Asc").extract("Name"; "value"; "UUID"; "key"))  // returns [ { .key; .value } ]
// 'CITY' - the key is stored into [Customer]City
Form.boxGroup.box_City:=cs.enBox.new("box_City"; "Form.LB.Browser.en_edit"; "City"; ""; Null; ""; $formula; "City"; "UUID"; "Name")

```



When an entity changes, call the .load() function: Example: **Form.box_City.load()**

The class will automatically update the record key/value attributes upon *on losing focus*



**ENTITY CHANGE** then call .load() for the cs.enBox's.



| Functions                                        | Context: edit_Jobs                                           |
| :----------------------------------------------- | :----------------------------------------------------------- |
| .**show**()                                      | show the comboBox                                            |
| .**hide**()                                      | hide the comboBox                                            |
| **.en**()                                        | The entity being operated on (Evaluate(This.entityPath))     |
| .**load**()                                      | load the comboBox based on the .valuesFormula and .entity{Key} |
| Functions                                        | Context: job_EditCustomer                                    |
| .**JEC_InitializeForm**()                        | initialize the 4 FINDERs, configure form and updade it. Go to first item |
| .**JEC_Colorize**($en:Object; $nameSnippet:Text) | hide / show the $nameSnippets                                |
| .**boxDo**()                                     | operates the comboBox. Use in the object method of the comboBox |

SAMPLE COMBOBOX SCRIPT:

**var** $me **:** **cs**.enBox:=**Form**.boxGroup[**OBJECT Get name**] // the cs.enBox object. Assuming you collect all of the into 'Form.boxGroup' to keep them together

$me.*boxDo*() // operate the box

**If** (**Form event code**=On Losing Focus) // we are exitting the box. Do anything special you need to do here

...

**End if** 

