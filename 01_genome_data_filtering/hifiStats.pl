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

# declare variables
my %filehash;
my %allhash;
my %filehoa;
my @all;

# read directory contents
opendir( DIR, $dir ) or die "Can't open $dir: $!\n\n";
my @contents = readdir( DIR );

open( LOG, '>', $log ) or die "Can't open $log: $!\n\n";

# operate on fastq files
foreach my $file( @contents ){
	if( $file =~ /\.fastq$/ ){
		print "Counting reads in file $file.\n";
		open( FQ, $file ) or die "Can't open $file: $!\n\n"; 
		my $count=0;
		while( my $line = <FQ> ){
			$count++;
			chomp( $line );
			# get only lines with sequence data - should be divisible by 2 but not by 4
			if( $count%2 == 0 && $count%4 != 0 ){
				#print length($line), "\n";
				$filehash{$file}{length($line)}++;
				$allhash{length($line)}++;

				push( @{$filehoa{$file}}, length($line) );
				push( @all, length($line) );
			}
		}
		close FQ;

		# sort the array
		my @sorted = sort { $a <=> $b } @{$filehoa{$file}};

		# calculate median
		my $median;
		if( scalar(@sorted)%2 == 0 ){
			$median = ($sorted[int(scalar(@sorted)/2)] + $sorted[(int(scalar(@sorted)/2))-1])/2;
		}else{
			$median = $sorted[int(scalar(@sorted)/2)];
		}

		# calculate mean
		my $mean = sum(@sorted)/scalar(@sorted);

		# calculate standard deviation
		my $sqsum = 0;
		foreach my $val( @sorted ){
			$sqsum += ( $val ** 2 );
		}
		$sqsum /= scalar(@sorted);
		$sqsum -= ( $mean ** 2 );
		my $stdev = sqrt( $sqsum );

		# calculate min and max
		my $min = min( @sorted );
		my $max = max( @sorted );

		my $total=0;
		my $n50=0;
		my $bp = sum(@sorted);
		#I know there are more elegant methods of calculating N50, but this still works.
		for( my $i=scalar(@sorted)-1; $i>=0; $i-- ){
			$total+=$sorted[$i];
			if( $total > $bp/2 ){
				$n50=$sorted[$i];
				last;
			}
		}

		print LOG "Stats for $file:\n";
		print LOG "Reads:\t", scalar(@sorted), "\n";
		print LOG "Total Length:\t", $bp, "\n";
		print LOG "Minimum Length:\t", $min, "\n";
		print LOG "Median Length:\t", $median, "\n";
		print LOG "Mean Length:\t", $mean, "\n";
		print LOG "Standard Deviation:\t", $stdev, "\n";
		print LOG "Maximum Length:\t", $max, "\n";
		print LOG "N50:\t", $n50, "\n";
		print LOG "\n\n";
	}

}
# yeah, I know I could have made this into a subroutine but I didn't feel like referencing/dereferencing arrays and hashes in perl today.
# sort the array
my @allsorted = sort { $a <=> $b } @all;

# calculate median
my $allmedian;
if( scalar(@allsorted)%2 == 0 ){
	$allmedian = ($allsorted[int(scalar(@allsorted)/2)] + $allsorted[(int(scalar(@allsorted)/2))-1])/2;
}else{
	$allmedian = $allsorted[int(scalar(@allsorted)/2)];
}

# calculate mean
my $allmean = sum(@allsorted)/scalar(@allsorted);

# calculate standard deviation
my $allsqsum = 0;
foreach my $val( @allsorted ){
	$allsqsum += ( $val ** 2 );
}
$allsqsum /= scalar(@allsorted);
$allsqsum -= ( $allmean ** 2 );
my $allstdev = sqrt( $allsqsum );

# calculate min and max
my $allmin = min( @allsorted );
my $allmax = max( @allsorted );

my $alltotal=0;
my $alln50=0;
my $allbp = sum(@allsorted);
for( my $i=scalar(@allsorted)-1; $i>=0; $i-- ){
	$alltotal+=$allsorted[$i];
	if( $alltotal > $allbp/2 ){
		$alln50=$allsorted[$i];
		last;
	}
}

print LOG "Combined stats for all files:\n";
print LOG "Reads:\t", scalar(@allsorted), "\n";
print LOG "Total Length:\t", $allbp, "\n";
print LOG "Minimum Length:\t", $allmin, "\n";
print LOG "Median Length:\t", $allmedian, "\n";
print LOG "Mean Length:\t", $allmean, "\n";
print LOG "Standard Deviation:\t", $allstdev, "\n";
print LOG "Maximum Length:\t", $allmax, "\n";
print LOG "N50:\t", $alln50, "\n";

close LOG;

foreach my $file( sort keys %filehash ){
	my @temp = split( /\./, $file );
	pop( @temp );
	push( @temp, "hist" );
	push( @temp, "txt" );
	my $newfile = join( ".", @temp );
	open( OUT, '>', $newfile ) or die "Can't open $newfile: $!\n\n";
	foreach my $len( sort { $a <=> $b } keys %{$filehash{$file}} ){
		print OUT $len, "\t", $filehash{$file}{$len}, "\n";
	}
	close OUT;
}

my $combhist = "combinedHiFiReads.hist.txt";
open( OUT, '>', $combhist ) or die "Can't open $combhist: $!\n\n";
foreach my $len( sort { $a <=> $b } keys %allhash ){
	print OUT $len, "\t", $allhash{$len}, "\n";
}
close OUT;


#print Dumper(\%filehash);
#print Dumper(\%filehoa);

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
  print "\t-l:\tSpecify the log file that will contain output information (default = hifiStats.log).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $dir = $opts{d} || die "No input directory specified.\n\n"; #used to specify directory of hifi reads in fastq format
  my $log = $opts{l} || "hifiStats.log"; #used to specify output log file  

  return( $dir, $log );

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
