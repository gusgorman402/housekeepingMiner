#!/usr/bin/perl -w

use strict;

open( ACC, "geneListTrain.human" );

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /(\w+)\s+\w+/;
    my $gID = $1;

    my @trans = `grep $gID Homo_sapiens.GRCh37.60.pep.all.fa | grep known`;
    if( @trans == 0 )
    {
        #print "skipping $gID\n";
        next;
    }
    my $bestTran;    
    my $oneDistance = 999999999999999;
    my $distance = 0;
    foreach my $tran (@trans)
    {
        $tran =~ /\>(ENSP\d+)\s+\w+\:known\s+\w+\:\w+\:\S+:(\d+):(\d+):(\S+)\s+gene:ENSG\d+\s+transcript:(ENST\d+).*/;
        
        my $tranID = $5;
        my $start = $2;
        my $stop = $3;
        my $frame = $4;

        if( $frame eq '1' )
        {
            if( $start < $oneDistance )
            {
                $oneDistance = $start;
                $bestTran = $tranID;
            }
        }
        if( $frame eq '-1' )
        {
            if( $stop > $distance )
            {
                $distance = $stop;
                $bestTran = $tranID;
            }
        }
    }

    my $tranLine = `grep $bestTran human.csv`;
    print $tranLine;
}
