# ScriptsBash
Bash scripts for operating on data files belonging to particular forms.
There will be the following scripts produced.
+ _makedata.sh_ - interactive script to make the form data from users measurements.
+ _editps.sh_ - script splits the pdf into single pages, converts those pages to postscript and applies the form data to edit those file. The postscript files are then converted back to pdf and re-assembled into a complete document.
+ _updatetext.sh_ - interactive script to change the text of the fields of the pdf form.
+ _updatexy.sh_ - interactive script to change the position of the form elements.

NB the file that describes the form data comprises 4 fields of comma separated fields per line of:
+ Comment entry - mimics the data names of the original form.
+ X - the distance in points from the left side of the form, to place the _text_.
+ Y - the distance in points from the bottom of the form, to the _text_.
+ Text - the actual text to enter into the form field.

Since the data file comprises lines of simple ASCII data, 1 line per field on the form, it is quite in order to make changes to the
data file using your favorite editor, rather than using the _update*.sh_ scripts.
