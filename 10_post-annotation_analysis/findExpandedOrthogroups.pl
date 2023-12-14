#!/usr/bin/perl

use List::Util qw(reduce);
use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# take command line arguments
my %opts;
getopts( 'a:hf:F:m:o::r:q:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
	&help;
	die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $file, $out, $ref, $qry, $org, $faa, $mult ) = &parsecom( \%opts );

my @lines; #holds content of input fasta file
my @orgLines;
my %refHash;
my %qryHash;
my @orgs; # orthogroups to keep
my %orgHash;
my %keepHash; #genes from $ref fasta file to retain in final output
my @faaLines;

&filetoarray( $file, \@lines );
&filetoarray( $org, \@orgLines );
&filetoarray( $faa, \@faaLines );

my $header = shift( @lines );
my @headList = split( /\t/, $header );

my $orgHeader = shift( @orgLines );
my @orgList = split( /\t/, $orgHeader );

# parse orthogroup gene lists
foreach my $line( @orgLines ){
	my @temp = split( /\t/, $line );
	for( my $i=1; $i<@temp; $i++ ){
		$orgHash{$temp[0]}{$orgList[$i]}=$temp[$i];
	}
}

# parse orthogroup gene counts
for( my $i=0; $i<@lines; $i++ ){
	my @temp = split( /\t/, $lines[$i] );
	for( my $j=0; $j<@temp; $j++ ){
		if( $headList[$j] eq $ref ){
			$refHash{$temp[0]}=$temp[$j];
		}
		if( $headList[$j] eq $qry ){
			$qryHash{$temp[0]}=$temp[$j];
		}
	}
}

# start working here to compare query and reference using multiplier
foreach my $refG( sort keys %refHash ){
	if( ($refHash{$refG} > 1) and ($qryHash{$refG} > ($mult*$refHash{$refG}) ) ){
		print $refHash{$refG}, "\n";
		push( @orgs, $refG );
	}
}

foreach my $g( @orgs ){
	print $orgHash{$g}{$ref}, "\n";
	my @temp = split( /, /, $orgHash{$g}{$ref} );
	foreach my $item( @temp ){
		$keepHash{$item} = $g;
	}
}


open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

my $print = 0;
my $current = "";
foreach my $line( @faaLines ){
	if( $line =~ /^>/ ){
		my @temp = split( /\s+/, $line );
		$temp[0] =~ s/>//g;
		if( exists($keepHash{$temp[0]}) ){
			$print = 1;
			$current = $temp[0];
		}else{
			$print = 0;
			$current = "";
		}
	}
	if( $print == 1 ){
		if( $line =~ />/ ){
			print OUT $line, " Orthogroup=", $keepHash{$current}, "\n";
		}else{
			print OUT $line, "\n";
		}
	}
}

close OUT;

#print Dumper( \%keepHash );

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################
# subroutine to print help

sub help{
	print "\nfindExpandedOrthogroups.pl is a perl script developed by Steven Michael Mussmann\n\n";
	print "To report bugs send an email to mussmann\@email.uark.edu\n";
	print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
	print "Program Options:\n";
	print "\t\t[ -a | -f | -F | -h | -m | -o | -r | -q ]\n\n";
	print "\t-a:\tProtein fasta from reference species (default = GCF_000002035.6_GRCz11_protein.faa).\n\n";
	print "\t-f:\tSpecify the input file (default = Orthogroups.GeneCount.tsv).\n\n";
	print "\t-F:\tSpecify the other input file (default = Orthogroups.tsv).\n\n";
	print "\t-h:\tDisplay this help message.\n";
	print "\t\tThe program will die after the help message is displayed.\n\n";
	print "\t-m:\tSpecify the multiplier relative to the reference for determining orthologs to retain (default = 5).\n\n";
	print "\t-o:\tSpecify the output file name (Default = Orthogroups.expanded.faa).\n\n";
	print "\t-r:\tSpecify the reference species (default = GCF_000002035.6_GRCz11_protein).\n\n";
	print "\t-q:\tSpecify the query species (default = Ptychocheilus_lucius.proteins).\n\n";
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{
	my( $params ) =  @_;
	my %opts = %$params;

	# set default values for command line arguments
 	my $faa = $opts{a} || "GCF_000002035.6_GRCz11_protein.faa"; #protein fasta file for reference species
 	my $file = $opts{f} || "Orthogroups.GeneCount.tsv"; #Orthogroups.GeneCount.tsv from orthofinder
	my $org = $opts{F} || "Orthogroups.tsv"; # specify Orthogroups.tsv file from orthofinder
	my $out = $opts{o} || "Orthogroups.expanded.faa"; #used to specify output file name
	my $mult = $opts{m} || 5; # multiplier for determining which ortholog groups to retain
	my $ref = $opts{r} || "GCF_000002035.6_GRCz11_protein"; #used to specify reference species
	my $qry = $opts{q} || "Ptychocheilus_lucius.proteins"; #used to specify query species
	
	return( $file, $out, $ref, $qry, $org, $faa, $mult );
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
