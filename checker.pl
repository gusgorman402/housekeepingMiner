#!/usr/bin/perl -w

use strict;

my $counter;
my $hit;
open( ACC, "human.nc" );
#open( OUTTY, ">humanTrain.arff" );
while( my $fline = <ACC> )
{
    $counter++;
    chomp $fline;
    $fline =~ /(\w+)\s+(\S+)/;
    my $check = `grep -c $1 humanTrain.lst`;
    #my $gID = $1;
    #my $tID = $2;
    #my $isHK = $3;

    if( $check > 0 )
    { 
        #print $1;
        $hit++;
        #print $fline,"\n";
        #my @genes = `grep $gID human.stats`;
        #my $retired = `grep $gID retired.txt`;
        #print $retired;
        #foreach my $gene (@genes)
        #{
        #    chomp $gene;
        #    if( $gene !~ /\?/ ){ print $gene,"#$isHK\n" }
        #}
        #print "\n";
    }
    else
    {
        #$hit++;
        #$check = `grep $tID human.stats`;
        #chomp $check;
        #print OUTTY $check."#".$isHK."\n";
    }
}

print "$counter $hit\n";
