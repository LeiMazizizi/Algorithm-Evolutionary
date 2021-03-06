#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;

my $file = shift || die "No file, no joy\n";

my @rows = read_file( $file );

my $count;
my $max = -1;
grep( $max=($_ > $max )?$_:$max, @rows );
grep( $count += ($_ == $max ), @rows );

print "Reached max: $count\n";
