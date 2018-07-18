#!/usr/bin/perl -w

open( ACC, "geneListTrain.human" );

while( my $fline = <ACC> )
{
    chomp $fline;
    $fline =~ /(\w+)\s+(\w+)/;
    my $gID = $1;
    my $isHK = $2;

    my @trans = `grep $gID human.stats`;
    foreach my $tran (@trans)
    {
        chomp $tran;
        if( $tran !~ /\?/ ){ print $tran,"#$isHK\n" }
    }
}
