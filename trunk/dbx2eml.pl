#!/usr/bin/perl -W

# dbx2eml.pl - rips Outlook Express mailboxes to folders containing .eml files.

# USAGE: dbx2eml.pl <filename> [<filename2>...<filenameN>]
# REQUIRES: Mail::Transport::Dbx, File::Path
# AUTHOR: Colin Moller <colin@unixarmy.com>
# URL: http://code.google.com/p/dbx2eml/
# LICENSE: BSD
# Copyright (c) 2010 Colin Moller
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of Colin Moller nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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


