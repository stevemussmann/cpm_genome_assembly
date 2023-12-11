#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
	&help;
	die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'c:hf:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}
# parse the command line
my( $file, $out, $chrom ) = &parsecom( \%opts );

my @lines; #holds content of input fasta file
my @chrs; #holds line content of $chrom file
my %rev; #hash of sequence names to revcom

&filetoarray( $file, \@lines );
&filetoarray( $chrom, \@chrs );

foreach my $line( @chrs ){
	$rev{$line}++;
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

for( my $i=0; $i<@lines; $i+=2 ){
	my $header = $lines[$i];
	$header =~ s/>//g;
	if( exists( $rev{$header} ) ){
		print OUT $lines[$i], "\n";
		my $revcomp = reverse( $lines[$i+1] );
		$revcomp =~ tr/ATGCatgc/TACGtacg/;
		print OUT $revcomp, "\n";
	}else{
		print OUT $lines[$i], "\n";
		print OUT $lines[$i+1], "\n";
	}
}

close OUT;

#print Dumper( \@vals );

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\nrevcomList.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -f | -h | -o ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".renamed.fa\" will be appended to the input file name.\n\n";
	print "\t-f:\tSpecify the fasta input file.\n\n";
	print "\t-c:\tSpecify a text file with list of sequences to reverse complement. One sequence name per line. Sequence names must match fasta headers.\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
 	my $file = $opts{f} || die "No input fasta file specified.\n\n"; #used to specify input fasta file
	my $out = $opts{o} || "$file.revcom.fa"  ; #used to specify output file name.  If no name is provided, "revcom.fa" will be appended to input name
	my $chrom = $opts{c} || die "No list of chromosomes to reverse complement was provided."  ; # specify list of chromosomes to reverse complement
	
	return( $file, $out, $chrom );
}
#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  
  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    push( @$array, $line );
  }

  # close input file
  close FILE;

}

#####################################################################################################
