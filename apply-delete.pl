#!/usr/bin/env perl
use strict;
use warnings;
use v5.20.1;

my $deletefile = 'out/'.`date +"%d-%m-%y"`;
chomp $deletefile;
my $deletefile_old = 'out/'.`date --date="-7 day" +"%d-%m-%y"`;
chomp $deletefile_old;

if (not -e 'out') {
    `mkdir out`;
}

if (not -e $deletefile) {
    say "no deletefile for today";
    exit -1;
}

if (not -e $deletefile_old) {
    say "no deletefile for seven days ago";
    exit -1;
}

# all users who have had a big directory today and seven days ago
my $common = `comm -1 -2 $deletefile $deletefile_old`;

# whitelist into hash map
open my $f, '<', 'whitelist.txt';
chomp(my @lines = <$f>);
close $f;
my %whitelist = map { $_ => 1 } @lines;

foreach my $d ($common) {
    chomp $d;
    if ($whitelist{$d}) {
	say "directory $d is on whitelist";
    } else {
	say "deleting $d";
	`rm -rf $d`;
    }
}
