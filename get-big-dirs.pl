#!/usr/bin/env perl
use strict;
use warnings;
use v5.30.1;

use Scalar::Util qw(looks_like_number);
use File::Find;
use File::Spec;

# user arguments
my $usage = "usage: $0 base_dir depth max_directory_size_megs";
my $basedir = undef; # the directory that the deletion occurs in
my $depth = undef; # the exact depth of directories that will be checked
my $maxsize = undef; # the maximum valid size for a directory

# shit
`mkdir out` if (not -e 'out');

# create outfile
my $date = 'out/'.`date +"%d-%m-%y"`; chomp $date;
open(OUTFILE, '>'. $date) or die;

sub ifthenexit {
    if (shift) { say shift; exit -1; }
}

sub checkargs {
	($basedir, $depth, $maxsize) = @ARGV;

	ifthenexit(
	    @ARGV != 3,
	    $usage);
	
	# check if path exists
	ifthenexit(
	    not -e $basedir or not -d $basedir,
	    "directory $basedir does not exist");

	# validate depth and max size
	foreach my $e (($depth, $maxsize)) {
	    ifthenexit(
		(not looks_like_number($e)),
		"$e doesn't look like a number");
	}
}

sub dirsize {
    my $size = 0;
    find(sub { $size += -s if -f }, shift);
    return $size;
}

# walkdirs recurses on every directory (ignoring regular files) and
# calls dirsize on each to determine if it should be deleted.
sub walkdirs {
    my $dir = shift;
    my $depth = shift;
    
    if ($depth == 0) {
	$dir = File::Spec->canonpath($dir);
        my $sz = dirsize $dir;
	if ($sz > $maxsize * 1024) {
	    say OUTFILE $dir;
	    say STDERR 'LOG: '.$dir.' '.$sz.'MB'
	}
	return;
    }

    opendir(my $dh, $dir) || return;
    while (readdir $dh) {
	my $newpath = $dir . '/' . $_;
	walkdirs($newpath, $depth - 1)
	    unless ($_ eq '.' or $_ eq '..');
    }
}

checkargs;
walkdirs $basedir, $depth;
