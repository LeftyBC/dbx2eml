# Introduction #

dbx2eml is a small chunk of Perl code to rip Outlook Express mailboxes to .eml files.

# Requirements #

Perl modules:
  * Mail::Transport::Dbx
  * File::Path

# Details #

Can process multiple DBX files specified from the command line.

Generally, you'll want to process Folders.dbx only, as Outlook Express stores the normal folder hierarchy there.  This will allow dbx2eml to create the corresponding folder structure on the file system, and place the .eml files in their appropriate folders.

If processing individual DBX files, the .emls will be output to the current directory.