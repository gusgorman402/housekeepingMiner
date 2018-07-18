#!/usr/bin/perl -w

use strict;

open( ACC, "allTransClean.arff" );

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /(\w+)#(\w+)#(.*#.*#.*#.*#.*#.*#.*#.*#.*#.*#.*)#(\w+)/;
    #print "$1\n$2\n$3\n$4\n\n";
    my $transID = $2;
    my $isHK = $4;
    my $string = "$1#$transID#$3#";

    my $ncLine = `grep $transID human.nc`;
    if( $ncLine =~ /protein/ )
    { 
        my $nc = "?";
        $string = $string."$nc#$isHK";
    }
    else
    {
        $ncLine =~ /ENS\w+\s+(\d+\.\d+)/;
        my $nc = $1;
        $string = $string."$nc#$isHK";
    }

    print $string,"\n";
    

}
