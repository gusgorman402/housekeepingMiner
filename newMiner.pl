#!/usr/bin/perl -w

use Bio::SeqIO;
use Bio::DB::Fasta;
use Bio::Factory::EMBOSS;
use strict;

my $fiveDB = Bio::DB::Fasta->new( "human_5.fa" );
my $threeDB = Bio::DB::Fasta->new( "human_3.fa" );
my $threeTeDB = Bio::DB::Fasta->new( "human_3_te.fa" );
my $emboss = new Bio::Factory::EMBOSS;

my $polyA;
my $fiveMar;
my $threeMar;
my $destable;
my $tata;
my $spTF;
my $islands;
my $GCcontent;
my $nc;


open( GENE, "geneListTrain.human" );
open( OUTTY, ">bestOutput.human" );

while( my $fline = <GENE> )
{
    $fline =~ /(\w+)\s+(\w+)/;
    my $geneID = $1;
    my $isHK = $2;

    my @trans = `grep $geneID Homo_sapiens.GRCh37.60.cdna.all.fa | grep "known"`;

    foreach my $tran (@trans)
    {
        $tran =~ /\>(ENS\w+)\s+cdna:known\s+chromosome:\S+:\S+:\d+:\d+:(\S+)\s+gene:ENS\w+/;
        my $transID = $1;
        my $frame = $2;

        
        my $checker = `grep -c $transID human_5.fa`; chomp $checker;
        if( $checker == 0 ){ next }
        $checker = `grep -c $transID human_3.fa`; chomp $checker;
        if( $checker == 0 ){ next }

        my $fiveSeq = $fiveDB->get_Seq_by_id( $transID );
        my $threeSeq = $threeDB->get_Seq_by_id( $transID );
        if( $threeSeq->seq =~ /Sequence unavailable/ ){ $threeSeq = $threeTeDB->get_Seq_by_id( $transID ) }
        
        my $header = $fiveDB->header( $transID );

        $header =~ /\w+\s+(\d*)\|(\d*)\|(\d*)\|(ENSG\d+)\|(.*)\|(.*)/;
        my $cds_length = $1;
        my $cdna_length = $3 - $2;
        my $geneDesc = $5;
        my $geneName = $6;
        if( $geneDesc =~ /(.*\S*)\s*\[.+\]/ ){ $geneDesc = $1 }

        if( $cds_length eq "" ){ $cds_length = "?" }

        my $exons = `grep -c $transID human_exon.txt`;
        chomp $exons;
        if( $exons == 0 ){ $exons = "?" }
        
        #if( $frame eq '-1' )
        #{
        #    $fiveSeq = $fiveSeq->revcom;
        #    $threeSeq = $threeSeq->revcom;
        #}

        if( $fiveSeq->seq =~ /(A{18,}|T{18,})/ ){ $polyA = "yes" }
        else{ $polyA = "no" }
        
        my $fiveRevSeq = $fiveSeq->revcom;
        if( $fiveSeq->seq =~ /(CCG\w\w){2,5}/ || $fiveRevSeq->seq =~ /(CCG\w\w){2,5}/ )
        { $destable = "yes" }
        else{ $destable = "no" }

        if( $fiveSeq->subseq(1450,1500) =~ /TATA(A|T)A(A|T)/ ){ $tata = "yes" }
        else{ $tata = "no" }

        if( $fiveSeq->seq =~ /(G|T)GGGCGG(G|A)(G|A)(C|T)/ ){ $spTF = "yes" }
        else{ $spTF = "no" }
    
        my $marscan = $emboss->program('marscan');
        my %input = ( -sequence => $fiveSeq, -outfile => "$transID.5.mar" );
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
        %input = ( -sequence => $fiveSeq, -outfile => "$transID.gc" );
        $gc->run(\%input);
        my $content = `grep $transID $transID.gc`;
        chomp $content;
        $content =~ /$transID\s+(\S+)/;
        $GCcontent = $1;

        my $islander = $emboss->program('newcpgreport');
        %input = ( -sequence => $fiveSeq,
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

        my $ncLine = `grep $transID human.nc.longGene`;
        chomp $ncLine;
        if( $ncLine =~ /\w+\s+\w+\s+(\S+)/ ){ $nc = $1 }
        else
        {
            $ncLine = `grep $transID ncFix.output.human`;
            chomp $ncLine;
            if( $ncLine =~ /\w+\s+(\S+)/ && $ncLine !~ /protein/ ){ $nc = $1 }
            else{ $nc = "?" }
        }
    
        print OUTTY "$geneID#$transID#$geneName#$geneDesc#$cdna_length#$cds_length#$exons#$threeMar#$fiveMar#$polyA#$destable#$tata#$spTF#$GCcontent#$islands#$nc#$isHK\n";

    }
}

close( GENE );
close( OUTTY );
