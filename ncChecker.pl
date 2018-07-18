#!/usr/bin/perl -w

use strict;

open( ACC, "allTrans.arff" );
my $hitcounter;
my $counter;

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /ENSG\d+\#(ENST\d+)\#.+/;
    $counter++;

    my $num = `grep -c $1 human.nc`;
    if( $num < 1 )
    {
        print $1,"\n";
        $hitcounter++;
    }

}

print "$counter $hitcounter\n";
