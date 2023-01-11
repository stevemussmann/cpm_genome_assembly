#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;

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

&filetoarray( $file, \@lines );

my $chromcount=0;
my $scaffoldcount=0;

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";
foreach my $line( @lines ){
	if( $line =~ /^>/ ){
		#print $line, "\n";
		my @header = split( /_/, $line );
		if( $header[2] < $chrom+1 ){
			$chromcount+=1;
			print OUT ">Chromosome_", $chromcount, "\n";
		}else{
			$scaffoldcount+=1;
			print OUT ">Unplaced_scaffold_", $scaffoldcount, "\n";
		}
	}else{
		print OUT $line, "\n";
	}
}
close OUT;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\nrename3d-dnaScaffolds.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -f | -h | -o ]\n\n";
	print "\t-h:\tUse this flag to display this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-o:\tUse this flag to specify the output file name.\n";
	print "\t\tIf no name is provided, the file extension \".renamed.fa\" will be appended to the input file name.\n\n";
	print "\t-f:\tUse this flag to specify the final fasta output from 3d-dna.\n\n";
	print "\t-c:\tSpecify the expected number of chromosomes. The first N scaffolds will be renamed as chromosomes (default = 25).\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
 	my $file = $opts{f} || die "No input fasta file specified.\n\n"; #used to specify input final fasta output from 3d-dna
	my $out = $opts{o} || "$file.renamed.fa"  ; #used to specify output file name.  If no name is provided, "renamed.fa" will be appended to input name
	my $chrom = $opts{c} || 25  ; # specify number of chromosomes
	
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
    #print $line, "\n";
    push( @$array, $line );
  }

  # close input file
  close FILE;

}

#####################################################################################################
