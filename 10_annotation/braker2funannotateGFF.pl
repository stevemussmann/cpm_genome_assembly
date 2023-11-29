#!/usr/bin/perl

use warnings;
use strict;

my $in = "braker.backup.gff3";
my $out = "braker.fixed.gff3";

my @lines; #holds input lines from gff3 file
my @outlines;

open( IN, $in ) or die "Can't open $in: $!\n\n";

while( my $line = <IN> ){
	chomp( $line );
	my @temp = split( /\t/, $line );
	if( $temp[2] ne "intron" ){
		push( @lines, $line );
	}
}

close IN;

my $tempgenes = "";
my @tempmrnas;
my @tempcds;
my @tempexons;

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $line( @lines ){
	my @temp = split( /\t/, $line );
	$temp[1] = "funannotate";
	# if "gene"
	if( $temp[2] eq "gene" ){
		if( $temp[8] =~ /ID=g(\d+);/ ){
			my $newnum = sprintf( "%06d", $1 );
			$temp[8] = "ID=FUN_$newnum;";
		}
		my $newstring = join( "\t", @temp );
		if( $tempgenes eq "" ){
			print OUT "##gff-version 3\n";
			$tempgenes = $newstring;
		}elsif( ($tempgenes ne $newstring) ){
			print OUT $tempgenes, "\n";
			foreach my $item( @tempmrnas ){
				print OUT $item, "\n";
				my @temp = split( /\t/, $item );
				my @trans = split( /;/, $temp[8] );
				my $searchstring = "$trans[0].exon";
				#print $searchstring, "\n";
				foreach my $item( @tempexons ){
					if( $item =~ /\Q$searchstring/ ){
						print OUT $item, "\n";
					}
				}
				$searchstring = "$trans[0].cds";
				foreach my $item( @tempcds ){
					if( $item =~ /\Q$searchstring/ ){
						print OUT $item, "\n";
					}
				}
			}
			$tempgenes=$newstring;
			@tempmrnas=();
			@tempcds=();
			@tempexons=();
		}
	}

	# if "mRNA
	if( $temp[2] eq "mRNA" ){
		if( $temp[8] =~ /ID=g(\d+)\.(t\d+)/ ){
			#print $line, "\n";
			my $newnum = sprintf( "%06d", $1 );
			my $newtrans = uc($2);
			$temp[8] = "ID=FUN_$newnum\-$newtrans;Parent=FUN_$newnum;product=hypothetical protein;";
		}
		my $newstring = join( "\t", @temp );
		push( @tempmrnas, $newstring );
		#print $newstring, "\n";
	}
	# if "CDS"
	if( $temp[2] eq "CDS" ){
		my $newlastcol;
		if( $temp[8] =~ /ID=g(\d+)\.(t\d+).CDS(\d+)/ ){
			my $newnum = sprintf( "%06d", $1 );
			my $newtrans = uc($2);
			$temp[8] = "ID=FUN_$newnum\-$newtrans\.cds;Parent=FUN_$newnum\-$newtrans;";
			$newlastcol = "ID=FUN_$newnum\-$newtrans\.exon$3;Parent=FUN_$newnum\-$newtrans;";
			#print $newlastcol, "\n";
		}
		my $newCDS = join( "\t", @temp );
		$temp[2] = "exon";
		$temp[7] = ".";
		$temp[8] = $newlastcol;
		my $newexon = join( "\t", @temp );
		push( @tempcds, $newCDS );
		push( @tempexons, $newexon );
		#print $newCDS, "\n";
		#print $newexon, "\n";
	}
}

close OUT;

exit;
