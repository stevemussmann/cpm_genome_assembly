#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

if( scalar( @ARGV ) == 0 ){
	&help;
	die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'f:h', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $file ) = &parsecom( \%opts );

# make output file name
my @temp = split( /\./, $file );
my $suffix = pop( @temp );
push( @temp, "longest" );
push( @temp, $suffix );
my $outname = join( '.', @temp );

# reads whole file into memory
my %content; #hash that holds all contents of fasta file
&filetohash( $file, \%content );

#open output file for writing
open( OUT, '>', $outname ) or die "Can't open $outname: $!\n\n";

#traverse hash data structure to find longest transcripts
foreach my $gene( sort keys %content ){
	my $nTranscripts = keys(%{$content{$gene}}); #get number of transcripts per gene
	if( $nTranscripts > 1 ){
		my %lens; #hold lengths of transcripts
		foreach my $trans( sort keys %{$content{$gene}} ){
			my $len = length( $content{$gene}{$trans} ); #get length of transcript
			push( @{$lens{$len}}, $trans );
		}

		##find length of the longest transcript
		my @lenArray;
		#sort transcript lengths and put into array
		foreach my $translen( sort {$a <=> $b} keys %lens ){
			push( @lenArray, $translen );
		}
		my $longest = pop( @lenArray ); #pop off last element of array (longest transcript)

		my @keep = @{$lens{$longest}}; #keep array of the longest transcripts

		my $retain = $keep[0]; #if there were multiple transcripts with the same greatest length, keep the first in the list.

		print OUT $retain, "\n"; #print fasta header for retained transcript
		print OUT $content{$gene}{$retain}, "\n"; #print sequence
	}else{
		#in all other cases there is a single transcript. Print that transcript.
		foreach my $trans( sort keys %{$content{$gene}} ){
			print OUT $trans, "\n"; #print header
			print OUT $content{$gene}{$trans}, "\n"; #print sequence
		}
	}
}

#close output file
close OUT;

#print Dumper(\%content);

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{

	print "\ngetLongestTranscript.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -f | -h ]\n\n";
	print "\t-f:\tSpecify the input transcript file in fasta format.\n\n";
	print "\t-h:\tUse this flag to display this help message.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{

	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
	my $file = $opts{f} || die "Specify transcript file in fasta format."  ; #used to specify input transcript filename.

	return( $file );

}

#####################################################################################################
# subroutine to put fasta file into a hash structure

sub filetohash{

	my( $infile, $hashref ) = @_;


	# open the input file
	open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

	# loop through input file, pushing lines onto array
	my $currentHeader; #holds name (i.e., fasta header) of current transcript
	my $currentGene; #holds name of current gene
	while( my $line = <FILE> ){
		chomp( $line ); #strip end of line characters
		next if($line =~ /^\s*$/); #skip blank lines
		if( $line =~ /^>/ ){
			$currentHeader = $line; #reset current transcript name
			my @splitHeader = split( /\s+/, $line );
			$currentGene = $splitHeader[1]; #get the current gene name
			#print $currentHeader, "\n", $currentGene, "\n"
		}else{
			$$hashref{$currentGene}{$currentHeader} .= $line #accounts for fasta split across multiple lines. If transcript name does not change this appends sequence to current transcript.
		}
	}

	# close input file
	close FILE;

}

#####################################################################################################
