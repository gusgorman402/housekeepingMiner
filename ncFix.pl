#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::Fasta;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Factory::EMBOSS;
use strict;

my $protDB = Bio::DB::Fasta->new("Homo_sapiens.GRCh37.60.pep.all.fa");
my $dnaDB = Bio::DB::Fasta->new("Homo_sapiens.GRCh37.60.cdna.all.fa");
my $blaster = Bio::Tools::Run::StandAloneBlast->new( -program => 'blastx', -F => 'F' );
my $emboss = new Bio::Factory::EMBOSS;

open( ACC, "notFound.nc" );

while( my $transID = <ACC> )
{
    chomp $transID;
    
    my $cdna = $dnaDB->get_Seq_by_id( $transID );
    my $protLine = `grep $transID Homo_sapiens.GRCh37.60.pep.all.fa`;
    if( $protLine =~ /\>(\w+)\s+.+/ )
    {
        my $protID = $1;

        my $pseq = $protDB->get_Seq_by_id( $protID );
    
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
        print "$transID $nc\n";
        my $cmd = "rm $transID.nc";
        system( $cmd );
    }
    else{ print "No protein for $transID\n" }

}
