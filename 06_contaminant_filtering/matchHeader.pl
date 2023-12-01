#!/usr/bin/perl

## This script will pull out headers of contaminant sequences and remove them from your assembly fasta file.
# Run this after running removeContamination.sh and make sure inputs are in fasta format (you might need to remove lines with "--" from the output of removeContamination.sh)

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
getopts( 'c:ho:r:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $class, $remove, $out ) = &parsecom( \%opts );

my @classLines;
my @removeLines;

my %classHash;
my %removeHash;
my %newHash;

&filetoarray( $class, \@classLines );
&filetoarray( $remove, \@removeLines );

for( my $i=0; $i<@classLines; $i+=2 ){
	$classHash{$classLines[$i]} = $classLines[$i+1];
}

for( my $i=0; $i<@removeLines; $i+=2 ){
	$removeHash{$removeLines[$i]} = $removeLines[$i+1];
}

my @keyList;
foreach my $key( sort keys %classHash ){
	push( @keyList, $key ) unless exists $removeHash{$key};
}

foreach my $key( @keyList ){
	my @temp = split( /\s+/, $key );
	my @temp2 = split( /_/, $temp[0] );
	for( my $i=0; $i<@temp2; $i++ ){
		if( $temp2[$i] =~ /^\d+$/ ){
			$temp2[$i] = sprintf('%03d', $temp2[$i]);
			#print $temp2[$i], "\n";
		}
	}
	my $newname = join("_", @temp2);
	#print $newname, "\n";
	$newHash{$newname} = $key;
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";
foreach my $key( sort keys %newHash ){
	print OUT $key, "\n";
	print OUT $classHash{$newHash{$key}}, "\n";
}
close OUT;

#print Dumper( \@keyList );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nmatchHeader.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -c | -h | -o | -r ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n\n";
  print "\t-c:\tSpecify fasta file of your classified sequences from kraken2.\n\n";
  print "\t-r:\tSpecify fasta file of your contaminant sequences to be removed from your classified sequences. Fasta headers should exactly match those in your kraken2 output (i.e., -c option input).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $class = $opts{c} || die "No classified fasta file specified.\n\n"; #used to specify input file name.
  my $remove = $opts{r} || die "No file of contaminants for removal was provided.\n\n"; #specify fasta file of contaminants
  my $out = $opts{o} || die "No output file specified." ; #used to specify output file name.

  return( $class, $remove, $out );

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
