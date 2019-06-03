# PdfEditBash

Bash scripts for filling in forms provided as PDF files.

## Limitations

This system does not allow for entry of multi-byte UTF-8 characters. This is because the actual edits are applied to postscript files, derived from the input PDF form, then converted back to PDF. Postscript accepts the UTF-8 but the conversion back to PDF fails.

## Alternative editing methods

[Foxit Reader](https://www.foxitsoftware.com/pdf-reader/) This is a PDF reader with limited editing capability, available for MacOs, Linux, and Windows. Unlike some other PDF editors, if you make a mistake you can undo the damage. The default text colour, light blue is useless if you print on a B&W laser printer. You can change the colour, but in the Linux version at least, there was no choice of black but there was a very dark blue which was good enough. Another issue was that it kept falling back to light blue text without any input any input from me.

[PDFescape](https://www.pdfescape.com/) You can use it on-line from a browser for free. There is also a down-loadable Windows version. The on-line editor is really excellent. Security of personal data on this system is a worry to some of us. I have no knowledge if the worry is justified or not. 

## Platforms supported

1. Linux - This has been developed on Xubuntu-18.04.
2. MacOs - It has Bash by default I believe, if so there should be no problem.
3. Windows 10 - [Install a Linux Distribution](https://www.windowscentral.com/how-install-linux-distros-windows-10) Bash will be installed as part of it.
4. Windows Earlier Versions - [Install Cygwin](https://cygwin.com/install.html).

## Required Software

1. Poppler-utils - available from your software repository.
2. Ghostscript - as above.
3. Pdftk - on my system I used `sudo snap install pdftk`and that worked fine. It is also available on Github if need be.

## Read Further?

If you intend to create your own data set to edit a form which is not present in this site, the procedure to do so follows.

If you just need to edit a form already provided here just do this:

1. Clone this repository.
2. Copy all of the scripts into a location of your path eg */usr/local/bin/* on a Unix like system.
3. Clone the form that you want to use.
4. Follow the *README.md* for that form.

### Scripts


The following scripts exist.

- *pe_initform.sh* - run this in a directory containing only 1 PDF file, the form as published by the party to whom the completed form is submitted. It creates some initial data files.
- *pe_datanames.sh* - creates the names of the required data files.
- *pe_calcpoints.sh* - converts your measured distances to the entry field on the form, in points. Distance known as X is measured from the left of the form, and Y from the bottom.

+ *pe_formdata.sh* - interactive script to make the form data from users measurements.
+ *pe_editps.sh* - script splits the PDF into single pages, converts those pages to postscript and applies the form data to edit those file. The postscript files are then converted back to PDF and re-assembled into a complete document.
+ *pe_updatetext.sh* - interactive script to change the text of the fields of the PDF form.

NB the file that describes the form data comprises 5 fields of comma separated fields per line of:
+ Comment entry - mimics the data names of the original form.
+ X - the distance in *points* from the left side of the form, to place the *text*.
+ Y - the distance in *points* from the bottom of the form, to the *text*.

- Text - the actual text to enter into the form field.

- Selector - text that usually has the value 'stable' or 'variable'. Stable data is of course personal identifying data, names, date of birth, and passport numbers. Variable data may be stuff like submission date for the form, dates of arrival, dates of departure and so on.

Since the data file comprises lines of simple ASCII data, 1 line per field on the form, it is quite in order to make changes to the data file using your favorite editor, rather than using the *pe_updatetext.sh* script. You may also construct your data file the same way, possibly after entering the first line using *pe_formdata.sh*

### Procedure

1. In an empty directory move or copy an empty, unfilled PDF form. This copy will never be altered in any way by the editing procedures.
2. Run *pe_initform.sh*. It will create 3 files, __pdfname__, __burst.lst__ and __toedit.lst__, the last 2 of which  contain identical lists of file names initially. The naming will be as follows, if the original PDF is called _theform.pdf_, then that name is recorded in __pdfname__, and the other 2 contain the names of all the burst single page PDF files named as  *theform_1.pdf*,  *theform_2.pdf*, ...   *theform_N.pdf*. As it happens, not every PDF page needs to be edited because often there is one or more pages containing nothing but instructions to the user. So it is the users job to delete the names of the pages that are not to be edited from **toedit.lst**.
3. Run *pe_datanames.sh* - for each PDF name in __toedit.lst__, this creates an empty file with the extension **.dat** instead of **.pdf**.
4. For each of the data files created, run *pe_formdata.sh* **filename.dat**
   - Name the target after text on the form.
   - Measure the distance from the left of the form to the input field (X).
   - Measure the distance from the bottom of the form to the input field (Y).
   - *pe_calcpoints.sh* X Y. This will print the X and Y values in points. As installed the inputs are required to be in centimeters and decimals, eg 10.55. You may alter the script to change the default units, or use options to chose the unit of measure to use. *pe_calcpoints.sh* -h to get more information. Enter the X and Y values.
   - Enter the text field data. If you intend to publish the form data for this particular PDF use generic data rather than personal data, eg 'Surname' for a surname field and so on.
   - The last field to enter is the Selector field. If you are running the entry script you will be prompted with 'stable variable' to erase one of the words. You may choose to erase both and enter any text that you like.
   - Once you have a line or two entered this way, you may find it more expedient to just use your favourite text editor to complete your data file or files.
5. *pe_editps.sh* There is no need to enter any file names here. All of that was set up when *pe_initform.sh* was run. View the completed PDF in your viewer of choice and adjust the X and Y point sizes as needed.
6. I'd recommend having your new form data under control of *git*, *git init* to start the process. Leave the generic form with the impersonal data in *branch master* and make new branches as needed, say *mine*, *his*  and *hers* or similar.
7. Working in a git branch suitable for installing real personal data into the data files. You can do this with *pe_updatetext.sh* **filename.dat**. Run without options you will be presented with the text of every field to change, delete, or select one or more words from a presented list. Should you decide that the content of a field is not needed just enter an underscore, '_'. It will be converted internally into a space. This is particularly useful for forms with Mr, Mrs, and Miss selections which may work by dropping 'X' on a check box to show what your title is, or sometimes by placing 'X' to cross out the titles you have not.
8. You can also use  *pe_updatetext.sh* using options.
   + *pe_updatetext.sh -S* presents the data lines having selection text 'stable'.
   + *pe_updatetext.sh -v* presents the data lines having selection text 'variable'.
   + *pe_updatetext.sh -s your_text* presents the data lines having selection text of any value that you chose to put there.
9. You may also just edit the data file say **filename.dat** by just opening it up in a text editor. In such a case, when you want a field to be absent from an edit do not insert '_' in the text field, instead insert one space between the commas around the text field, eg `Mr,59,774, ,stable`
