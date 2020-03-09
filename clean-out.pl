#!/usr/bin/env perl
use strict;
use warnings;
use v5.30.1;

opendir(DIR, 'out') or die "out: no such directory";
my %dates;

for (0 .. 30) {
    my $date = `date --date="-$_ day" +"%d-%m-%y"`;
    chomp $date;
    $dates{$date} = 1;
}

#skip over files made in the last 30 days
while (my $filename = readdir(DIR)) {
    next if ($dates{$filename});
    next if ($filename eq '.' or $filename eq '..');
    say "removing $filename";
    unlink 'out/'.$filename;
}
