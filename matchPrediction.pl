#!/usr/bin/perl -w

use strict;

open( PRED, "j48result.txt" );

while( my $fline = <PRED> )
{
    chomp $fline;
    $fline =~ /\s+\d+\s+(1|2):(yes|no)\s+(1|2):(yes|no).+\((\w+)\)/;

    my $predict = $4;
    my $transID = $5;

    #print "$4 $5 \n";

    my $tranLine = `grep $transID bestOutput.human`;
    chomp $tranLine;

    if( $tranLine =~ /ENS/ )
    {
        print "$tranLine#$predict\n"

    }
}
