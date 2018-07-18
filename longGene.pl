#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::Fasta;
use strict;

my $infile = Bio::SeqIO->new( -file => $ARGV[0] );
my $dbfile = Bio::SeqIO->new( -file => ">".$ARGV[0].".long", -format => 'fasta' );
my $protDB = Bio::DB::Fasta->new( $ARGV[0] );
my $outfile = "gene.index";
my @genes;
open( OUTTY, ">".$outfile );

while( my $seq = $infile->next_seq )
{
    $seq->desc =~ /gene:(\w+)\s+transcript:(\w+)/;
    my $gene = $1;
    my $cdna = $2;
    print OUTTY $gene." ".$seq->display_id." ".$cdna." ".$seq->length."\n";
    
    my $checker = 0;
    foreach my $unique ( @genes )
    {
        if( $gene eq $unique ){ $checker = 1 }
    }
    if( $checker == 0 ){ push( @genes, $gene )}

}

close( OUTTY );

foreach my $dna ( @genes )
{
    my @trans = `grep $dna $outfile`;
    my $max = 0;
    my $longprot;
    foreach my $tran ( @trans )
    {
        $tran =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\d+)/;
        if( $4 > $max )
        {
            $max = $4;
            $longprot = $2;
        }
    }
    #print $longprot,"??\n";
    my $protseq = $protDB->get_Seq_by_id($longprot);
    #print $protseq->length,"\n";
    #print $protseq->desc,"\n";
    my $desc = $protDB->header($longprot);
    #print $desc,"\n";
    $desc =~ /\w+\s+(pep:.+transcript.+)/;
    $desc = $1;

    my $newseq = Bio::Seq->new( -display_id => $protseq->display_id,
                                -desc => $desc,
                                -seq => $protseq->seq );
    $dbfile->write_seq( $newseq );
}
