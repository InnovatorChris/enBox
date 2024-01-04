THIS CONTAINS THREE CLASSES TO OPERATE COMBO-BOXES IN 4TH DIMENSION

There are three classes:
**cs.boxGroup** — a means by which to 'collect' these objects so as to perform a function on all of them. for example:
```4d
// in the form on load method handler:
Form.boxes:=cs.boxGroup.new() // define a boxGroup
Form.boxes.addBox(cs.box.new( ... ) ) // add the box
Form.boxes.box_Contact:=cs.box.new("box_Contact", ... ) // this is also add a box

----
can work on a group of boxes with:
Form.boxes.loadBoxes() // re-load the boxes
Form.boxes.setVisible(true) show the boxes
```

**COMBOBOX CLASSES**
**cs.box** — this is compatible with classic mode programming.
It uses orda formula to configure itself, but can access and store values directly into a [table]

**cs.enBox** — used in Orda-based programming (i.e. entities).

I tried documenting the **cs.enBox** class well enough you should be able to understand how to configure it for your needs. the instructions would apply to using cs.box for classic.

**OPERATION**
* the .boxDo() function for the boxes will handle clairvoyance and so on. If the result of the user's interaction results in a definite choice, it will automatically update the field it is operating on.
* .boxDo() will automatically ensure the choices are up-to-date when the *on getting focus* event happens. If the 'existing' value in the field is not in the list, it will lookup and automatically insert it into the list. I find this happens when I am looking at an archived record that, for instance, is for a customer that is no longer 'active' and not part of the selection.
* The foreign key and/or the foreign value (for example, the name of a city) are both automatically maintained if provided in .new( )
