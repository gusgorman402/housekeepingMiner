#!/usr/bin/perl -w

use strict;

open( ACC, "geneListTrain.human" );

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /(\w+)\s+(\w+)/;

    my $gID = $1;
    my $isHK = $2;

    my $ncLine = `grep $gID human.nc.longGene`;
    chomp $ncLine;
    if( $ncLine eq "" ){ print "$gID GENE NOT FOUND*************************************\n" }
    else
    {
        $ncLine =~ /(\w+)\s+(\w+)\s(\S+)/;
        my $tID = $2;
        my $nc = $3;

        my $statLine = `grep $tID human.stats`;
        chomp $statLine;
        $statLine .= "#$nc#$isHK\n";
        print $statLine;

    }
}
