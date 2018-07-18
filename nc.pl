#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::Fasta;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Factory::EMBOSS;
use strict;

my $infile = Bio::SeqIO->new( -file => "Homo_sapiens.GRCh37.60.pep.all.fa.long" );
my $dnaDB = Bio::DB::Fasta->new( "Homo_sapiens.GRCh37.59.cdna.all.fa" );
my $blaster = Bio::Tools::Run::StandAloneBlast->new( -program => 'blastx', -F => 'F' );
my $emboss = new Bio::Factory::EMBOSS;
open( OUTTY, ">human.nc" );

while( my $pseq = $infile->next_seq )
{
    $pseq->desc =~ /transcript:(\w+)/;
    my $transID = $1;
    my $isThere = `grep -c $transID Homo_sapiens.GRCh37.59.cdna.all.fa`;

    #my $cdna = $dnaDB->get_Seq_by_id( $transID );

    if( $isThere > 0 && $pseq->length > 9 )
    {
        my $cdna = $dnaDB->get_Seq_by_id( $transID );
        my $report = $blaster->bl2seq( $cdna, $pseq );
        my $result = $report->next_result;
        my $hit = $result->next_hit;
        my $hsp = $hit->next_hsp;

        my $start = $hsp->start('query');
        my $stop = $hsp->end('query');

        my $ncFinder = $emboss->program('chips');
        my %input = ( -seqall => $cdna,
                      -sbeg => $start,
                      -send => $stop,
                      -outfile => "$transID.nc" );
        $ncFinder->run(\%input);
        my $nc = `grep Nc $transID.nc`;
        $nc =~ /Nc\s*\=\s*(\S+)/;
        $nc = $1;
        #print "$start $stop ".$cdna->length."\n";
        print OUTTY "$transID $nc\n";
        my $cmd = "rm $transID.nc";
        system( $cmd );
    }
}

close( OUTTY );
