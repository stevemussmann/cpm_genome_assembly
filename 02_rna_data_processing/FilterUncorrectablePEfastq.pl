#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
#use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
    &help;
    die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'd:D:f:F:ho:O:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line options and return values
my( $file1, $file2, $dis1, $dis2, $out1, $out2 ) = &parsecom( \%opts );

# open files for reading
open( FILE1, $file1 ) or die "Can't open $file1: $!\n\n";
open( FILE2, $file2 ) or die "Can't open $file2: $!\n\n";

# open files for writing
open( DIS1, '>', $dis1 ) or die "Can't open $dis1: $!\n\n";
open( DIS2, '>', $dis2 ) or die "Can't open $dis2: $!\n\n";
open( OUT1, '>', $out1 ) or die "Can't open $out1: $!\n\n";
open( OUT2, '>', $out2 ) or die "Can't open $out2: $!\n\n";

my $counter = 0;
my @record1;
my @record2;
my $counts1 = 0;
my $counts2 = 0;
my $kept = 0;
my $discard = 0;
my $unfix = 0;

print "\nRemoving uncorrectable sequences.";
print "Read 1 filename = $file1\n";
print "Read 2 filename = $file2\n\n";

while( defined(my $line1 = <FILE1>) and defined(my $line2 = <FILE2>) ){
	$counter++;
	chomp( $line1 );
	chomp( $line2 );
	push( @record1, $line1 );
	push( @record2, $line2 );
	if( $counter == 1 ){
		my @fragments1 = split( /\s+/, $line1 );
		my @fragments2 = split( /\s+/, $line2 );
		my $last1 = pop( @fragments1 );
		my $last2 = pop( @fragments2 );
		if( $last1 eq "unfixable_error" or $last2 eq "unfixable_error" ){
			$unfix = 1;
		}
		my @newrecord1 = splice( @fragments1, 0, 2 );
		my @newrecord2 = splice( @fragments2, 0, 2 );
		my $newstring1 = join( " ", @newrecord1 );	
		my $newstring2 = join( " ", @newrecord2 );
		$record1[0] = $newstring1;
		$record2[0] = $newstring2;
	}
	if( $counter % 4 == 0 ){
		if( $unfix == 0 ){
			$kept++;
			foreach my $record( @record1 ){
				print OUT1 $record, "\n";
			}
			foreach my $record( @record2 ){
				print OUT2 $record, "\n";
			}
		}else{
			$discard++;
			foreach my $record( @record1 ){
				print DIS1 $record, "\n";
			}
			foreach my $record( @record2 ){
				print DIS2 $record, "\n";
			}
		}
		## FASTQ record clear
		# reset counter
		$counter=0;
		$unfix=0;

		# clear arrays
		@record1 = ();
		@record2 = ();
	}
}
my $perKept = sprintf( "%.2f", ($kept/($kept+$discard))*100 );
my $perDis = sprintf( "%.2f", ($discard/($kept+$discard))*100 );
print "Number of retained read pairs = $kept ($perKept\%).\n";
print "Number of discarded read pairs = $discard ($perDis\%).\n\n";

print "Retained reads written to $out1 and $out2.\n";
print "Discarded reads written to $dis1 and $dis2.\n\n";


# close files
close FILE1;
close FILE2;
close DIS1;
close DIS2;
close OUT1;
close OUT2;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nFilterUncorrectablePEfastq.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  
  print "Program Options:\n";
  print "\t\t[ -d | -D | -f | -F | -h | -o | -O ]\n\n";
  print "\t-d:\tUse this to specify the output file name containing unfixable reads for read 1.\n";
  print "\t\t[optional] The default output uses .unfix.fq as the file extension.\n\n";

  print "\t-D:\tUse this to specify the output file name containing unfixable reads for read 2.\n";
  print "\t\t[optional] The default output uses .unfix.fq as the file extension.\n\n";

  print "\t-f:\tUse this to specify the input file name for read 1.\n";
  print "\t\tProgram will terminate if no file name is provided.\n\n";

  print "\t-F:\tUse this to specify the input file name for read 2.\n";
  print "\t\tProgram will terminate if no file name is provided.\n\n";

  print "\t-h:\tUse this command to display this help message.\n";
  print "\t\tProgram will terminate after displaying this help message.\n\n";

  print "\t-o:\tUse this to specify the output file name containing retained reads for read 1.\n";
  print "\t\t[optional] The default output uses .kept.fq as the file extension.\n\n";

  print "\t-O:\tUse this to specify the output file name containing retained reads for read 2.\n";
  print "\t\t[optional] The default output uses .kept.fq as the file extension.\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $file1 = $opts{f} or die "\nNo input file specified for read 1.\n\n";
  my $file2 = $opts{F} or die "\nNo input file specified for read 2.\n\n";

  my @root1 = split( /\./, $file1 );
  my @root2 = split( /\./, $file2 );
  my $extension1 = pop( @root1);
  my $extension2 = pop( @root2);

  my $dis1 = $opts{d} || join(".", @root1, "unfix", $extension1);
  my $dis2 = $opts{D} || join(".", @root2, "unfix", $extension2);
  my $out1 = $opts{o} || join(".", @root1, "kept", $extension1);
  my $out2 = $opts{O} || join(".", @root2, "kept", $extension2);
  
  return( $file1, $file2, $dis1, $dis2, $out1, $out2 );

}

#####################################################################################################

