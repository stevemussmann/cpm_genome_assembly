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
getopts( 'b:f:ho:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $blast, $fasta, $out ) = &parsecom( \%opts );

my @bLines;
my @fLines;

my %fHash;

&filetoarray( $blast, \@bLines );
&filetoarray( $fasta, \@fLines );

foreach my $line( @bLines ){
	my @temp = split( /\t/, $line );
		$fHash{$temp[0]}++;
}

# printer switch to control whether record is printed to filtered file. 0 = print off; 1 = print on
my $printer = 0;

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

foreach my $line( @fLines ){
	if( $line =~ /^>/ ){
		my @temp = split( /\s+/, $line );
		$temp[0] =~ s/^>//g;
		if( exists( $fHash{$temp[0]} ) ) {
			#print $temp[0], "\n";
			$printer=0;
		}else{
			$printer=1;
			print OUT $line, "\n";
		}
	}else{
		if( $printer == 1 ){
			print OUT $line, "\n";
		}
	}
}

close OUT;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{

  print "\nfilterBlastMatch.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -b | -f | -h | -o ]\n\n";
  print "\t-b:\tSpecify the BLAST output in tabular format (-outfmt 6) (required).\n\n";
  print "\t-f:\tSpecify the input FASTA file (required).\n\n";
  print "\t-h:\tDisplay this help message and exit.\n\n";
  print "\t-o:\tSpecify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".filtered.fa\" will be appended to the input FASTA file name.\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{

  my( $params ) =  @_;
  my %opts = %$params;

  # set default values for command line arguments
  my $blast = $opts{b} || die "No BLAST result file specified.\n\n";
  my $fasta = $opts{f} || die "No FASTA file specified.\n\n";
  my $out = $opts{o} || "$fasta";

  my @temp = split( /\./, $out );
  pop( @temp );
  push( @temp, "filtered");
  push( @temp, "fa");
  $out = join( ".", @temp );

  return( $blast, $fasta, $out );

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
