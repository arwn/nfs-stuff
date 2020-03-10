#!/usr/bin/env perl
use strict;
use warnings;
use v5.20.1;

use Net::SMTP;
use File::Basename;

my $smtp = Net::SMTP->new('mail.42.us.org', Port => 25) or die "can't init smtp";
# we don't need authentication if we are on the nfs server
#$smtp->starttls or die $smtp->message();
#$smtp->auth('no-reply', '') or die $smtp->message();

my $date = `date +"%d-%m-%y"`;chomp $date;

sub sendemail {
    my $username = shift;
    $smtp->mail('no-reply');
    my $send = $smtp->to("$username\@42.us.org");
    
    if (not $send) {
	say "error: ", $smtp->message();
	return;
    }

    $smtp->data() or die;
    $smtp->datasend("To: $username\@42.us.org\n") or die;
    $smtp->datasend("\n") or die;
    $smtp->datasend("this is a simple test message\n") or die;
    $smtp->dataend() or die;
}

open(my $fh, '<', 'out/'.$date) or die "can't open out/$date";

while (<$fh>) {
    my $path = $_;
    chomp $path;
    say "sending email to user: ${\basename($path)}";
    sendemail basename $path;
}

$smtp->quit;
