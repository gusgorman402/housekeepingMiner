#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::Fasta;
use Bio::Factory::EMBOSS;
use strict;

my $polyA;
my $fiveMar;
my $threeMar;
my $destable;
my $islands;
my $GCcontent;
my $infile = Bio::SeqIO->new( -file => "human_5.fa", format => 'fasta' );
my $threeDB = Bio::DB::Fasta->new( "human_3.fa" );
my $threeTeDB = Bio::DB::Fasta->new( "human_3_te.fa" );
my $emboss = new Bio::Factory::EMBOSS;

open( OUTTIE, ">human.output" );
while( my $seq = $infile->next_seq )
{
    my $transID = $seq->display_id;
    my $isDone = `grep -c $transID output.lst`;
    if( $isDone == 0 )
    {
    my $threeSeq = $threeDB->get_Seq_by_id( $transID );
    if( $threeSeq->seq =~ /Sequence unavailable/ ){ $threeSeq = $threeTeDB->get_Seq_by_id( $transID ) }

    $seq->desc =~ /(\d*)\|(\d*)\|(\d*)\|(ENSG\d+)\|(.*)\|(.*)/;
    my $cds_length = $1;
    my $cdna_length = $3 - $2;
    my $geneID = $4;
    my $geneDesc = $5;
    my $geneName = $6;
    if( $geneDesc =~ /(.*\S*)\s*\[.+\]/ ){ $geneDesc = $1 }

    if( $cds_length eq "" ){ $cds_length = "?" }

    my $exons = `grep -c $transID human_exon.txt`;
    chomp $exons;
    if( $exons == 0 ){ $exons = "?" }

    if( $seq->seq =~ /(A{18,}|T{18,})/ ){ $polyA = "yes" }
    else{ $polyA = "no" }

    if( $seq->seq =~ /(CCG\w\w){2,5}/ ){ $destable = "yes" }
    else{ $destable = "no" }

    my $marscan = $emboss->program('marscan');
    my %input = ( -sequence => $seq, -outfile => "$transID.5.mar" );
    $marscan->run(\%input);
    my $mars = `grep -c marscan $transID.5.mar`;
    chomp $mars;
    if( $mars > 0 ){ $fiveMar = "yes" }
    else{ $fiveMar = "no" }
    
    %input = ( -sequence => $threeSeq, -outfile => "$transID.3.mar" );
    $marscan->run(\%input);
    $mars = `grep -c marscan $transID.3.mar`;
    chomp $mars;
    if( $mars > 0 ){ $threeMar = "yes" }
    else{ $threeMar = "no" }

    my $gc = $emboss->program('geecee');
    %input = ( -sequence => $seq, -outfile => "$transID.gc" );
    $gc->run(\%input);
    my $content = `grep $transID $transID.gc`;
    chomp $content;
    $content =~ /$transID\s+(\S+)/;
    $GCcontent = $1;

    my $islander = $emboss->program('newcpgreport');
    %input = ( -sequence => $seq,
               -window => 100,
               -shift => 1,
               -minlen => 200,
               -minoe => 0.6,
               -minpc => 50,
               -outfile => "$transID.island" );
    $islander->run(\%input);
    my $tmp = `grep -c "no islands detected" $transID.island`;
    chomp $tmp;
    if( $tmp == 1 ){ $islands = 0 }
    else
    {
        $tmp = `grep numislands $transID.island`;
        $tmp =~ /FT\s+numislands\s+(\d+)/;
        $islands = $1;
    }
    $tmp = "rm $transID.*";
    system( $tmp );
    
    $tmp = `grep $transID Homo_sapiens.GRCh37.59.cdna.all.fa`;
    if( $tmp =~ /known/ || $tmp =~ /novel/ )
    {
    print OUTTIE "$geneID#$transID#$geneName#$geneDesc#$cdna_length#$cds_length#$exons#$threeMar#$fiveMar#$polyA#$destable#$GCcontent#$islands\n";
    }
    }
}

