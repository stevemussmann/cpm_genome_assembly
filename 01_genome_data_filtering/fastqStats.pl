#! /usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;
use List::Util qw(sum min max);

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'd:hl:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $dir, $log ) = &parsecom( \%opts );

# read directory contents
opendir( DIR, $dir ) or die "Can't open $dir: $!\n\n";
my @contents = readdir( DIR );

open( LOG, '>', $log ) or die "Can't open $log: $!\n\n";

# operate on fastq files
foreach my $file( @contents ){
	if( $file =~ /_R1_001.fastq$/ ){
		my $len=0;
		my $seqs=0;
		print "Counting reads in file $file.\n";
		open( FQ, $file ) or die "Can't open $file: $!\n\n"; 
		my $count=0;
		while( my $line = <FQ> ){
			$count++;
			chomp( $line );
			# get only lines with sequence data - should be divisible by 2 but not by 4
			if( $count%2 == 0 && $count%4 != 0 ){
				$seqs++;
				$len+=length($line);
			}
		}
		close FQ;

		# read in paired file here
		my @temp = split( /_/, $file );
		my $tail = pop( @temp );
		pop( @temp );

		push( @temp, "R2" );
		push( @temp, $tail );
		my $newfile = join( '_', @temp );

		print "Adding length of reads in paired file $newfile.\n";
		open( FQ, $newfile ) or die "Can't open $newfile: $!\n\n";
		$count=0;
		while( my $line = <FQ> ){
			$count++;
			chomp( $line );
			if( $count%2 == 0 && $count%4 != 0 ){
				$len+=length($line);
			}
		}
		close FQ;

		print LOG "Stats for $file:\n";
		print LOG "Reads:\t", $seqs, "\n";
		print LOG "Total Length:\t", $len, "\n";
		print LOG "\n\n";
		LOG->flush;
	}

}

close LOG;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nhifiStats.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -d | -h | -l ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-d:\tSpecify the directory containing HiFi reads in fastq format.\n\n";
  print "\t-l:\tSpecify the log file that will contain output information (default = fastqStats.log).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $dir = $opts{d} || die "No input directory specified.\n\n"; #used to specify directory of hifi reads in fastq format
  my $log = $opts{l} || "fastqStats.log"; #used to specify output log file  

  return( $dir, $log );

}

#####################################################################################################
