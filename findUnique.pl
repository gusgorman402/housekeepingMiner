#!/usr/bin/perl -w

open( ACC, $ARGV[0] );
my @uniques;

while( my $fline = <ACC> )
{
    my $checker = 0;
    foreach my $unique (@uniques)
    {
        if( $unique eq $fline ){ $checker = 1 }
    }
    if( $checker == 0 ){ push( @uniques, $fline )}
}

print "\n";
foreach my $lines ( @uniques )
{
    chomp $lines;
    print $lines,",";
}
print "\n";
