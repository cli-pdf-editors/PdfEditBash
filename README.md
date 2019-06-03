# PdfEditBash

Bash scripts for filling in forms provided as PDF files.

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
3. Run *pe_datanames.sh* - for for each PDF name in __toedit.lst__, there will created an empty file with the extension **.dat** instead of **.pdf**.
