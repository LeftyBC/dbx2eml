#!/usr/bin/perl -W

# dbx2eml.pl - rips Outlook Express mailboxes to folders containing .eml files.

# USAGE: dbx2eml.pl <filename> [<filename2>...<filenameN>]
# REQUIRES: Mail::Transport::Dbx, File::Path
# AUTHOR: Colin Moller <colin@unixarmy.com>
# LICENSE: None.  Do with it what you will, just don't complain to me if it breaks your entire universe.

use strict;

use Mail::Transport::Dbx;
use File::Path qw(make_path);

sub getEmail {
    my $msg = shift;
    my $path = shift;

    if (length($path) < 1) { $path = "." };

    my $subject = $msg->subject;
    my $filename = $subject . ".eml";
    my $filepath = $path . "/" . $filename;
    my $messagecontent = $msg->header . "\n\n" . $msg->body;

    print "\t* Got a message with subject '" . $subject . "' of length " . length($messagecontent) . "\n";

    # write to a .eml file
    open (EMLFILE, ">>$filepath");
    print EMLFILE $messagecontent;
    close (EMLFILE);
}

print "dbx2eml - rips Outlook Express mailboxes to folders containing .eml files.\n";

if ($#ARGV < 1) {
    print "USAGE: $0 <filename> [<filename2>..<filenameN>]\n";
}

foreach my $fname (@ARGV) {
    print "Processing " . $fname . "...\n";

    my $dbx = eval { Mail::Transport::Dbx->new("$fname") };
    die $@ if $@;

    if ($dbx->emails) {
        for my $emls ($dbx->emails) {
            getEmail($emls,"."); 
        }
    } else {
        for my $sub ($dbx->subfolders) {
            if (my $d = $sub->dbx) {
                print "*** recursing into " . join("/", $sub->folder_path) . ": \n";

                # make this folder if it doesn't exist
                my $this_path = join("/",$sub->folder_path);
                make_path($this_path);

                for my $msg ($d->emails) {
                    getEmail($msg,$this_path);
                }
            } else {
                print "Subfolder " . join("/", $sub->folder_path) . " referenced but does not exist, skipping.\n";
            }
        }
    }
}


