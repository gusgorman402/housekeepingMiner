#!/usr/bin/perl -w

use strict;

open( ACC, "human.nc" );

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /(\w+)\s+(\S+)/;
    my $tID = $1;
    my $nc = $2;

    my $geneLine = `grep $tID human.stats`;

    $geneLine =~ /(ENSG\d+)#ENST\d+#.+/;
    my $gID = $1;

    print "$gID $tID $nc\n";
}
